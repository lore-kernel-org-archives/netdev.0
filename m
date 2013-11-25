From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] sit: use kfree_skb to replace dev_kfree_skb
Date: Mon, 25 Nov 2013 17:21:24 +0800
Message-ID: <1385371284-15105-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:7440 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751088Ab3KYJU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Nov 2013 04:20:29 -0500
Received: from fnstmail02.fnst.cn.fujitsu.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id rAP9KRwm027636
	for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 17:20:27 +0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In failure case, we should use kfree_skb not
dev_kfree_skb to free skbuff, dev_kfree_skb
is defined as consume_skb.

Trace takes advantage of this point.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/sit.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 8435267..366fbba 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -951,7 +951,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		if (!new_skb) {
 			ip_rt_put(rt);
 			dev->stats.tx_dropped++;
-			dev_kfree_skb(skb);
+			kfree_skb(skb);
 			return NETDEV_TX_OK;
 		}
 		if (skb->sk)
@@ -977,7 +977,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 tx_error_icmp:
 	dst_link_failure(skb);
 tx_error:
-	dev_kfree_skb(skb);
+	kfree_skb(skb);
 out:
 	dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
@@ -1017,7 +1017,7 @@ static netdev_tx_t sit_tunnel_xmit(struct sk_buff *skb,
 
 tx_err:
 	dev->stats.tx_errors++;
-	dev_kfree_skb(skb);
+	kfree_skb(skb);
 	return NETDEV_TX_OK;
 
 }
-- 
1.8.3.1
