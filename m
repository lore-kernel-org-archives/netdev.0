From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 3/5] bpf: fix up test cases with mixed signed/unsigned bounds
Date: Fri, 21 Jul 2017 00:00:23 +0200
Message-ID: <f52713443d326b828e0352844df07c1c2561e1f9.1500586732.git.daniel@iogearbox.net>
References: <cover.1500586732.git.daniel@iogearbox.net>
Cc: ast@fb.com, ecree@solarflare.com, josef@toxicpanda.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45855 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964776AbdGTWEF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 18:04:05 -0400
In-Reply-To: <cover.1500586732.git.daniel@iogearbox.net>
In-Reply-To: <cover.1500586732.git.daniel@iogearbox.net>
References: <cover.1500586732.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the few existing test cases that used mixed signed/unsigned
bounds and switch them only to one flavor. Reason why we need this
is that proper boundaries cannot be derived from mixed tests.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/test_verifier.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index f4d0a1d..64b39d3 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -4969,7 +4969,7 @@ struct test_val {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val), 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -4995,7 +4995,7 @@ struct test_val {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val) + 1, 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -5023,7 +5023,7 @@ struct test_val {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val) - 20, 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -5050,7 +5050,7 @@ struct test_val {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val) - 19, 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
-- 
1.9.3
