From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH] net-next: Fix __inet_inherit_port() to correctly increment bsockets and num_owners
Date: Fri, 26 Nov 2010 16:01:25 -0800 (PST)
Message-ID: <548718.40457.qm@web53706.mail.re2.yahoo.com>
References: <1290768477.2855.97.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53706.mail.re2.yahoo.com ([206.190.37.27]:49013 "HELO
	web53706.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751674Ab0K0AB0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 19:01:26 -0500
In-Reply-To: <1290768477.2855.97.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, here is the patch against net-next.

Thanks,
Tomar


---
inet sockets corresponding to passive connections are added to the bind hash
using ___inet_inherit_port(). These sockets are later removed from the bind 
hash using __inet_put_port(). These two functions are not exactly symmetrical. 
__inet_put_port() decrements hashinfo->bsockets and tb->num_owners, whereas 
___inet_inherit_port() does not increment them. This results in both of these 
going to -ve values.

This patch fixes this by calling inet_bind_hash() from ___inet_inherit_port(),
which does the right thing.

'bsockets' and 'num_owners' were introduced by commit a9d8f9110d7e953c 
(inet: Allowing more than 64k connections and heavily optimize bind(0))

Signed-off-by: Nagendra Singh Tomar <tomer_iisc@yahoo.com>

---
--- linux-2.6.37-rc3/net/ipv4/inet_hashtables.c.orig	2010-11-26 13:28:51.034811940 -0500
+++ linux-2.6.37-rc3/net/ipv4/inet_hashtables.c	2010-11-26 14:41:41.006268035 -0500
@@ -133,8 +133,7 @@ int __inet_inherit_port(struct sock *sk,
 			}
 		}
 	}
-	sk_add_bind_node(child, &tb->owners);
-	inet_csk(child)->icsk_bind_hash = tb;
+	inet_bind_hash(child, tb, port);
 	spin_unlock(&head->lock);
 
 	return 0;
--- 	





      
