From: <igal.liberman@freescale.com>
Subject: [PATCH] fsl/fman: fix dtsec_set_tx_pause_frames
Date: Sun, 13 Mar 2016 21:14:43 +0200
Message-ID: <1457896483-7942-1-git-send-email-igal.liberman@freescale.com>
Reply-To: <igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <scottwood@freescale.com>, <madalin.bucur@freescale.com>,
	Igal Liberman <igal.liberman@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0116.outbound.protection.outlook.com ([157.56.111.116]:58587
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965326AbcCNPEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 11:04:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igal Liberman <igal.liberman@freescale.com>

Fix a bug introduced in e06a03b (fsl/fman: fix the pause_time test)
When pause_time is set to '0' - pause frames are disabled and
there's no need to apply dTSEC-A003 Errata workaround.

Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/fman_dtsec.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman_dtsec.c b/drivers/net/ethernet/freescale/fman/fman_dtsec.c
index 7c92eb8..c88918c 100644
--- a/drivers/net/ethernet/freescale/fman/fman_dtsec.c
+++ b/drivers/net/ethernet/freescale/fman/fman_dtsec.c
@@ -932,15 +932,14 @@ int dtsec_set_tx_pause_frames(struct fman_mac *dtsec,
 	if (!is_init_done(dtsec->dtsec_drv_param))
 		return -EINVAL;
 
-	/* FM_BAD_TX_TS_IN_B_2_B_ERRATA_DTSEC_A003 Errata workaround */
-	if (dtsec->fm_rev_info.major == 2)
-		if (pause_time <= 320) {
+	if (pause_time) {
+		/* FM_BAD_TX_TS_IN_B_2_B_ERRATA_DTSEC_A003 Errata workaround */
+		if (dtsec->fm_rev_info.major == 2 && pause_time <= 320) {
 			pr_warn("pause-time: %d illegal.Should be > 320\n",
 				pause_time);
 			return -EINVAL;
 		}
 
-	if (pause_time) {
 		ptv = ioread32be(&regs->ptv);
 		ptv &= PTV_PTE_MASK;
 		ptv |= pause_time & PTV_PT_MASK;
-- 
1.7.9.5
