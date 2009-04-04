From: John Wright <john.wright@hp.com>
Subject: [PATCH 3/4] bnx2x: Get init_ops offsets from the firmware file
Date: Sat,  4 Apr 2009 16:15:14 -0600
Message-ID: <1238883314-13140-3-git-send-email-john.wright@hp.com>
References: <1238883314-13140-1-git-send-email-john.wright@hp.com>
 <1238883314-13140-2-git-send-email-john.wright@hp.com>
Cc: Eilon Greenstein <eilong@broadcom.com>,
	John Wright <john.wright@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:11037 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719AbZDDWPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 18:15:20 -0400
In-Reply-To: <1238883314-13140-2-git-send-email-john.wright@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes the last dependency on bnx2x_init_values.h.

Signed-off-by: John Wright <john.wright@hp.com>
---
 drivers/net/bnx2x_init.h |  283 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 280 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 50fff14..b300b4e 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -73,6 +73,272 @@
 #define OP_WR_FPGA		0x1e /* write single register on FPGA */
 #define OP_WR_ASIC		0x1f /* write single register on ASIC */
 
+/* These are indexes into an array in the firmware file that gives the actual
+ * offsets for these chunks in the init_ops array */
+#define PRS_COMMON_START	0
+#define PRS_COMMON_END		1
+#define SRCH_COMMON_START	2
+#define SRCH_COMMON_END		3
+#define TSDM_COMMON_START	4
+#define TSDM_COMMON_END		5
+#define TCM_COMMON_START	6
+#define TCM_COMMON_END		7
+#define TCM_FUNC0_START		8
+#define TCM_FUNC0_END		9
+#define TCM_FUNC1_START		10
+#define TCM_FUNC1_END		11
+#define TCM_FUNC2_START		12
+#define TCM_FUNC2_END		13
+#define TCM_FUNC3_START		14
+#define TCM_FUNC3_END		15
+#define TCM_FUNC4_START		16
+#define TCM_FUNC4_END		17
+#define TCM_FUNC5_START		18
+#define TCM_FUNC5_END		19
+#define TCM_FUNC6_START		20
+#define TCM_FUNC6_END		21
+#define TCM_FUNC7_START		22
+#define TCM_FUNC7_END		23
+#define BRB1_COMMON_START	24
+#define BRB1_COMMON_END		25
+#define BRB1_PORT0_START	26
+#define BRB1_PORT0_END		27
+#define BRB1_PORT1_START	28
+#define BRB1_PORT1_END		29
+#define TSEM_COMMON_START	30
+#define TSEM_COMMON_END		31
+#define TSEM_PORT0_START	32
+#define TSEM_PORT0_END		33
+#define TSEM_PORT1_START	34
+#define TSEM_PORT1_END		35
+#define TSEM_FUNC0_START	36
+#define TSEM_FUNC0_END		37
+#define TSEM_FUNC1_START	38
+#define TSEM_FUNC1_END		39
+#define TSEM_FUNC2_START	40
+#define TSEM_FUNC2_END		41
+#define TSEM_FUNC3_START	42
+#define TSEM_FUNC3_END		43
+#define TSEM_FUNC4_START	44
+#define TSEM_FUNC4_END		45
+#define TSEM_FUNC5_START	46
+#define TSEM_FUNC5_END		47
+#define TSEM_FUNC6_START	48
+#define TSEM_FUNC6_END		49
+#define TSEM_FUNC7_START	50
+#define TSEM_FUNC7_END		51
+#define MISC_COMMON_START	52
+#define MISC_COMMON_END		53
+#define MISC_FUNC0_START	54
+#define MISC_FUNC0_END		55
+#define MISC_FUNC1_START	56
+#define MISC_FUNC1_END		57
+#define MISC_FUNC2_START	58
+#define MISC_FUNC2_END		59
+#define MISC_FUNC3_START	60
+#define MISC_FUNC3_END		61
+#define MISC_FUNC4_START	62
+#define MISC_FUNC4_END		63
+#define MISC_FUNC5_START	64
+#define MISC_FUNC5_END		65
+#define MISC_FUNC6_START	66
+#define MISC_FUNC6_END		67
+#define MISC_FUNC7_START	68
+#define MISC_FUNC7_END		69
+#define NIG_COMMON_START	70
+#define NIG_COMMON_END		71
+#define NIG_PORT0_START		72
+#define NIG_PORT0_END		73
+#define NIG_PORT1_START		74
+#define NIG_PORT1_END		75
+#define UPB_COMMON_START	76
+#define UPB_COMMON_END		77
+#define CSDM_COMMON_START	78
+#define CSDM_COMMON_END		79
+#define USDM_COMMON_START	80
+#define USDM_COMMON_END		81
+#define CCM_COMMON_START	82
+#define CCM_COMMON_END		83
+#define CCM_FUNC0_START		84
+#define CCM_FUNC0_END		85
+#define CCM_FUNC1_START		86
+#define CCM_FUNC1_END		87
+#define CCM_FUNC2_START		88
+#define CCM_FUNC2_END		89
+#define CCM_FUNC3_START		90
+#define CCM_FUNC3_END		91
+#define CCM_FUNC4_START		92
+#define CCM_FUNC4_END		93
+#define CCM_FUNC5_START		94
+#define CCM_FUNC5_END		95
+#define CCM_FUNC6_START		96
+#define CCM_FUNC6_END		97
+#define CCM_FUNC7_START		98
+#define CCM_FUNC7_END		99
+#define UCM_COMMON_START	100
+#define UCM_COMMON_END		101
+#define UCM_FUNC0_START		102
+#define UCM_FUNC0_END		103
+#define UCM_FUNC1_START		104
+#define UCM_FUNC1_END		105
+#define UCM_FUNC2_START		106
+#define UCM_FUNC2_END		107
+#define UCM_FUNC3_START		108
+#define UCM_FUNC3_END		109
+#define UCM_FUNC4_START		110
+#define UCM_FUNC4_END		111
+#define UCM_FUNC5_START		112
+#define UCM_FUNC5_END		113
+#define UCM_FUNC6_START		114
+#define UCM_FUNC6_END		115
+#define UCM_FUNC7_START		116
+#define UCM_FUNC7_END		117
+#define USEM_COMMON_START	118
+#define USEM_COMMON_END		119
+#define USEM_PORT0_START	120
+#define USEM_PORT0_END		121
+#define USEM_PORT1_START	122
+#define USEM_PORT1_END		123
+#define USEM_FUNC0_START	124
+#define USEM_FUNC0_END		125
+#define USEM_FUNC1_START	126
+#define USEM_FUNC1_END		127
+#define USEM_FUNC2_START	128
+#define USEM_FUNC2_END		129
+#define USEM_FUNC3_START	130
+#define USEM_FUNC3_END		131
+#define USEM_FUNC4_START	132
+#define USEM_FUNC4_END		133
+#define USEM_FUNC5_START	134
+#define USEM_FUNC5_END		135
+#define USEM_FUNC6_START	136
+#define USEM_FUNC6_END		137
+#define USEM_FUNC7_START	138
+#define USEM_FUNC7_END		139
+#define CSEM_COMMON_START	140
+#define CSEM_COMMON_END		141
+#define CSEM_PORT0_START	142
+#define CSEM_PORT0_END		143
+#define CSEM_PORT1_START	144
+#define CSEM_PORT1_END		145
+#define CSEM_FUNC0_START	146
+#define CSEM_FUNC0_END		147
+#define CSEM_FUNC1_START	148
+#define CSEM_FUNC1_END		149
+#define CSEM_FUNC2_START	150
+#define CSEM_FUNC2_END		151
+#define CSEM_FUNC3_START	152
+#define CSEM_FUNC3_END		153
+#define CSEM_FUNC4_START	154
+#define CSEM_FUNC4_END		155
+#define CSEM_FUNC5_START	156
+#define CSEM_FUNC5_END		157
+#define CSEM_FUNC6_START	158
+#define CSEM_FUNC6_END		159
+#define CSEM_FUNC7_START	160
+#define CSEM_FUNC7_END		161
+#define XPB_COMMON_START	162
+#define XPB_COMMON_END		163
+#define DQ_COMMON_START		164
+#define DQ_COMMON_END		165
+#define TIMERS_COMMON_START	166
+#define TIMERS_COMMON_END	167
+#define TIMERS_PORT0_START	168
+#define TIMERS_PORT0_END	169
+#define TIMERS_PORT1_START	170
+#define TIMERS_PORT1_END	171
+#define XSDM_COMMON_START	172
+#define XSDM_COMMON_END		173
+#define QM_COMMON_START		174
+#define QM_COMMON_END		175
+#define PBF_COMMON_START	176
+#define PBF_COMMON_END		177
+#define PBF_PORT0_START		178
+#define PBF_PORT0_END		179
+#define PBF_PORT1_START		180
+#define PBF_PORT1_END		181
+#define XCM_COMMON_START	182
+#define XCM_COMMON_END		183
+#define XCM_PORT0_START		184
+#define XCM_PORT0_END		185
+#define XCM_PORT1_START		186
+#define XCM_PORT1_END		187
+#define XCM_FUNC0_START		188
+#define XCM_FUNC0_END		189
+#define XCM_FUNC1_START		190
+#define XCM_FUNC1_END		191
+#define XCM_FUNC2_START		192
+#define XCM_FUNC2_END		193
+#define XCM_FUNC3_START		194
+#define XCM_FUNC3_END		195
+#define XCM_FUNC4_START		196
+#define XCM_FUNC4_END		197
+#define XCM_FUNC5_START		198
+#define XCM_FUNC5_END		199
+#define XCM_FUNC6_START		200
+#define XCM_FUNC6_END		201
+#define XCM_FUNC7_START		202
+#define XCM_FUNC7_END		203
+#define XSEM_COMMON_START	204
+#define XSEM_COMMON_END		205
+#define XSEM_PORT0_START	206
+#define XSEM_PORT0_END		207
+#define XSEM_PORT1_START	208
+#define XSEM_PORT1_END		209
+#define XSEM_FUNC0_START	210
+#define XSEM_FUNC0_END		211
+#define XSEM_FUNC1_START	212
+#define XSEM_FUNC1_END		213
+#define XSEM_FUNC2_START	214
+#define XSEM_FUNC2_END		215
+#define XSEM_FUNC3_START	216
+#define XSEM_FUNC3_END		217
+#define XSEM_FUNC4_START	218
+#define XSEM_FUNC4_END		219
+#define XSEM_FUNC5_START	220
+#define XSEM_FUNC5_END		221
+#define XSEM_FUNC6_START	222
+#define XSEM_FUNC6_END		223
+#define XSEM_FUNC7_START	224
+#define XSEM_FUNC7_END		225
+#define CDU_COMMON_START	226
+#define CDU_COMMON_END		227
+#define DMAE_COMMON_START	228
+#define DMAE_COMMON_END		229
+#define PXP_COMMON_START	230
+#define PXP_COMMON_END		231
+#define CFC_COMMON_START	232
+#define CFC_COMMON_END		233
+#define HC_COMMON_START		234
+#define HC_COMMON_END		235
+#define HC_PORT0_START		236
+#define HC_PORT0_END		237
+#define HC_PORT1_START		238
+#define HC_PORT1_END		239
+#define HC_FUNC0_START		240
+#define HC_FUNC0_END		241
+#define HC_FUNC1_START		242
+#define HC_FUNC1_END		243
+#define HC_FUNC2_START		244
+#define HC_FUNC2_END		245
+#define HC_FUNC3_START		246
+#define HC_FUNC3_END		247
+#define HC_FUNC4_START		248
+#define HC_FUNC4_END		249
+#define HC_FUNC5_START		250
+#define HC_FUNC5_END		251
+#define HC_FUNC6_START		252
+#define HC_FUNC6_END		253
+#define HC_FUNC7_START		254
+#define HC_FUNC7_END		255
+#define PXP2_COMMON_START	256
+#define PXP2_COMMON_END		257
+#define MISC_AEU_COMMON_START	258
+#define MISC_AEU_COMMON_END	259
+#define MISC_AEU_PORT0_START	260
+#define MISC_AEU_PORT0_END	261
+#define MISC_AEU_PORT1_START	262
+#define MISC_AEU_PORT1_END	263
 
 struct raw_op {
 	u32 op:8;
@@ -118,8 +384,6 @@ union init_op {
 	struct raw_op		raw;
 };
 
-#include "bnx2x_init_values.h"
-
 static void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val);
 static int bnx2x_gunzip(struct bnx2x *bp, u8 *zbuf, int len);
 
@@ -302,6 +566,18 @@ static void bnx2x_init_wr_wb(struct bnx2x *bp, u32 addr, const u32 *data,
 		bnx2x_init_ind_wr(bp, addr, bp->gunzip_buf, len);
 }
 
+static u32 bnx2x_get_op_offset(struct bnx2x *bp, u32 op_offset_idx)
+{
+	const struct bnx2x_fw_file *fw_file;
+	const u32 *offsets;
+
+	fw_file = (struct bnx2x_fw_file *)bp->firmware->data;
+	offsets = (u32 *)(bp->firmware->data +
+				le32_to_cpu(fw_file->init_ops_offsets.offset));
+
+	return offsets[op_offset_idx];
+}
+
 static int bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 {
 	int is_e1       = CHIP_IS_E1(bp);
@@ -341,7 +617,8 @@ static int bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 		return -EINVAL;
 	data_base = (u32 *)(bp->firmware->data + offset);
 
-	for (i = op_start; i < op_end; i++) {
+	for (i = bnx2x_get_op_offset(bp, op_start);
+	     i < bnx2x_get_op_offset(bp, op_end); i++) {
 #ifdef __BIG_ENDIAN
 		op = (union init_op *)&real_op;
 		pos = (u32 *)&init_ops[i];
-- 
1.5.6.5

