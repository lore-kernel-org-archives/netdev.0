From: David Daney <david.daney@cavium.com>
Subject: [PATCH v2 1/5] MIPS: uasm:  Add support for LHU.
Date: Tue, 14 Mar 2017 14:21:40 -0700
Message-ID: <20170314212144.29988-2-david.daney@cavium.com>
References: <20170314212144.29988-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>,
        David Daney <david.daney@cavium.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
        James Hogan <james.hogan@imgtec.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0055.outbound.protection.outlook.com ([104.47.41.55]:28802
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752101AbdCNVVy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 17:21:54 -0400
In-Reply-To: <20170314212144.29988-1-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The follow-on BPF JIT patches use the LHU instruction, so add it.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/include/asm/uasm.h | 1 +
 arch/mips/mm/uasm-mips.c     | 1 +
 arch/mips/mm/uasm.c          | 3 ++-
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/mips/include/asm/uasm.h b/arch/mips/include/asm/uasm.h
index f7929f6..d7e84f1 100644
--- a/arch/mips/include/asm/uasm.h
+++ b/arch/mips/include/asm/uasm.h
@@ -135,6 +135,7 @@ Ip_u2s3u1(_lb);
 Ip_u2s3u1(_ld);
 Ip_u3u1u2(_ldx);
 Ip_u2s3u1(_lh);
+Ip_u2s3u1(_lhu);
 Ip_u2s3u1(_ll);
 Ip_u2s3u1(_lld);
 Ip_u1s2(_lui);
diff --git a/arch/mips/mm/uasm-mips.c b/arch/mips/mm/uasm-mips.c
index 763d3f1..2277499 100644
--- a/arch/mips/mm/uasm-mips.c
+++ b/arch/mips/mm/uasm-mips.c
@@ -103,6 +103,7 @@ static struct insn insn_table[] = {
 	{ insn_ld,  M(ld_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
 	{ insn_ldx, M(spec3_op, 0, 0, 0, ldx_op, lx_op), RS | RT | RD },
 	{ insn_lh,  M(lh_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
+	{ insn_lhu,  M(lhu_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
 #ifndef CONFIG_CPU_MIPSR6
 	{ insn_lld,  M(lld_op, 0, 0, 0, 0, 0),	RS | RT | SIMM },
 	{ insn_ll,  M(ll_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
diff --git a/arch/mips/mm/uasm.c b/arch/mips/mm/uasm.c
index a829704..7f400c8 100644
--- a/arch/mips/mm/uasm.c
+++ b/arch/mips/mm/uasm.c
@@ -61,7 +61,7 @@ enum opcode {
 	insn_sllv, insn_slt, insn_sltiu, insn_sltu, insn_sra, insn_srl,
 	insn_srlv, insn_subu, insn_sw, insn_sync, insn_syscall, insn_tlbp,
 	insn_tlbr, insn_tlbwi, insn_tlbwr, insn_wait, insn_wsbh, insn_xor,
-	insn_xori, insn_yield, insn_lddir, insn_ldpte,
+	insn_xori, insn_yield, insn_lddir, insn_ldpte, insn_lhu,
 };
 
 struct insn {
@@ -297,6 +297,7 @@ I_u1(_jr)
 I_u2s3u1(_lb)
 I_u2s3u1(_ld)
 I_u2s3u1(_lh)
+I_u2s3u1(_lhu)
 I_u2s3u1(_ll)
 I_u2s3u1(_lld)
 I_u1s2(_lui)
-- 
2.9.3
