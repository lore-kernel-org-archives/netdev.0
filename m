From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 13/25] bnx2x: WoL capability
Date: Wed, 13 Aug 2008 17:14:40 +0300
Message-ID: <1218636880.547.89.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1375 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755634AbYHMOO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:14:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WoL capability
All designs reported WoL capability regardless of HW limitations - check
if this device is actually capable of WoL

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index db6a3b9..0321870 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6897,6 +6897,7 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 {
 	u32 val, val2, val3, val4, id;
+	u16 pmc;
 
 	/* Get the chip revision id and number. */
 	/* chip num:16-31, rev:12-15, metal:4-11, bond_id:0-3 */
@@ -6954,8 +6955,16 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 		BNX2X_ERR("This driver needs bc_ver %X but found %X,"
 			  " please upgrade BC\n", BNX2X_BC_VER, val);
 	}
-	BNX2X_DEV_INFO("%sWoL Capable\n",
-		       (bp->flags & NO_WOL_FLAG)? "Not " : "");
+
+	if (BP_E1HVN(bp) == 0) {
+		pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_PMC, &pmc);
+		bp->flags |= (pmc & PCI_PM_CAP_PME_D3cold) ? 0 : NO_WOL_FLAG;
+	} else {
+		/* no WOL capability for E1HVN != 0 */
+		bp->flags |= NO_WOL_FLAG;
+	}
+	BNX2X_DEV_INFO("%sWoL capable\n",
+		       (bp->flags & NO_WOL_FLAG) ? "Not " : "");
 
 	val = SHMEM_RD(bp, dev_info.shared_hw_config.part_num);
 	val2 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[4]);
-- 
1.5.3.2




