From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] ax25: Fix possible oops in ax25_make_new
Date: Sun, 27 Sep 2009 22:57:02 +0200
Message-ID: <20090927205701.GA7205@del.dom.local>
References: <20090921201157.GA5460@del.dom.local>
 <4ABA9058.3010605@free.fr>
 <20090925131038.GA14778@ff.dom.local>
 <20090925134052.GA1661@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Bernard Pidoux <bernard.pidoux@upmc.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Ralf Baechle DL5RB <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:40012 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbZI0U6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2009 16:58:18 -0400
Content-Disposition: inline
In-Reply-To: <20090925134052.GA1661@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ax25_make_new, if kmemdup of digipeat returns an error, there would
be an oops in sk_free while calling sk_destruct, because sk_protinfo
is NULL at the moment; move sk->sk_destruct initialization after this.

BTW of reported-by: Bernard Pidoux F6BVP <f6bvp@free.fr>

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/ax25/af_ax25.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index fbcac76..9884639 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -900,7 +900,6 @@ struct sock *ax25_make_new(struct sock *osk, struct ax25_dev *ax25_dev)
 
 	sock_init_data(NULL, sk);
 
-	sk->sk_destruct = ax25_free_sock;
 	sk->sk_type     = osk->sk_type;
 	sk->sk_priority = osk->sk_priority;
 	sk->sk_protocol = osk->sk_protocol;
@@ -938,6 +937,7 @@ struct sock *ax25_make_new(struct sock *osk, struct ax25_dev *ax25_dev)
 	}
 
 	sk->sk_protinfo = ax25;
+	sk->sk_destruct = ax25_free_sock;
 	ax25->sk    = sk;
 
 	return sk;
