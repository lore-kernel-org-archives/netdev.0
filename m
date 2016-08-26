From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFCv2 06/16] bpf: verifier: recognize rN ^ rN as load of 0
Date: Fri, 26 Aug 2016 19:06:05 +0100
Message-ID: <1472234775-29453-7-git-send-email-jakub.kicinski@netronome.com>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38641 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752270AbcHZSPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:15:38 -0400
Received: by mail-wm0-f47.google.com with SMTP id o80so3518571wme.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:14:47 -0700 (PDT)
In-Reply-To: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Teach the verifier to recognize that xoring a register with
itself makes it a constant (0).

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 kernel/bpf/verifier.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index db68a0e5db1e..0f4494c194f9 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1550,6 +1550,12 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 		verbose("invalid BPF_ALU opcode %x\n", opcode);
 		return -EINVAL;
 
+	} else if (opcode == BPF_XOR && BPF_SRC(insn->code) == BPF_X &&
+		   insn->src_reg == insn->dst_reg) {
+
+		regs[insn->dst_reg].type = CONST_IMM;
+		regs[insn->dst_reg].imm = 0;
+
 	} else {	/* all other ALU ops: and, sub, xor, add, ... */
 
 		if (BPF_SRC(insn->code) == BPF_X) {
-- 
1.9.1
