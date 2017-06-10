From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/8] bpf: don't check spilled reg state for non-STACK_SPILLed type slots
Date: Sun, 11 Jun 2017 00:50:41 +0200
Message-ID: <edc83260e62b531a653c5c25605127972bb8693c.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57821 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751666AbdFJWu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 18:50:58 -0400
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

spilled_regs[] state is only used for stack slots of type STACK_SPILL,
never for STACK_MISC. Right now, in states_equal(), even if we have
old and current stack state of type STACK_MISC, we compare spilled_regs[]
for that particular offset. Just skip these like we do everywhere else.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 14ccb07..d031b3b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2828,6 +2828,8 @@ static bool states_equal(struct bpf_verifier_env *env,
 			return false;
 		if (i % BPF_REG_SIZE)
 			continue;
+		if (old->stack_slot_type[i] != STACK_SPILL)
+			continue;
 		if (memcmp(&old->spilled_regs[i / BPF_REG_SIZE],
 			   &cur->spilled_regs[i / BPF_REG_SIZE],
 			   sizeof(old->spilled_regs[0])))
-- 
1.9.3
