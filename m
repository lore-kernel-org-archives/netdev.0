From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 13/20] veth: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:18 -0700
Message-ID: <1302050665-10460-14-git-send-email-maheshb@google.com>
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
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28065 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224Ab1DFAoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:55 -0400
In-Reply-To: <1302050665-10460-13-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/veth.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 6542288..a0acfe8 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -131,7 +131,7 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* don't change ip_summed == CHECKSUM_PARTIAL, as that
 	   will cause bad checksum on forwarded packets */
 	if (skb->ip_summed == CHECKSUM_NONE &&
-	    rcv->features & NETIF_F_RXCSUM)
+	    rcv->legacy_features & NETIF_F_RXCSUM)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	length = skb->len;
@@ -265,10 +265,10 @@ static void veth_setup(struct net_device *dev)
 
 	dev->netdev_ops = &veth_netdev_ops;
 	dev->ethtool_ops = &veth_ethtool_ops;
-	dev->features |= NETIF_F_LLTX;
+	dev->legacy_features |= NETIF_F_LLTX;
 	dev->destructor = veth_dev_free;
 
-	dev->hw_features = NETIF_F_NO_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
+	dev->legacy_hw_features = NETIF_F_NO_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
 }
 
 /*
-- 
1.7.3.1

