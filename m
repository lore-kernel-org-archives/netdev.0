From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next 3/8] bpf: Add BPF_ macros
Date: Sun, 11 Dec 2016 16:53:10 -0800
Message-ID: <1481503995-24825-4-git-send-email-dsa@cumulusnetworks.com>
References: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34008 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751817AbcLLAxZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 19:53:25 -0500
Received: by mail-pg0-f42.google.com with SMTP id x23so29048590pgx.1
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 16:53:24 -0800 (PST)
In-Reply-To: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on version in kernel repo, samples/bpf/libbpf.h

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/bpf_util.h | 179 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 179 insertions(+)

diff --git a/include/bpf_util.h b/include/bpf_util.h
index 726e34777755..5361dab1933d 100644
--- a/include/bpf_util.h
+++ b/include/bpf_util.h
@@ -65,6 +65,185 @@ struct bpf_cfg_in {
 	struct sock_filter *ops;
 };
 
+/* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
+
+#define BPF_ALU64_REG(OP, DST, SRC)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_X,	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+#define BPF_ALU32_REG(OP, DST, SRC)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_OP(OP) | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+/* ALU ops on immediates, bpf_add|sub|...: dst_reg += imm32 */
+
+#define BPF_ALU64_IMM(OP, DST, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_K,	\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+#define BPF_ALU32_IMM(OP, DST, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_OP(OP) | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* Short form of mov, dst_reg = src_reg */
+
+#define BPF_MOV64_REG(DST, SRC)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_MOV | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+#define BPF_MOV32_REG(DST, SRC)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_MOV | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+/* Short form of mov, dst_reg = imm32 */
+
+#define BPF_MOV64_IMM(DST, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_MOV | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+#define BPF_MOV32_IMM(DST, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_MOV | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* BPF_LD_IMM64 macro encodes single 'load 64-bit immediate' insn */
+#define BPF_LD_IMM64(DST, IMM)					\
+	BPF_LD_IMM64_RAW(DST, 0, IMM)
+
+#define BPF_LD_IMM64_RAW(DST, SRC, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_LD | BPF_DW | BPF_IMM,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = (__u32) (IMM) }),			\
+	((struct bpf_insn) {					\
+		.code  = 0, /* zero is reserved opcode */	\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = ((__u64) (IMM)) >> 32 })
+
+#ifndef BPF_PSEUDO_MAP_FD
+# define BPF_PSEUDO_MAP_FD	1
+#endif
+
+/* pseudo BPF_LD_IMM64 insn used to refer to process-local map_fd */
+#define BPF_LD_MAP_FD(DST, MAP_FD)				\
+	BPF_LD_IMM64_RAW(DST, BPF_PSEUDO_MAP_FD, MAP_FD)
+
+
+/* Direct packet access, R0 = *(uint *) (skb->data + imm32) */
+
+#define BPF_LD_ABS(SIZE, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_ABS,	\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* Memory load, dst_reg = *(uint *) (src_reg + off16) */
+
+#define BPF_LDX_MEM(SIZE, DST, SRC, OFF)			\
+	((struct bpf_insn) {					\
+		.code  = BPF_LDX | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+/* Memory store, *(uint *) (dst_reg + off16) = src_reg */
+
+#define BPF_STX_MEM(SIZE, DST, SRC, OFF)			\
+	((struct bpf_insn) {					\
+		.code  = BPF_STX | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+/* Memory store, *(uint *) (dst_reg + off16) = imm32 */
+
+#define BPF_ST_MEM(SIZE, DST, OFF, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ST | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Conditional jumps against registers, if (dst_reg 'op' src_reg) goto pc + off16 */
+
+#define BPF_JMP_REG(OP, DST, SRC, OFF)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_OP(OP) | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+/* Conditional jumps against immediates, if (dst_reg 'op' imm32) goto pc + off16 */
+
+#define BPF_JMP_IMM(OP, DST, IMM, OFF)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_OP(OP) | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Raw code statement block */
+
+#define BPF_RAW_INSN(CODE, DST, SRC, OFF, IMM)			\
+	((struct bpf_insn) {					\
+		.code  = CODE,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Program exit */
+
+#define BPF_EXIT_INSN()						\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_EXIT,			\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
 int bpf_parse_common(enum bpf_prog_type type, struct bpf_cfg_in *cfg,
 		     const struct bpf_cfg_ops *ops, void *nl);
 
-- 
2.1.4
