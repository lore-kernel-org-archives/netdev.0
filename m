From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6] bnx2x: protect sequence increment with mutex
Date: Wed, 25 May 2011 17:55:51 +0300
Message-ID: <1306335351.15327.0.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3273 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755709Ab1EYOzv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2011 10:55:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index a97d9be..4b70311 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2222,12 +2222,13 @@ static void bnx2x_pmf_update(struct bnx2x *bp)
 u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param)
 {
 	int mb_idx = BP_FW_MB_IDX(bp);
-	u32 seq = ++bp->fw_seq;
+	u32 seq;
 	u32 rc = 0;
 	u32 cnt = 1;
 	u8 delay = CHIP_REV_IS_SLOW(bp) ? 100 : 10;
 
 	mutex_lock(&bp->fw_mb_mutex);
+	seq = ++bp->fw_seq;
 	SHMEM_WR(bp, func_mb[mb_idx].drv_mb_param, param);
 	SHMEM_WR(bp, func_mb[mb_idx].drv_mb_header, (command | seq));
 
-- 
1.7.2.2




