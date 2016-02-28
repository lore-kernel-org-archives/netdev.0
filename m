From: <igal.liberman@freescale.com>
Subject: [PATCH] fsl/fman: remove dTSEC-A003 Errata workaround
Date: Sun, 28 Feb 2016 23:59:41 +0200
Message-ID: <1456696781-32384-1-git-send-email-igal.liberman@freescale.com>
Reply-To: <igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <scottwood@freescale.com>, <madalin.bucur@freescale.com>,
	Igal Liberman <igal.liberman@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0119.outbound.protection.outlook.com ([65.55.169.119]:21328
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751041AbcB2Pc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 10:32:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igal Liberman <igal.liberman@freescale.com>

Errata dTSEC-A003 was fixed in P4080 rev 3.0.
Prior revisions are not supported, so the workaround can be removed.

Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/fman_dtsec.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman_dtsec.c b/drivers/net/ethernet/freescale/fman/fman_dtsec.c
index 7c92eb8..09dd46d 100644
--- a/drivers/net/ethernet/freescale/fman/fman_dtsec.c
+++ b/drivers/net/ethernet/freescale/fman/fman_dtsec.c
@@ -932,14 +932,6 @@ int dtsec_set_tx_pause_frames(struct fman_mac *dtsec,
 	if (!is_init_done(dtsec->dtsec_drv_param))
 		return -EINVAL;
 
-	/* FM_BAD_TX_TS_IN_B_2_B_ERRATA_DTSEC_A003 Errata workaround */
-	if (dtsec->fm_rev_info.major == 2)
-		if (pause_time <= 320) {
-			pr_warn("pause-time: %d illegal.Should be > 320\n",
-				pause_time);
-			return -EINVAL;
-		}
-
 	if (pause_time) {
 		ptv = ioread32be(&regs->ptv);
 		ptv &= PTV_PTE_MASK;
-- 
1.7.9.5
