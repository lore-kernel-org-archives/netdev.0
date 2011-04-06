From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 18/20] usb-smsc95xx: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:23 -0700
Message-ID: <1302050665-10460-19-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
 <1302050665-10460-6-git-send-email-maheshb@google.com>
 <1302050665-10460-7-git-send-email-maheshb@google.com>
 <1302050665-10460-8-git-send-email-maheshb@google.com>
 <1302050665-10460-9-git-send-email-maheshb@google.com>
 <1302050665-10460-10-git-send-email-maheshb@google.com>
 <1302050665-10460-11-git-send-email-maheshb@google.com>
 <1302050665-10460-12-git-send-email-maheshb@google.com>
 <1302050665-10460-13-git-send-email-maheshb@google.com>
 <1302050665-10460-14-git-send-email-maheshb@google.com>
 <1302050665-10460-15-git-send-email-maheshb@google.com>
 <1302050665-10460-16-git-send-email-maheshb@google.com>
 <1302050665-10460-17-git-send-email-maheshb@google.com>
 <1302050665-10460-18-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28067 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240Ab1DFAo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:56 -0400
In-Reply-To: <1302050665-10460-18-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/usb/smsc95xx.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 708f208..ffdc654 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -933,7 +933,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	}
 
 	/* Enable or disable checksum offload engines */
-	smsc95xx_set_features(dev->net, dev->net->features);
+	smsc95xx_set_features(dev->net, dev->net->legacy_features);
 
 	smsc95xx_set_multicast(dev->net);
 
@@ -1000,11 +1000,11 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	spin_lock_init(&pdata->mac_cr_lock);
 
 	if (DEFAULT_TX_CSUM_ENABLE)
-		dev->net->features |= NETIF_F_HW_CSUM;
+		dev->net->legacy_features |= NETIF_F_HW_CSUM;
 	if (DEFAULT_RX_CSUM_ENABLE)
-		dev->net->features |= NETIF_F_RXCSUM;
+		dev->net->legacy_features |= NETIF_F_RXCSUM;
 
-	dev->net->hw_features = NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
+	dev->net->legacy_hw_features = NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 
 	smsc95xx_init_mac_address(dev);
 
@@ -1079,7 +1079,7 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 			/* last frame in this batch */
 			if (skb->len == size) {
-				if (dev->net->features & NETIF_F_RXCSUM)
+				if (dev->net->legacy_features & NETIF_F_RXCSUM)
 					smsc95xx_rx_csum_offload(skb);
 				skb_trim(skb, skb->len - 4); /* remove fcs */
 				skb->truesize = size + sizeof(struct sk_buff);
@@ -1097,7 +1097,7 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			ax_skb->data = packet;
 			skb_set_tail_pointer(ax_skb, size);
 
-			if (dev->net->features & NETIF_F_RXCSUM)
+			if (dev->net->legacy_features & NETIF_F_RXCSUM)
 				smsc95xx_rx_csum_offload(ax_skb);
 			skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
 			ax_skb->truesize = size + sizeof(struct sk_buff);
-- 
1.7.3.1

