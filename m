From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/5] bpf: Do per-instruction state dumping in verifier when
 log_level > 1.
Date: Wed, 10 May 2017 15:09:47 -0400 (EDT)
Message-ID: <20170510.150947.1771591614496655880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42890 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754160AbdEJTJy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 15:09:54 -0400
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
index 56230ff..e1effce 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2932,8 +2932,12 @@ static int do_check(struct bpf_verifier_env *env)
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
2.1.2.532.g19b5d50
