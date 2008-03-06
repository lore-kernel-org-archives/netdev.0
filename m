From: Li Yang <leoli@freescale.com>
Subject: [PATCH] ucc_geth: use correct thread number for 10/100Mbps link
Date: Thu,  6 Mar 2008 18:48:46 +0800
Message-ID: <1204800526-11670-1-git-send-email-leoli@freescale.com>
Cc: netdev@vger.kernel.org,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	Li Yang <leoli@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:37758 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756167AbYCFKiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 05:38:20 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id m26AcDdV026141
	for <netdev@vger.kernel.org>; Thu, 6 Mar 2008 03:38:14 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id m26AcBmp011510
	for <netdev@vger.kernel.org>; Thu, 6 Mar 2008 04:38:12 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Use thread number of 1 for 10/100Mbps link instead of 4.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/ucc_geth.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index fba0811..8cc3166 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -154,8 +154,8 @@ static struct ucc_geth_info ugeth_primary_info = {
 	.rxQoSMode = UCC_GETH_QOS_MODE_DEFAULT,
 	.aufc = UPSMR_AUTOMATIC_FLOW_CONTROL_MODE_NONE,
 	.padAndCrc = MACCFG2_PAD_AND_CRC_MODE_PAD_AND_CRC,
-	.numThreadsTx = UCC_GETH_NUM_OF_THREADS_4,
-	.numThreadsRx = UCC_GETH_NUM_OF_THREADS_4,
+	.numThreadsTx = UCC_GETH_NUM_OF_THREADS_1,
+	.numThreadsRx = UCC_GETH_NUM_OF_THREADS_1,
 	.riscTx = QE_RISC_ALLOCATION_RISC1_AND_RISC2,
 	.riscRx = QE_RISC_ALLOCATION_RISC1_AND_RISC2,
 };
@@ -3975,6 +3975,8 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		ug_info->uf_info.utfs = UCC_GETH_UTFS_GIGA_INIT;
 		ug_info->uf_info.utfet = UCC_GETH_UTFET_GIGA_INIT;
 		ug_info->uf_info.utftt = UCC_GETH_UTFTT_GIGA_INIT;
+		ug_info->numThreadsTx = UCC_GETH_NUM_OF_THREADS_4;
+		ug_info->numThreadsRx = UCC_GETH_NUM_OF_THREADS_4;
 	}
 
 	/* Set the bus id */
-- 
1.5.4

