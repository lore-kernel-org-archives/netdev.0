From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netns: remove one sparse warning
Date: Tue, 09 Sep 2014 08:24:53 -0700
Message-ID: <1410276293.7106.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:37209 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766AbaIIPYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 11:24:54 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so7285975pad.6
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 08:24:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

net/core/net_namespace.c:227:18: warning: incorrect type in argument 1
(different address spaces)
net/core/net_namespace.c:227:18:    expected void const *<noident>
net/core/net_namespace.c:227:18:    got struct net_generic [noderef]
<asn:4>*gen

We can use rcu_access_pointer() here as read-side access to the pointer
was removed at least one grace period ago.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/net_namespace.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 7c6b51a58968..7f155175bba8 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -224,7 +224,7 @@ static void net_free(struct net *net)
 		return;
 	}
 #endif
-	kfree(net->gen);
+	kfree(rcu_access_pointer(net->gen));
 	kmem_cache_free(net_cachep, net);
 }
 
