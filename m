From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net] bpf/verifier: reject invalid LD_ABS | BPF_DW instruction
Date: Tue, 12 Apr 2016 10:26:19 -0700
Message-ID: <1460481979-1771165-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:29656 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966106AbcDLR0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 13:26:23 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3CHPWLM010583
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 10:26:22 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2293q1rjsv-4
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 10:26:22 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 ab6001dc00d311e6aa5a0002c99293a0-6cfe53f0 for <netdev@vger.kernel.org>;	Tue,
 12 Apr 2016 10:26:19 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

verifier must check for reserved size bits in instruction opcode and
reject BPF_LD | BPF_ABS | BPF_DW and BPF_LD | BPF_IND | BPF_DW instructions,
otherwise interpreter will WARN_RATELIMIT on them during execution.

Fixes: ddd872bc3098 ("bpf: verifier: add checks for BPF_ABS | BPF_IND instructions")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2e08f8e9b771..618ef77c302a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1374,6 +1374,7 @@ static int check_ld_abs(struct verifier_env *env, struct bpf_insn *insn)
 	}
 
 	if (insn->dst_reg != BPF_REG_0 || insn->off != 0 ||
+	    BPF_SIZE(insn->code) == BPF_DW ||
 	    (mode == BPF_ABS && insn->src_reg != BPF_REG_0)) {
 		verbose("BPF_LD_ABS uses reserved fields\n");
 		return -EINVAL;
-- 
2.8.0
