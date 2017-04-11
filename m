From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] bpf: reference may_access_skb() from __bpf_prog_run()
Date: Tue, 11 Apr 2017 12:10:58 +0200
Message-ID: <20170411101058.13526-1-johannes@sipsolutions.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49064 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754176AbdDKKLD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 06:11:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

It took me quite some time to figure out how this was linked,
so in order to save the next person the effort of finding it
add a comment in __bpf_prog_run() that indicates what exactly
determines that a program can access the ctx == skb.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 kernel/bpf/core.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index f45827e205d3..b4f1cb0c5ac7 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1162,12 +1162,12 @@ static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
 	LD_ABS_W: /* BPF_R0 = ntohl(*(u32 *) (skb->data + imm32)) */
 		off = IMM;
 load_word:
-		/* BPF_LD + BPD_ABS and BPF_LD + BPF_IND insns are
-		 * only appearing in the programs where ctx ==
-		 * skb. All programs keep 'ctx' in regs[BPF_REG_CTX]
-		 * == BPF_R6, bpf_convert_filter() saves it in BPF_R6,
-		 * internal BPF verifier will check that BPF_R6 ==
-		 * ctx.
+		/* BPF_LD + BPD_ABS and BPF_LD + BPF_IND insns are only
+		 * appearing in the programs where ctx == skb
+		 * (see may_access_skb() in the verifier). All programs
+		 * keep 'ctx' in regs[BPF_REG_CTX] == BPF_R6,
+		 * bpf_convert_filter() saves it in BPF_R6, internal BPF
+		 * verifier will check that BPF_R6 == ctx.
 		 *
 		 * BPF_ABS and BPF_IND are wrappers of function calls,
 		 * so they scratch BPF_R1-BPF_R5 registers, preserve
-- 
2.11.0
