From: Rodolfo Giometti <giometti@linux.it>
Subject: [PATCH] net dsa: add TX timestamping support
Date: Mon, 15 Oct 2012 15:33:27 +0200
Message-ID: <1350308008-17189-3-git-send-email-giometti@linux.it>
References: <1350308008-17189-1-git-send-email-giometti@linux.it>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Rodolfo Giometti <giometti@linux.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-196-116.sn1.eutelia.it ([62.94.196.116]:13955 "EHLO
	goldrake.enneenne.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753577Ab2JONyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 09:54:46 -0400
In-Reply-To: <1350308008-17189-1-git-send-email-giometti@linux.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rodolfo Giometti <giometti@linux.it>
---
 net/dsa/tag_dsa.c     |    8 ++++++++
 net/dsa/tag_edsa.c    |    8 ++++++++
 net/dsa/tag_trailer.c |    8 ++++++++
 3 files changed, 24 insertions(+)

diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index cacce1e..20c2959 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -24,6 +24,14 @@ netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
+	/* We should call skb_tx_timestamp() at bottom of this function,
+	 * just before dev_queue_xmit(), but the skb is going to be
+	 * modified by DSA stack so it is going to be NOT recognized
+	 * by the ptp_filter called into function skb_clone_tx_timestamp()
+	 * [see file linux/net/core/timestamping.c].
+	 */
+	skb_tx_timestamp(skb);
+
 	/*
 	 * Convert the outermost 802.1q tag to a DSA tag for tagged
 	 * packets, or insert a DSA tag between the addresses and
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index e70c43c..9138bda 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -25,6 +25,14 @@ netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
+	/* We should call skb_tx_timestamp() at bottom of this function,
+	 * just before dev_queue_xmit(), but the skb is going to be
+	 * modified by DSA stack so it is going to be NOT recognized
+	 * by the ptp_filter called into function skb_clone_tx_timestamp()
+	 * [see file linux/net/core/timestamping.c].
+	 */
+	skb_tx_timestamp(skb);
+
 	/*
 	 * Convert the outermost 802.1q tag to a DSA tag and prepend
 	 * a DSA ethertype field is the packet is tagged, or insert
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 94bc260..b92cad2 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -24,6 +24,14 @@ netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
+	/* We should call skb_tx_timestamp() at bottom of this function,
+	 * just before dev_queue_xmit(), but the skb is going to be
+	 * modified by DSA stack so it is going to be NOT recognized
+	 * by the ptp_filter called into function skb_clone_tx_timestamp()
+	 * [see file linux/net/core/timestamping.c].
+	 */
+	skb_tx_timestamp(skb);
+
 	/*
 	 * We have to make sure that the trailer ends up as the very
 	 * last 4 bytes of the packet.  This means that we have to pad
-- 
1.7.9.5
