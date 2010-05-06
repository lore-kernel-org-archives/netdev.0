From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 1/3 v2] bnx2: Add GRO support.
Date: Thu, 6 May 2010 11:58:12 -0700
Message-ID: <1273172293-10241-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1994 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754816Ab0EFSqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 14:46:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And turn on NETIF_F_GRO by default [requested by DaveM].

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ab26bbc..320526b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3207,10 +3207,10 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 #ifdef BCM_VLAN
 		if (hw_vlan)
-			vlan_hwaccel_receive_skb(skb, bp->vlgrp, vtag);
+			vlan_gro_receive(&bnapi->napi, bp->vlgrp, vtag, skb);
 		else
 #endif
-			netif_receive_skb(skb);
+			napi_gro_receive(&bnapi->napi, skb);
 
 		rx_pkt++;
 
@@ -8296,7 +8296,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	memcpy(dev->dev_addr, bp->mac_addr, 6);
 	memcpy(dev->perm_addr, bp->mac_addr, 6);
 
-	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
+	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_GRO;
 	vlan_features_add(dev, NETIF_F_IP_CSUM | NETIF_F_SG);
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
 		dev->features |= NETIF_F_IPV6_CSUM;
-- 
1.6.4.GIT


