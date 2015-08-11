From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH net-next] bpf: fix the bug "'struct bpf_array' has no member named 'prog'" in s390 architecture
Date: Tue, 11 Aug 2015 05:00:24 +0000
Message-ID: <1439269224-13266-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<wangnan0@huawei.com>, <xiakaixu@huawei.com>
To: <fengguang.wu@intel.com>, <davem@davemloft.net>,
	<ast@plumgrid.com>, <schwidefsky@de.ibm.com>,
	<heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:33161 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbbHKFAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 01:00:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'Kbuild test robot' sent me an email about a build error
"'struct bpf_array' has no member named 'prog'" in s390
architecture. This error is caused by commit: 2a36f0b92eb
638dd023870574eb471b1c56be9ad [656/692] bpf: Make the bpf
_prog_array_map more generic. In this patch, the member 'prog'
of struct bpf_array has been replaced by 'ptrs'. So this
patch fix it.
---
 arch/s390/net/bpf_jit_comp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 9f4bbc0..eeda051 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -1032,7 +1032,7 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 				      MAX_TAIL_CALL_CNT, 0, 0x2);
 
 		/*
-		 * prog = array->prog[index];
+		 * prog = array->ptrs[index];
 		 * if (prog == NULL)
 		 *         goto out;
 		 */
@@ -1041,7 +1041,7 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 		EMIT6_DISP_LH(0xeb000000, 0x000d, REG_1, BPF_REG_3, REG_0, 3);
 		/* lg %r1,prog(%b2,%r1) */
 		EMIT6_DISP_LH(0xe3000000, 0x0004, REG_1, BPF_REG_2,
-			      REG_1, offsetof(struct bpf_array, prog));
+			      REG_1, offsetof(struct bpf_array, ptrs));
 		/* clgij %r1,0,0x8,label0 */
 		EMIT6_PCREL_IMM_LABEL(0xec000000, 0x007d, REG_1, 0, 0, 0x8);
 
-- 
1.8.3.4
