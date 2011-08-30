From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 6/8] bnx2x: init fw_seq after undi_unload is done
Date: Tue, 30 Aug 2011 13:08:44 +0300
Message-ID: <1314698926-24525-7-git-send-email-dmitry@broadcom.com>
References: <1314698926-24525-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1533 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879Ab1H3KIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 06:08:50 -0400
In-Reply-To: <1314698926-24525-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 00dc8f0..94382a7 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -9623,13 +9623,6 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	/* port info */
 	bnx2x_get_port_hwinfo(bp);
 
-	if (!BP_NOMCP(bp)) {
-		bp->fw_seq =
-			(SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_mb_header) &
-			 DRV_MSG_SEQ_NUMBER_MASK);
-		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
-	}
-
 	/* Get MAC addresses */
 	bnx2x_get_mac_hwinfo(bp);
 
@@ -9795,6 +9788,14 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	if (!BP_NOMCP(bp))
 		bnx2x_undi_unload(bp);
 
+	/* init fw_seq after undi_unload! */
+	if (!BP_NOMCP(bp)) {
+		bp->fw_seq =
+			(SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_mb_header) &
+			 DRV_MSG_SEQ_NUMBER_MASK);
+		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
+	}
+
 	if (CHIP_REV_IS_FPGA(bp))
 		dev_err(&bp->pdev->dev, "FPGA detected\n");
 
-- 
1.7.2.2
