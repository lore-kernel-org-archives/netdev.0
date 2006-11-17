From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 15/17][BNX2]: Download 5709 firmware.
Date: Thu, 16 Nov 2006 19:14:44 -0800
Message-ID: <1163733284.6658.48.camel@rh4>
References: <1163731443.6658.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3846 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S1424927AbWKQCWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 21:22:19 -0500
To: davem@davemloft.net
In-Reply-To: <1163731443.6658.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Download 5709 firmware.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 52fe620..92897ef 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -53,6 +53,7 @@
 
 #include "bnx2.h"
 #include "bnx2_fw.h"
+#include "bnx2_fw2.h"
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
@@ -2410,7 +2411,10 @@ bnx2_init_cpus(struct bnx2 *bp)
 	cpu_reg.spad_base = BNX2_RXP_SCRATCH;
 	cpu_reg.mips_view_base = 0x8000000;
 
-	fw = &bnx2_rxp_fw_06;
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		fw = &bnx2_rxp_fw_09;
+	else
+		fw = &bnx2_rxp_fw_06;
 
 	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
@@ -2430,7 +2434,10 @@ bnx2_init_cpus(struct bnx2 *bp)
 	cpu_reg.spad_base = BNX2_TXP_SCRATCH;
 	cpu_reg.mips_view_base = 0x8000000;
 
-	fw = &bnx2_txp_fw_06;
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		fw = &bnx2_txp_fw_09;
+	else
+		fw = &bnx2_txp_fw_06;
 
 	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
@@ -2450,7 +2457,10 @@ bnx2_init_cpus(struct bnx2 *bp)
 	cpu_reg.spad_base = BNX2_TPAT_SCRATCH;
 	cpu_reg.mips_view_base = 0x8000000;
 
-	fw = &bnx2_tpat_fw_06;
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		fw = &bnx2_tpat_fw_09;
+	else
+		fw = &bnx2_tpat_fw_06;
 
 	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
@@ -2470,12 +2480,36 @@ bnx2_init_cpus(struct bnx2 *bp)
 	cpu_reg.spad_base = BNX2_COM_SCRATCH;
 	cpu_reg.mips_view_base = 0x8000000;
 
-	fw = &bnx2_com_fw_06;
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		fw = &bnx2_com_fw_09;
+	else
+		fw = &bnx2_com_fw_06;
 
 	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
 		goto init_cpu_err;
 
+	/* Initialize the Command Processor. */
+	cpu_reg.mode = BNX2_CP_CPU_MODE;
+	cpu_reg.mode_value_halt = BNX2_CP_CPU_MODE_SOFT_HALT;
+	cpu_reg.mode_value_sstep = BNX2_CP_CPU_MODE_STEP_ENA;
+	cpu_reg.state = BNX2_CP_CPU_STATE;
+	cpu_reg.state_value_clear = 0xffffff;
+	cpu_reg.gpr0 = BNX2_CP_CPU_REG_FILE;
+	cpu_reg.evmask = BNX2_CP_CPU_EVENT_MASK;
+	cpu_reg.pc = BNX2_CP_CPU_PROGRAM_COUNTER;
+	cpu_reg.inst = BNX2_CP_CPU_INSTRUCTION;
+	cpu_reg.bp = BNX2_CP_CPU_HW_BREAKPOINT;
+	cpu_reg.spad_base = BNX2_CP_SCRATCH;
+	cpu_reg.mips_view_base = 0x8000000;
+
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		fw = &bnx2_cp_fw_09;
+
+		load_cpu_fw(bp, &cpu_reg, fw);
+		if (rc)
+			goto init_cpu_err;
+	}
 init_cpu_err:
 	bnx2_gunzip_end(bp);
 	return rc;


