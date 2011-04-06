From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 14/20] jme: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:19 -0700
Message-ID: <1302050665-10460-15-git-send-email-maheshb@google.com>
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
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54012 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754133Ab1DFAox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:53 -0400
In-Reply-To: <1302050665-10460-14-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/jme.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index be4773f..10b972e 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -741,7 +741,7 @@ jme_set_clean_rxdesc(struct jme_adapter *jme, int i)
 	rxdesc->desc1.bufaddrl	= cpu_to_le32(
 					(__u64)rxbi->mapping & 0xFFFFFFFFUL);
 	rxdesc->desc1.datalen	= cpu_to_le16(rxbi->len);
-	if (jme->dev->features & NETIF_F_HIGHDMA)
+	if (jme->dev->legacy_features & NETIF_F_HIGHDMA)
 		rxdesc->desc1.flags = RXFLAG_64BIT;
 	wmb();
 	rxdesc->desc1.flags	|= RXFLAG_OWN | RXFLAG_INT;
@@ -1917,7 +1917,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 	struct jme_ring *txring = &(jme->txring[0]);
 	struct txdesc *txdesc = txring->desc, *ctxdesc;
 	struct jme_buffer_info *txbi = txring->bufinf, *ctxbi;
-	u8 hidma = jme->dev->features & NETIF_F_HIGHDMA;
+	u8 hidma = jme->dev->legacy_features & NETIF_F_HIGHDMA;
 	int i, nr_frags = skb_shinfo(skb)->nr_frags;
 	int mask = jme->tx_ring_mask;
 	struct skb_frag_struct *frag;
@@ -2911,13 +2911,13 @@ jme_init_one(struct pci_dev *pdev,
 	netdev->netdev_ops = &jme_netdev_ops;
 	netdev->ethtool_ops		= &jme_ethtool_ops;
 	netdev->watchdog_timeo		= TX_TIMEOUT;
-	netdev->hw_features		=	NETIF_F_IP_CSUM |
+	netdev->legacy_hw_features		=	NETIF_F_IP_CSUM |
 						NETIF_F_IPV6_CSUM |
 						NETIF_F_SG |
 						NETIF_F_TSO |
 						NETIF_F_TSO6 |
 						NETIF_F_RXCSUM;
-	netdev->features		=	NETIF_F_IP_CSUM |
+	netdev->legacy_features		=	NETIF_F_IP_CSUM |
 						NETIF_F_IPV6_CSUM |
 						NETIF_F_SG |
 						NETIF_F_TSO |
@@ -2925,7 +2925,7 @@ jme_init_one(struct pci_dev *pdev,
 						NETIF_F_HW_VLAN_TX |
 						NETIF_F_HW_VLAN_RX;
 	if (using_dac)
-		netdev->features	|=	NETIF_F_HIGHDMA;
+		netdev->legacy_features	|=	NETIF_F_HIGHDMA;
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	pci_set_drvdata(pdev, netdev);
@@ -3002,7 +3002,7 @@ jme_init_one(struct pci_dev *pdev,
 	jme->reg_gpreg1 = GPREG1_DEFAULT;
 
 	if (jme->reg_rxmcs & RXMCS_CHECKSUM)
-		netdev->features |= NETIF_F_RXCSUM;
+		netdev->legacy_features |= NETIF_F_RXCSUM;
 
 	/*
 	 * Get Max Read Req Size from PCI Config Space
-- 
1.7.3.1

