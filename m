From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 2/16][BNX2]:  Fix register and memory test on 5709.
Date: Thu, 03 May 2007 00:28:29 -0700
Message-ID: <1178177309.4909.66.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2220 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030938AbXECGld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:41:33 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix register and memory test on 5709.

Tweak registers and memory test range for 5709.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 9f0a067..6d05397 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3763,10 +3763,11 @@ static int
 bnx2_test_registers(struct bnx2 *bp)
 {
 	int ret;
-	int i;
+	int i, is_5709;
 	static const struct {
 		u16   offset;
 		u16   flags;
+#define BNX2_FL_NOT_5709	1
 		u32   rw_mask;
 		u32   ro_mask;
 	} reg_tbl[] = {
@@ -3774,26 +3775,26 @@ bnx2_test_registers(struct bnx2 *bp)
 		{ 0x0090, 0, 0xffffffff, 0x00000000 },
 		{ 0x0094, 0, 0x00000000, 0x00000000 },
 
-		{ 0x0404, 0, 0x00003f00, 0x00000000 },
-		{ 0x0418, 0, 0x00000000, 0xffffffff },
-		{ 0x041c, 0, 0x00000000, 0xffffffff },
-		{ 0x0420, 0, 0x00000000, 0x80ffffff },
-		{ 0x0424, 0, 0x00000000, 0x00000000 },
-		{ 0x0428, 0, 0x00000000, 0x00000001 },
-		{ 0x0450, 0, 0x00000000, 0x0000ffff },
-		{ 0x0454, 0, 0x00000000, 0xffffffff },
-		{ 0x0458, 0, 0x00000000, 0xffffffff },
-
-		{ 0x0808, 0, 0x00000000, 0xffffffff },
-		{ 0x0854, 0, 0x00000000, 0xffffffff },
-		{ 0x0868, 0, 0x00000000, 0x77777777 },
-		{ 0x086c, 0, 0x00000000, 0x77777777 },
-		{ 0x0870, 0, 0x00000000, 0x77777777 },
-		{ 0x0874, 0, 0x00000000, 0x77777777 },
-
-		{ 0x0c00, 0, 0x00000000, 0x00000001 },
-		{ 0x0c04, 0, 0x00000000, 0x03ff0001 },
-		{ 0x0c08, 0, 0x0f0ff073, 0x00000000 },
+		{ 0x0404, BNX2_FL_NOT_5709, 0x00003f00, 0x00000000 },
+		{ 0x0418, BNX2_FL_NOT_5709, 0x00000000, 0xffffffff },
+		{ 0x041c, BNX2_FL_NOT_5709, 0x00000000, 0xffffffff },
+		{ 0x0420, BNX2_FL_NOT_5709, 0x00000000, 0x80ffffff },
+		{ 0x0424, BNX2_FL_NOT_5709, 0x00000000, 0x00000000 },
+		{ 0x0428, BNX2_FL_NOT_5709, 0x00000000, 0x00000001 },
+		{ 0x0450, BNX2_FL_NOT_5709, 0x00000000, 0x0000ffff },
+		{ 0x0454, BNX2_FL_NOT_5709, 0x00000000, 0xffffffff },
+		{ 0x0458, BNX2_FL_NOT_5709, 0x00000000, 0xffffffff },
+
+		{ 0x0808, BNX2_FL_NOT_5709, 0x00000000, 0xffffffff },
+		{ 0x0854, BNX2_FL_NOT_5709, 0x00000000, 0xffffffff },
+		{ 0x0868, BNX2_FL_NOT_5709, 0x00000000, 0x77777777 },
+		{ 0x086c, BNX2_FL_NOT_5709, 0x00000000, 0x77777777 },
+		{ 0x0870, BNX2_FL_NOT_5709, 0x00000000, 0x77777777 },
+		{ 0x0874, BNX2_FL_NOT_5709, 0x00000000, 0x77777777 },
+
+		{ 0x0c00, BNX2_FL_NOT_5709, 0x00000000, 0x00000001 },
+		{ 0x0c04, BNX2_FL_NOT_5709, 0x00000000, 0x03ff0001 },
+		{ 0x0c08, BNX2_FL_NOT_5709,  0x0f0ff073, 0x00000000 },
 
 		{ 0x1000, 0, 0x00000000, 0x00000001 },
 		{ 0x1004, 0, 0x00000000, 0x000f0001 },
@@ -3840,7 +3841,6 @@ bnx2_test_registers(struct bnx2 *bp)
 
 		{ 0x5004, 0, 0x00000000, 0x0000007f },
 		{ 0x5008, 0, 0x0f0007ff, 0x00000000 },
-		{ 0x500c, 0, 0xf800f800, 0x07ff07ff },
 
 		{ 0x5c00, 0, 0x00000000, 0x00000001 },
 		{ 0x5c04, 0, 0x00000000, 0x0003000f },
@@ -3880,8 +3880,16 @@ bnx2_test_registers(struct bnx2 *bp)
 	};
 
 	ret = 0;
+	is_5709 = 0;
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		is_5709 = 1;
+
 	for (i = 0; reg_tbl[i].offset != 0xffff; i++) {
 		u32 offset, rw_mask, ro_mask, save_val, val;
+		u16 flags = reg_tbl[i].flags;
+
+		if (is_5709 && (flags & BNX2_FL_NOT_5709))
+			continue;
 
 		offset = (u32) reg_tbl[i].offset;
 		rw_mask = reg_tbl[i].rw_mask;
@@ -3950,10 +3958,10 @@ bnx2_test_memory(struct bnx2 *bp)
 {
 	int ret = 0;
 	int i;
-	static const struct {
+	static struct mem_entry {
 		u32   offset;
 		u32   len;
-	} mem_tbl[] = {
+	} mem_tbl_5706[] = {
 		{ 0x60000,  0x4000 },
 		{ 0xa0000,  0x3000 },
 		{ 0xe0000,  0x4000 },
@@ -3961,7 +3969,21 @@ bnx2_test_memory(struct bnx2 *bp)
 		{ 0x1a0000, 0x4000 },
 		{ 0x160000, 0x4000 },
 		{ 0xffffffff, 0    },
+	},
+	mem_tbl_5709[] = {
+		{ 0x60000,  0x4000 },
+		{ 0xa0000,  0x3000 },
+		{ 0xe0000,  0x4000 },
+		{ 0x120000, 0x4000 },
+		{ 0x1a0000, 0x4000 },
+		{ 0xffffffff, 0    },
 	};
+	struct mem_entry *mem_tbl;
+
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		mem_tbl = mem_tbl_5709;
+	else
+		mem_tbl = mem_tbl_5706;
 
 	for (i = 0; mem_tbl[i].offset != 0xffffffff; i++) {
 		if ((ret = bnx2_do_mem_test(bp, mem_tbl[i].offset,


