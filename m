From: David Daney <david.daney@cavium.com>
Subject: [PATCH v2 3/5] MIPS: Add some instructions to uasm.
Date: Tue, 13 Jun 2017 15:28:45 -0700
Message-ID: <20170613222847.7122-4-david.daney@cavium.com>
References: <20170613222847.7122-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        Matt Redfearn <matt.redfearn@imgtec.com>,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0055.outbound.protection.outlook.com ([104.47.42.55]:62888
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751802AbdFMW3D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 18:29:03 -0400
In-Reply-To: <20170613222847.7122-1-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow on patches for eBPF JIT require these additional instructions:

   insn_bgtz, insn_blez, insn_break, insn_ddivu, insn_dmultu,
   insn_dsbh, insn_dshd, insn_dsllv, insn_dsra32, insn_dsrav,
   insn_dsrlv, insn_lbu, insn_movn, insn_movz, insn_multu, insn_nor,
   insn_sb, insn_sh, insn_slti, insn_dinsu, insn_lwu

... so, add them.

Sort the insn_* enumeration values alphabetically.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/include/asm/uasm.h | 30 +++++++++++++++++++++++
 arch/mips/mm/uasm-mips.c     | 21 ++++++++++++++++
 arch/mips/mm/uasm.c          | 58 ++++++++++++++++++++++++++++++++++----------
 3 files changed, 96 insertions(+), 13 deletions(-)

diff --git a/arch/mips/include/asm/uasm.h b/arch/mips/include/asm/uasm.h
index 3748f4d..59dae37 100644
--- a/arch/mips/include/asm/uasm.h
+++ b/arch/mips/include/asm/uasm.h
@@ -72,9 +72,12 @@ Ip_u1u2s3(_beq);
 Ip_u1u2s3(_beql);
 Ip_u1s2(_bgez);
 Ip_u1s2(_bgezl);
+Ip_u1s2(_bgtz);
+Ip_u1s2(_blez);
 Ip_u1s2(_bltz);
 Ip_u1s2(_bltzl);
 Ip_u1u2s3(_bne);
+Ip_u1(_break);
 Ip_u2s3u1(_cache);
 Ip_u1u2(_cfc1);
 Ip_u2u1(_cfcmsa);
@@ -82,19 +85,28 @@ Ip_u1u2(_ctc1);
 Ip_u2u1(_ctcmsa);
 Ip_u2u1s3(_daddiu);
 Ip_u3u1u2(_daddu);
+Ip_u1u2(_ddivu);
 Ip_u1(_di);
 Ip_u2u1msbu3(_dins);
 Ip_u2u1msbu3(_dinsm);
+Ip_u2u1msbu3(_dinsu);
 Ip_u1u2(_divu);
 Ip_u1u2u3(_dmfc0);
 Ip_u1u2u3(_dmtc0);
+Ip_u1u2(_dmultu);
 Ip_u2u1u3(_drotr);
 Ip_u2u1u3(_drotr32);
+Ip_u2u1(_dsbh);
+Ip_u2u1(_dshd);
 Ip_u2u1u3(_dsll);
 Ip_u2u1u3(_dsll32);
+Ip_u3u2u1(_dsllv);
 Ip_u2u1u3(_dsra);
+Ip_u2u1u3(_dsra32);
+Ip_u3u2u1(_dsrav);
 Ip_u2u1u3(_dsrl);
 Ip_u2u1u3(_dsrl32);
+Ip_u3u2u1(_dsrlv);
 Ip_u3u1u2(_dsubu);
 Ip_0(_eret);
 Ip_u2u1msbu3(_ext);
@@ -104,6 +116,7 @@ Ip_u1(_jal);
 Ip_u2u1(_jalr);
 Ip_u1(_jr);
 Ip_u2s3u1(_lb);
+Ip_u2s3u1(_lbu);
 Ip_u2s3u1(_ld);
 Ip_u3u1u2(_ldx);
 Ip_u2s3u1(_lh);
@@ -112,27 +125,35 @@ Ip_u2s3u1(_ll);
 Ip_u2s3u1(_lld);
 Ip_u1s2(_lui);
 Ip_u2s3u1(_lw);
+Ip_u2s3u1(_lwu);
 Ip_u3u1u2(_lwx);
 Ip_u1u2u3(_mfc0);
 Ip_u1u2u3(_mfhc0);
 Ip_u1(_mfhi);
 Ip_u1(_mflo);
+Ip_u3u1u2(_movn);
+Ip_u3u1u2(_movz);
 Ip_u1u2u3(_mtc0);
 Ip_u1u2u3(_mthc0);
 Ip_u1(_mthi);
 Ip_u1(_mtlo);
 Ip_u3u1u2(_mul);
+Ip_u1u2(_multu);
+Ip_u3u1u2(_nor);
 Ip_u3u1u2(_or);
 Ip_u2u1u3(_ori);
 Ip_u2s3u1(_pref);
 Ip_0(_rfe);
 Ip_u2u1u3(_rotr);
+Ip_u2s3u1(_sb);
 Ip_u2s3u1(_sc);
 Ip_u2s3u1(_scd);
 Ip_u2s3u1(_sd);
+Ip_u2s3u1(_sh);
 Ip_u2u1u3(_sll);
 Ip_u3u2u1(_sllv);
 Ip_s3s1s2(_slt);
+Ip_u2u1s3(_slti);
 Ip_u2u1s3(_sltiu);
 Ip_u3u1u2(_sltu);
 Ip_u2u1u3(_sra);
@@ -248,6 +269,15 @@ static inline void uasm_i_dsrl_safe(u32 **p, unsigned int a1,
 		uasm_i_dsrl32(p, a1, a2, a3 - 32);
 }
 
+static inline void uasm_i_dsra_safe(u32 **p, unsigned int a1,
+				    unsigned int a2, unsigned int a3)
+{
+	if (a3 < 32)
+		uasm_i_dsra(p, a1, a2, a3);
+	else
+		uasm_i_dsra32(p, a1, a2, a3 - 32);
+}
+
 /* Handle relocations. */
 struct uasm_reloc {
 	u32 *addr;
diff --git a/arch/mips/mm/uasm-mips.c b/arch/mips/mm/uasm-mips.c
index f3937e3..3f74f6c 100644
--- a/arch/mips/mm/uasm-mips.c
+++ b/arch/mips/mm/uasm-mips.c
@@ -59,9 +59,12 @@ static const struct insn const insn_table[insn_invalid] = {
 	[insn_beql]	= {M(beql_op, 0, 0, 0, 0, 0), RS | RT | BIMM},
 	[insn_bgez]	= {M(bcond_op, 0, bgez_op, 0, 0, 0), RS | BIMM},
 	[insn_bgezl]	= {M(bcond_op, 0, bgezl_op, 0, 0, 0), RS | BIMM},
+	[insn_bgtz]	= {M(bgtz_op, 0, 0, 0, 0, 0), RS | BIMM},
+	[insn_blez]	= {M(blez_op, 0, 0, 0, 0, 0), RS | BIMM},
 	[insn_bltz]	= {M(bcond_op, 0, bltz_op, 0, 0, 0), RS | BIMM},
 	[insn_bltzl]	= {M(bcond_op, 0, bltzl_op, 0, 0, 0), RS | BIMM},
 	[insn_bne]	= {M(bne_op, 0, 0, 0, 0, 0), RS | RT | BIMM},
+	[insn_break]	= {M(spec_op, 0, 0, 0, 0, break_op), SCIMM},
 #ifndef CONFIG_CPU_MIPSR6
 	[insn_cache]	= {M(cache_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
 #else
@@ -73,19 +76,28 @@ static const struct insn const insn_table[insn_invalid] = {
 	[insn_ctcmsa]	= {M(msa_op, 0, msa_ctc_op, 0, 0, msa_elm_op), RD | RE},
 	[insn_daddiu]	= {M(daddiu_op, 0, 0, 0, 0, 0), RS | RT | SIMM},
 	[insn_daddu]	= {M(spec_op, 0, 0, 0, 0, daddu_op), RS | RT | RD},
+	[insn_ddivu]	= {M(spec_op, 0, 0, 0, 0, ddivu_op), RS | RT},
 	[insn_di]	= {M(cop0_op, mfmc0_op, 0, 12, 0, 0), RT},
 	[insn_dins]	= {M(spec3_op, 0, 0, 0, 0, dins_op), RS | RT | RD | RE},
 	[insn_dinsm]	= {M(spec3_op, 0, 0, 0, 0, dinsm_op), RS | RT | RD | RE},
+	[insn_dinsu]	= {M(spec3_op, 0, 0, 0, 0, dinsu_op), RS | RT | RD | RE},
 	[insn_divu]	= {M(spec_op, 0, 0, 0, 0, divu_op), RS | RT},
 	[insn_dmfc0]	= {M(cop0_op, dmfc_op, 0, 0, 0, 0), RT | RD | SET},
 	[insn_dmtc0]	= {M(cop0_op, dmtc_op, 0, 0, 0, 0), RT | RD | SET},
+	[insn_dmultu]	= {M(spec_op, 0, 0, 0, 0, dmultu_op), RS | RT},
 	[insn_drotr]	= {M(spec_op, 1, 0, 0, 0, dsrl_op), RT | RD | RE},
 	[insn_drotr32]	= {M(spec_op, 1, 0, 0, 0, dsrl32_op), RT | RD | RE},
+	[insn_dsbh]	= {M(spec3_op, 0, 0, 0, dsbh_op, dbshfl_op), RT | RD},
+	[insn_dshd]	= {M(spec3_op, 0, 0, 0, dshd_op, dbshfl_op), RT | RD},
 	[insn_dsll]	= {M(spec_op, 0, 0, 0, 0, dsll_op), RT | RD | RE},
 	[insn_dsll32]	= {M(spec_op, 0, 0, 0, 0, dsll32_op), RT | RD | RE},
+	[insn_dsllv]	= {M(spec_op, 0, 0, 0, 0, dsllv_op),  RS | RT | RD},
 	[insn_dsra]	= {M(spec_op, 0, 0, 0, 0, dsra_op), RT | RD | RE},
+	[insn_dsra32]	= {M(spec_op, 0, 0, 0, 0, dsra32_op), RT | RD | RE},
+	[insn_dsrav]	= {M(spec_op, 0, 0, 0, 0, dsrav_op),  RS | RT | RD},
 	[insn_dsrl]	= {M(spec_op, 0, 0, 0, 0, dsrl_op), RT | RD | RE},
 	[insn_dsrl32]	= {M(spec_op, 0, 0, 0, 0, dsrl32_op), RT | RD | RE},
+	[insn_dsrlv]	= {M(spec_op, 0, 0, 0, 0, dsrlv_op),  RS | RT | RD},
 	[insn_dsubu]	= {M(spec_op, 0, 0, 0, 0, dsubu_op), RS | RT | RD},
 	[insn_eret]	= {M(cop0_op, cop_op, 0, 0, 0, eret_op),  0},
 	[insn_ext]	= {M(spec3_op, 0, 0, 0, 0, ext_op), RS | RT | RD | RE},
@@ -99,6 +111,7 @@ static const struct insn const insn_table[insn_invalid] = {
 	[insn_jr]	= {M(spec_op, 0, 0, 0, 0, jalr_op),  RS},
 #endif
 	[insn_lb]	= {M(lb_op, 0, 0, 0, 0, 0), RS | RT | SIMM},
+	[insn_lbu]	= {M(lbu_op, 0, 0, 0, 0, 0), RS | RT | SIMM},
 	[insn_ld]	= {M(ld_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
 	[insn_lddir]	= {M(lwc2_op, 0, 0, 0, lddir_op, mult_op), RS | RT | RD},
 	[insn_ldpte]	= {M(lwc2_op, 0, 0, 0, ldpte_op, mult_op), RS | RD},
@@ -114,11 +127,14 @@ static const struct insn const insn_table[insn_invalid] = {
 #endif
 	[insn_lui]	= {M(lui_op, 0, 0, 0, 0, 0),	RT | SIMM},
 	[insn_lw]	= {M(lw_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
+	[insn_lwu]	= {M(lwu_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
 	[insn_lwx]	= {M(spec3_op, 0, 0, 0, lwx_op, lx_op), RS | RT | RD},
 	[insn_mfc0]	= {M(cop0_op, mfc_op, 0, 0, 0, 0),  RT | RD | SET},
 	[insn_mfhc0]	= {M(cop0_op, mfhc0_op, 0, 0, 0, 0),  RT | RD | SET},
 	[insn_mfhi]	= {M(spec_op, 0, 0, 0, 0, mfhi_op), RD},
 	[insn_mflo]	= {M(spec_op, 0, 0, 0, 0, mflo_op), RD},
+	[insn_movn]	= {M(spec_op, 0, 0, 0, 0, movn_op), RS | RT | RD},
+	[insn_movz]	= {M(spec_op, 0, 0, 0, 0, movz_op), RS | RT | RD},
 	[insn_mtc0]	= {M(cop0_op, mtc_op, 0, 0, 0, 0),  RT | RD | SET},
 	[insn_mthc0]	= {M(cop0_op, mthc0_op, 0, 0, 0, 0),  RT | RD | SET},
 	[insn_mthi]	= {M(spec_op, 0, 0, 0, 0, mthi_op), RS},
@@ -128,6 +144,8 @@ static const struct insn const insn_table[insn_invalid] = {
 #else
 	[insn_mul]	= {M(spec_op, 0, 0, 0, mult_mul_op, mult_op), RS | RT | RD},
 #endif
+	[insn_multu]	= {M(spec_op, 0, 0, 0, 0, multu_op), RS | RT},
+	[insn_nor]	= {M(spec_op, 0, 0, 0, 0, nor_op),  RS | RT | RD},
 	[insn_or]	= {M(spec_op, 0, 0, 0, 0, or_op),  RS | RT | RD},
 	[insn_ori]	= {M(ori_op, 0, 0, 0, 0, 0),	RS | RT | UIMM},
 #ifndef CONFIG_CPU_MIPSR6
@@ -137,6 +155,7 @@ static const struct insn const insn_table[insn_invalid] = {
 #endif
 	[insn_rfe]	= {M(cop0_op, cop_op, 0, 0, 0, rfe_op),  0},
 	[insn_rotr]	= {M(spec_op, 1, 0, 0, 0, srl_op),  RT | RD | RE},
+	[insn_sb]	= {M(sb_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
 #ifndef CONFIG_CPU_MIPSR6
 	[insn_sc]	= {M(sc_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
 	[insn_scd]	= {M(scd_op, 0, 0, 0, 0, 0),	RS | RT | SIMM},
@@ -145,9 +164,11 @@ static const struct insn const insn_table[insn_invalid] = {
 	[insn_scd]	= {M6(spec3_op, 0, 0, 0, scd6_op),  RS | RT | SIMM9},
 #endif
 	[insn_sd]	= {M(sd_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
+	[insn_sh]	= {M(sh_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
 	[insn_sll]	= {M(spec_op, 0, 0, 0, 0, sll_op),  RT | RD | RE},
 	[insn_sllv]	= {M(spec_op, 0, 0, 0, 0, sllv_op),  RS | RT | RD},
 	[insn_slt]	= {M(spec_op, 0, 0, 0, 0, slt_op),  RS | RT | RD},
+	[insn_slti]	= {M(slti_op, 0, 0, 0, 0, 0), RS | RT | SIMM},
 	[insn_sltiu]	= {M(sltiu_op, 0, 0, 0, 0, 0), RS | RT | SIMM},
 	[insn_sltu]	= {M(spec_op, 0, 0, 0, 0, sltu_op), RS | RT | RD},
 	[insn_sra]	= {M(spec_op, 0, 0, 0, 0, sra_op),  RT | RD | RE},
diff --git a/arch/mips/mm/uasm.c b/arch/mips/mm/uasm.c
index f23ed85..57570c0 100644
--- a/arch/mips/mm/uasm.c
+++ b/arch/mips/mm/uasm.c
@@ -47,20 +47,24 @@ enum fields {
 
 enum opcode {
 	insn_addiu, insn_addu, insn_and, insn_andi, insn_bbit0, insn_bbit1,
-	insn_beq, insn_beql, insn_bgez, insn_bgezl, insn_bltz, insn_bltzl,
-	insn_bne, insn_cache, insn_cfc1, insn_cfcmsa, insn_ctc1, insn_ctcmsa,
-	insn_daddiu, insn_daddu, insn_di, insn_dins, insn_dinsm, insn_divu,
-	insn_dmfc0, insn_dmtc0, insn_drotr, insn_drotr32, insn_dsll,
-	insn_dsll32, insn_dsra, insn_dsrl, insn_dsrl32, insn_dsubu, insn_eret,
-	insn_ext, insn_ins, insn_j, insn_jal, insn_jalr, insn_jr, insn_lb,
-	insn_ld, insn_ldx, insn_lh, insn_ll, insn_lld, insn_lui, insn_lw,
-	insn_lwx, insn_mfc0, insn_mfhc0, insn_mfhi, insn_mflo, insn_mtc0,
-	insn_mthc0, insn_mthi, insn_mtlo, insn_mul, insn_or, insn_ori,
-	insn_pref, insn_rfe, insn_rotr, insn_sc, insn_scd, insn_sd, insn_sll,
-	insn_sllv, insn_slt, insn_sltiu, insn_sltu, insn_sra, insn_srl,
+	insn_beq, insn_beql, insn_bgez, insn_bgezl, insn_bgtz, insn_blez,
+	insn_bltz, insn_bltzl, insn_bne, insn_break, insn_cache, insn_cfc1,
+	insn_cfcmsa, insn_ctc1, insn_ctcmsa, insn_daddiu, insn_daddu, insn_ddivu,
+	insn_di, insn_dins, insn_dinsm, insn_dinsu, insn_divu, insn_dmfc0,
+	insn_dmtc0, insn_dmultu, insn_drotr, insn_drotr32, insn_dsbh, insn_dshd,
+	insn_dsll, insn_dsll32, insn_dsllv, insn_dsra, insn_dsra32, insn_dsrav,
+	insn_dsrl, insn_dsrl32, insn_dsrlv, insn_dsubu, insn_eret, insn_ext,
+	insn_ins, insn_j, insn_jal, insn_jalr, insn_jr, insn_lb, insn_lbu,
+	insn_ld, insn_lddir, insn_ldpte, insn_ldx, insn_lh, insn_lhu,
+	insn_ll, insn_lld, insn_lui, insn_lw, insn_lwu, insn_lwx, insn_mfc0,
+	insn_mfhc0, insn_mfhi, insn_mflo, insn_movn, insn_movz, insn_mtc0,
+	insn_mthc0, insn_mthi, insn_mtlo, insn_mul, insn_multu, insn_nor,
+	insn_or, insn_ori, insn_pref, insn_rfe, insn_rotr, insn_sb,
+	insn_sc, insn_scd, insn_sd, insn_sh, insn_sll, insn_sllv,
+	insn_slt, insn_slti, insn_sltiu, insn_sltu, insn_sra, insn_srl,
 	insn_srlv, insn_subu, insn_sw, insn_sync, insn_syscall, insn_tlbp,
 	insn_tlbr, insn_tlbwi, insn_tlbwr, insn_wait, insn_wsbh, insn_xor,
-	insn_xori, insn_yield, insn_lddir, insn_ldpte, insn_lhu,
+	insn_xori, insn_yield,
 	insn_invalid /* insn_invalid must be last */
 };
 
@@ -214,6 +218,13 @@ Ip_u2u1msbu3(op)					\
 }							\
 UASM_EXPORT_SYMBOL(uasm_i##op);
 
+#define I_u2u1msb32msb3(op)				\
+Ip_u2u1msbu3(op)					\
+{							\
+	build_insn(buf, insn##op, b, a, c+d-33, c-32);	\
+}							\
+UASM_EXPORT_SYMBOL(uasm_i##op);
+
 #define I_u2u1msbdu3(op)				\
 Ip_u2u1msbu3(op)					\
 {							\
@@ -264,25 +275,36 @@ I_u1u2s3(_beq)
 I_u1u2s3(_beql)
 I_u1s2(_bgez)
 I_u1s2(_bgezl)
+I_u1s2(_bgtz)
+I_u1s2(_blez)
 I_u1s2(_bltz)
 I_u1s2(_bltzl)
 I_u1u2s3(_bne)
+I_u1(_break)
 I_u2s3u1(_cache)
 I_u1u2(_cfc1)
 I_u2u1(_cfcmsa)
 I_u1u2(_ctc1)
 I_u2u1(_ctcmsa)
+I_u1u2(_ddivu)
 I_u1u2u3(_dmfc0)
 I_u1u2u3(_dmtc0)
+I_u1u2(_dmultu)
 I_u2u1s3(_daddiu)
 I_u3u1u2(_daddu)
 I_u1(_di);
 I_u1u2(_divu)
+I_u2u1(_dsbh);
+I_u2u1(_dshd);
 I_u2u1u3(_dsll)
 I_u2u1u3(_dsll32)
+I_u3u2u1(_dsllv)
 I_u2u1u3(_dsra)
+I_u2u1u3(_dsra32)
+I_u3u2u1(_dsrav)
 I_u2u1u3(_dsrl)
 I_u2u1u3(_dsrl32)
+I_u3u2u1(_dsrlv)
 I_u2u1u3(_drotr)
 I_u2u1u3(_drotr32)
 I_u3u1u2(_dsubu)
@@ -294,6 +316,7 @@ I_u1(_jal)
 I_u2u1(_jalr)
 I_u1(_jr)
 I_u2s3u1(_lb)
+I_u2s3u1(_lbu)
 I_u2s3u1(_ld)
 I_u2s3u1(_lh)
 I_u2s3u1(_lhu)
@@ -301,8 +324,11 @@ I_u2s3u1(_ll)
 I_u2s3u1(_lld)
 I_u1s2(_lui)
 I_u2s3u1(_lw)
+I_u2s3u1(_lwu)
 I_u1u2u3(_mfc0)
 I_u1u2u3(_mfhc0)
+I_u3u1u2(_movn)
+I_u3u1u2(_movz)
 I_u1(_mfhi)
 I_u1(_mflo)
 I_u1u2u3(_mtc0)
@@ -310,15 +336,20 @@ I_u1u2u3(_mthc0)
 I_u1(_mthi)
 I_u1(_mtlo)
 I_u3u1u2(_mul)
-I_u2u1u3(_ori)
+I_u1u2(_multu)
+I_u3u1u2(_nor)
 I_u3u1u2(_or)
+I_u2u1u3(_ori)
 I_0(_rfe)
+I_u2s3u1(_sb)
 I_u2s3u1(_sc)
 I_u2s3u1(_scd)
 I_u2s3u1(_sd)
+I_u2s3u1(_sh)
 I_u2u1u3(_sll)
 I_u3u2u1(_sllv)
 I_s3s1s2(_slt)
+I_u2u1s3(_slti)
 I_u2u1s3(_sltiu)
 I_u3u1u2(_sltu)
 I_u2u1u3(_sra)
@@ -339,6 +370,7 @@ I_u2u1u3(_xori)
 I_u2u1(_yield)
 I_u2u1msbu3(_dins);
 I_u2u1msb32u3(_dinsm);
+I_u2u1msb32msb3(_dinsu);
 I_u1(_syscall);
 I_u1u2s3(_bbit0);
 I_u1u2s3(_bbit1);
-- 
2.9.4
