From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next v2 06/10] be2net: remove a line of code that has no effect
Date: Mon, 28 Dec 2015 01:49:20 -0500
Message-ID: <1451285364-9074-7-git-send-email-sathya.perla@avagotech.com>
References: <1451285364-9074-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:54931 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751373AbbL1Gtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 01:49:35 -0500
In-Reply-To: <1451285364-9074-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes a line of code that changes adapter->recommended_prio
value followed by yet another assignment.
Also, the variable is used to store the vlan priority value that is already
shifted to the PCP bits position in the vlan tag format. Hence, the name of
this variable is changed to recommended_prio_bits.

Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be.h      | 2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c | 3 +--
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index d463563..93e5eab 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -521,7 +521,7 @@ struct be_adapter {
 	struct be_drv_stats drv_stats;
 	struct be_aic_obj aic_obj[MAX_EVT_QS];
 	u8 vlan_prio_bmap;	/* Available Priority BitMap */
-	u16 recommended_prio;	/* Recommended Priority */
+	u16 recommended_prio_bits;/* Recommended Priority bits in vlan tag */
 	struct be_dma_mem rx_filter; /* Cmd DMA mem for rx-filter */
 
 	struct be_dma_mem stats_cmd;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 91b4689..23f8b9e 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -308,8 +308,7 @@ static void be_async_grp5_cos_priority_process(struct be_adapter *adapter,
 
 	if (evt->valid) {
 		adapter->vlan_prio_bmap = evt->available_priority_bmap;
-		adapter->recommended_prio &= ~VLAN_PRIO_MASK;
-		adapter->recommended_prio =
+		adapter->recommended_prio_bits =
 			evt->reco_default_priority << VLAN_PRIO_SHIFT;
 	}
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 646b021..c9f9d4b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -729,7 +729,7 @@ static inline u16 be_get_tx_vlan_tag(struct be_adapter *adapter,
 	/* If vlan priority provided by OS is NOT in available bmap */
 	if (!(adapter->vlan_prio_bmap & (1 << vlan_prio)))
 		vlan_tag = (vlan_tag & ~VLAN_PRIO_MASK) |
-				adapter->recommended_prio;
+				adapter->recommended_prio_bits;
 
 	return vlan_tag;
 }
-- 
2.4.1
