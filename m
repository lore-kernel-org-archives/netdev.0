From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/8] bpf: reset id on CONST_IMM transition
Date: Sun, 11 Jun 2017 00:50:42 +0200
Message-ID: <2aa9be25d503638d576a1f37114de396518634f2.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57824 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751687AbdFJWu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 18:50:58 -0400
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever we set the register to the type CONST_IMM, we currently don't
reset the id to 0. id member is not used in CONST_IMM case, so don't
let it become stale, where pruning won't be able to match later on.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d031b3b..d195d82 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1952,6 +1952,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			 */
 			regs[insn->dst_reg].type = CONST_IMM;
 			regs[insn->dst_reg].imm = insn->imm;
+			regs[insn->dst_reg].id = 0;
 			regs[insn->dst_reg].max_value = insn->imm;
 			regs[insn->dst_reg].min_value = insn->imm;
 			regs[insn->dst_reg].min_align = calc_align(insn->imm);
@@ -2409,6 +2410,7 @@ static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
 
 		regs[insn->dst_reg].type = CONST_IMM;
 		regs[insn->dst_reg].imm = imm;
+		regs[insn->dst_reg].id = 0;
 		return 0;
 	}
 
-- 
1.9.3
