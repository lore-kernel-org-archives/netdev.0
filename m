From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: be friend with drop monitor
Date: Sat, 18 Jan 2014 18:27:49 -0800
Message-ID: <1390098469.27806.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:50618 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbaASC1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 21:27:52 -0500
Received: by mail-pa0-f44.google.com with SMTP id kq14so5649991pab.31
        for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 18:27:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Replace some dev_kfree_skb() with kfree_skb() calls when
we drop one skb, this might help bug tracking.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_gre.c    |    4 ++--
 net/ipv4/ip_tunnel.c |    4 ++--
 net/ipv4/ip_vti.c    |    2 +-
 net/ipv4/ipip.c      |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index e560ef34cf4b..e7a92fdb36f6 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -278,7 +278,7 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 
 free_skb:
-	dev_kfree_skb(skb);
+	kfree_skb(skb);
 out:
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
@@ -301,7 +301,7 @@ static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 
 free_skb:
-	dev_kfree_skb(skb);
+	kfree_skb(skb);
 out:
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 432c28ab3197..83ede2e7ca42 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -716,7 +716,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	if (skb_cow_head(skb, dev->needed_headroom)) {
 		dev->stats.tx_dropped++;
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 		return;
 	}
 
@@ -732,7 +732,7 @@ tx_error_icmp:
 #endif
 tx_error:
 	dev->stats.tx_errors++;
-	dev_kfree_skb(skb);
+	kfree_skb(skb);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_xmit);
 
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 0783200ad8d2..48eafae51769 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -162,7 +162,7 @@ tx_error_icmp:
 	dst_link_failure(skb);
 tx_error:
 	dev->stats.tx_errors++;
-	dev_kfree_skb(skb);
+	kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index fe3e9f7f1f0b..812b18351462 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -228,7 +228,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 
 tx_error:
-	dev_kfree_skb(skb);
+	kfree_skb(skb);
 out:
 	dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
