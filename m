From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 3/3] bnx2x: Using DMAE to initialize the chip
Date: Mon, 09 Mar 2009 12:52:21 +0200
Message-ID: <1236595941.11030.14.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Alex Chiang" <achiang@hp.com>,
	"Bjorn Helgaas" <bjorn.helgaas@hp.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3320 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752549AbZCIKxV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 06:53:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 3/3] bnx2x: Using DMAE to initialize the chip

There was a bug, which occasionally caused failure in PRAM initialization after
the cold boot.
Also incremented version number to 1.45.27.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_init.h |    4 ----
 drivers/net/bnx2x_main.c |   18 +++++++++---------
 2 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index a6c0b3a..3b0c249 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -150,7 +150,6 @@ static void bnx2x_init_ind_wr(struct bnx2x *bp, u32 addr, const u32 *data,
 
 static void bnx2x_write_big_buf(struct bnx2x *bp, u32 addr, u32 len)
 {
-#ifdef USE_DMAE
 	int offset = 0;
 
 	if (bp->dmae_ready) {
@@ -164,9 +163,6 @@ static void bnx2x_write_big_buf(struct bnx2x *bp, u32 addr, u32 len)
 				 addr + offset, len);
 	} else
 		bnx2x_init_str_wr(bp, addr, bp->gunzip_buf, len);
-#else
-	bnx2x_init_str_wr(bp, addr, bp->gunzip_buf, len);
-#endif
 }
 
 static void bnx2x_init_fill(struct bnx2x *bp, u32 addr, int fill, u32 len)
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 48127f1..2e346a5 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -57,7 +57,7 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION	"1.45.26"
+#define DRV_MODULE_VERSION	"1.45.27"
 #define DRV_MODULE_RELDATE	"2009/01/26"
 #define BNX2X_BC_VER		0x040200
 
@@ -4035,10 +4035,10 @@ static void bnx2x_zero_sb(struct bnx2x *bp, int sb_id)
 {
 	int port = BP_PORT(bp);
 
-	bnx2x_init_fill(bp, BAR_USTRORM_INTMEM +
+	bnx2x_init_fill(bp, USTORM_INTMEM_ADDR +
 			USTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), 0,
 			sizeof(struct ustorm_status_block)/4);
-	bnx2x_init_fill(bp, BAR_CSTRORM_INTMEM +
+	bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR +
 			CSTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), 0,
 			sizeof(struct cstorm_status_block)/4);
 }
@@ -4092,18 +4092,18 @@ static void bnx2x_zero_def_sb(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
 
-	bnx2x_init_fill(bp, BAR_USTRORM_INTMEM +
+	bnx2x_init_fill(bp, TSTORM_INTMEM_ADDR +
+			TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
+			sizeof(struct tstorm_def_status_block)/4);
+	bnx2x_init_fill(bp, USTORM_INTMEM_ADDR +
 			USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
 			sizeof(struct ustorm_def_status_block)/4);
-	bnx2x_init_fill(bp, BAR_CSTRORM_INTMEM +
+	bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR +
 			CSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
 			sizeof(struct cstorm_def_status_block)/4);
-	bnx2x_init_fill(bp, BAR_XSTRORM_INTMEM +
+	bnx2x_init_fill(bp, XSTORM_INTMEM_ADDR +
 			XSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
 			sizeof(struct xstorm_def_status_block)/4);
-	bnx2x_init_fill(bp, BAR_TSTRORM_INTMEM +
-			TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
-			sizeof(struct tstorm_def_status_block)/4);
 }
 
 static void bnx2x_init_def_sb(struct bnx2x *bp,
-- 
1.5.6.3




