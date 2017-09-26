From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v2 net-next 2/2] bpf/verifier: improve disassembly of BPF_NEG
 instructions
Date: Tue, 26 Sep 2017 16:35:29 +0100
Message-ID: <f27b1dfe-4ea2-5737-d3d5-21cb581d1927@solarflare.com>
References: <52270348-67f1-4e7a-cd2f-9d611ae94064@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <daniel@iogearbox.net>,
        <alexei.starovoitov@gmail.com>, <ys114321@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:37862 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1031425AbdIZPfj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 11:35:39 -0400
In-Reply-To: <52270348-67f1-4e7a-cd2f-9d611ae94064@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF_NEG takes only one operand, unlike the bulk of BPF_ALU[64] which are
 compound-assignments.  So give it its own format in print_bpf_insn().

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 kernel/bpf/verifier.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 3aaa3262..04e0508 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -344,6 +344,11 @@ static void print_bpf_insn(const struct bpf_verifier_env *env,
 				verbose("BUG_alu64_%02x\n", insn->code);
 			else
 				print_bpf_end_insn(env, insn);
+		} else if (BPF_OP(insn->code) == BPF_NEG) {
+			verbose("(%02x) r%d = %s-r%d\n",
+				insn->code, insn->dst_reg,
+				class == BPF_ALU ? "(u32) " : "",
+				insn->dst_reg);
 		} else if (BPF_SRC(insn->code) == BPF_X) {
 			verbose("(%02x) %sr%d %s %sr%d\n",
 				insn->code, class == BPF_ALU ? "(u32) " : "",
