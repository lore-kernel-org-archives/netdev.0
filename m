From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] bpf: Remove unused but set variables
Date: Tue,  8 Nov 2016 16:40:28 +0100
Message-ID: <20161108154028.13334-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Josef Bacik <jbacik@fb.com>
To: Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:45762 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753781AbcKHPkf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 10:40:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unused but set variables min_set and max_set in
adjust_reg_min_max_vals to fix the following warning when building with
'W=1':

  kernel/bpf/verifier.c:1483:7: warning: variable ‘min_set’ set but not used [-Wunused-but-set-variable]

There is no warning about max_set being unused, but since it is only
used in the assignment of min_set it can be removed as well.

They were introduced in commit 484611357c19 ("bpf: allow access into map
value arrays") but seem to have never been used.

Cc: Josef Bacik <jbacik@fb.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 kernel/bpf/verifier.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 846d7ceaf202..14345be4a2d2 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1480,7 +1480,6 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 {
 	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg;
 	u64 min_val = BPF_REGISTER_MIN_RANGE, max_val = BPF_REGISTER_MAX_RANGE;
-	bool min_set = false, max_set = false;
 	u8 opcode = BPF_OP(insn->code);
 
 	dst_reg = &regs[insn->dst_reg];
@@ -1503,7 +1502,6 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 	} else if (insn->imm < BPF_REGISTER_MAX_RANGE &&
 		   (s64)insn->imm > BPF_REGISTER_MIN_RANGE) {
 		min_val = max_val = insn->imm;
-		min_set = max_set = true;
 	}
 
 	/* We don't know anything about what was done to this register, mark it
-- 
2.9.0
