From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: fix liveness propagation to parent in spilled stack slots
Date: Thu, 17 Aug 2017 14:59:40 +0200
Message-ID: <058693b94f456324fd1a3d5946fa486e3a09ca06.1502974643.git.daniel@iogearbox.net>
Cc: ecree@solarflare.com, ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40438 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750988AbdHQM74 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 08:59:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using parent->regs[] when propagating REG_LIVE_READ for spilled regs
doesn't work since parent->regs[] denote the set of normal registers
but not spilled ones. Propagate to the correct regs.

Fixes: dc503a8ad984 ("bpf/verifier: track liveness for pruning")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Edward Cree <ecree@solarflare.com>
---
 kernel/bpf/verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 958ba84..40f669d 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3460,7 +3460,7 @@ static bool do_propagate_liveness(const struct bpf_verifier_state *state,
 		if (parent->spilled_regs[i].live & REG_LIVE_READ)
 			continue;
 		if (state->spilled_regs[i].live == REG_LIVE_READ) {
-			parent->regs[i].live |= REG_LIVE_READ;
+			parent->spilled_regs[i].live |= REG_LIVE_READ;
 			touched = true;
 		}
 	}
-- 
1.9.3
