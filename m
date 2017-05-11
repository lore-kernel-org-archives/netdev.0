From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 2/7] bpf: Do per-instruction state dumping in verifier
 when log_level > 1.
Date: Thu, 11 May 2017 12:05:29 -0400 (EDT)
Message-ID: <20170511.120529.492579439081538459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51542 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933695AbdEKQFg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:05:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If log_level > 1, do a state dump every instruction and emit it in
a more compact way (without a leading newline).

This will facilitate more sophisticated test cases which inspect the
verifier log for register state.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 kernel/bpf/verifier.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index cc7b626..ff2bfe1 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2926,8 +2926,12 @@ static int do_check(struct bpf_verifier_env *env)
 			goto process_bpf_exit;
 		}
 
-		if (log_level && do_print_state) {
-			verbose("\nfrom %d to %d:", prev_insn_idx, insn_idx);
+		if (log_level > 1 || (log_level && do_print_state)) {
+			if (log_level > 1)
+				verbose("%d:", insn_idx);
+			else
+				verbose("\nfrom %d to %d:",
+					prev_insn_idx, insn_idx);
 			print_verifier_state(&env->cur_state);
 			do_print_state = false;
 		}
-- 
2.7.4
