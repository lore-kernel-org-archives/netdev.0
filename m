From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Use BUILD_BUG_ON for tcp_skb_cb size checking
Date: Fri, 07 Dec 2007 20:42:04 +0300
Message-ID: <475985EC.6050608@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53595 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753244AbXLGRmO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 12:42:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sizeof(struct tcp_skb_cb) should not be less than the
sizeof(skb->cb). This is checked in net/ipv4/tcp.c, but
this check can be made more gracefully.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8e65182..c8bebd3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2411,7 +2411,6 @@ void tcp_done(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(tcp_done);
 
-extern void __skb_cb_too_small_for_tcp(int, int);
 extern struct tcp_congestion_ops tcp_reno;
 
 static __initdata unsigned long thash_entries;
@@ -2430,9 +2429,7 @@ void __init tcp_init(void)
 	unsigned long limit;
 	int order, i, max_share;
 
-	if (sizeof(struct tcp_skb_cb) > sizeof(skb->cb))
-		__skb_cb_too_small_for_tcp(sizeof(struct tcp_skb_cb),
-					   sizeof(skb->cb));
+	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
 
 	tcp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("tcp_bind_bucket",
