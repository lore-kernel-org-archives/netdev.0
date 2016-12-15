From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, test_verifier: fix a test case error result on unprivileged
Date: Thu, 15 Dec 2016 01:39:10 +0100
Message-ID: <639d61f73c907b704001ed2b115208998990eb38.1481762158.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60842 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753048AbcLOAjV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 19:39:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running ./test_verifier as unprivileged lets 1 out of 98 tests fail:

  [...]
  #71 unpriv: check that printk is disallowed FAIL
  Unexpected error message!
  0: (7a) *(u64 *)(r10 -8) = 0
  1: (bf) r1 = r10
  2: (07) r1 += -8
  3: (b7) r2 = 8
  4: (bf) r3 = r1
  5: (85) call bpf_trace_printk#6
  unknown func bpf_trace_printk#6
  [...]

The test case is correct, just that the error outcome changed with
ebb676daa1a3 ("bpf: Print function name in addition to function id").
Same as with e00c7b216f34 ("bpf: fix multiple issues in selftest suite
and samples") issue 2), so just fix up the function name.

Fixes: ebb676daa1a3 ("bpf: Print function name in addition to function id")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/testing/selftests/bpf/test_verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 072dc63..853d7e4 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -1059,7 +1059,7 @@ struct test_val {
 			BPF_MOV64_IMM(BPF_REG_0, 0),
 			BPF_EXIT_INSN(),
 		},
-		.errstr_unpriv = "unknown func 6",
+		.errstr_unpriv = "unknown func bpf_trace_printk#6",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
 	},
-- 
1.9.3
