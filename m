From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 17/20] usb-smsc75xx: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:22 -0700
Message-ID: <1302050665-10460-18-git-send-email-maheshb@google.com>
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
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28072 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754248Ab1DFAo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:56 -0400
In-Reply-To: <1302050665-10460-17-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/usb/smsc75xx.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 860a20c..9c22f04 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -927,7 +927,7 @@ static int smsc75xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net, "RFE_CTL set to 0x%08x", pdata->rfe_ctl);
 
 	/* Enable or disable checksum offload engines */
-	smsc75xx_set_features(dev->net, dev->net->features);
+	smsc75xx_set_features(dev->net, dev->net->legacy_features);
 
 	smsc75xx_set_multicast(dev->net);
 
@@ -1030,15 +1030,15 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	INIT_WORK(&pdata->set_multicast, smsc75xx_deferred_multicast_write);
 
 	if (DEFAULT_TX_CSUM_ENABLE) {
-		dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+		dev->net->legacy_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 		if (DEFAULT_TSO_ENABLE)
-			dev->net->features |= NETIF_F_SG |
+			dev->net->legacy_features |= NETIF_F_SG |
 				NETIF_F_TSO | NETIF_F_TSO6;
 	}
 	if (DEFAULT_RX_CSUM_ENABLE)
-		dev->net->features |= NETIF_F_RXCSUM;
+		dev->net->legacy_features |= NETIF_F_RXCSUM;
 
-	dev->net->hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+	dev->net->legacy_hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_RXCSUM;
 
 	/* Init all registers */
@@ -1065,7 +1065,7 @@ static void smsc75xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 static void smsc75xx_rx_csum_offload(struct usbnet *dev, struct sk_buff *skb,
 				     u32 rx_cmd_a, u32 rx_cmd_b)
 {
-	if (!(dev->net->features & NETIF_F_RXCSUM) ||
+	if (!(dev->net->legacy_features & NETIF_F_RXCSUM) ||
 	    unlikely(rx_cmd_a & RX_CMD_A_LCSM)) {
 		skb->ip_summed = CHECKSUM_NONE;
 	} else {
-- 
1.7.3.1

