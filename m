From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/8] bpf: reset id on spilled regs in clear_all_pkt_pointers
Date: Sun, 11 Jun 2017 00:50:43 +0200
Message-ID: <e09fbd2f5e136107029efc7b301115b3d4c446f8.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57827 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751765AbdFJWu7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 18:50:59 -0400
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now, we don't reset the id of spilled registers in case of
clear_all_pkt_pointers(). Given pkt_pointers are highly likely to
contain an id, do so by reusing __mark_reg_unknown_value().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d195d82..519a614 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1346,8 +1346,8 @@ static void clear_all_pkt_pointers(struct bpf_verifier_env *env)
 		if (reg->type != PTR_TO_PACKET &&
 		    reg->type != PTR_TO_PACKET_END)
 			continue;
-		reg->type = UNKNOWN_VALUE;
-		reg->imm = 0;
+		__mark_reg_unknown_value(state->spilled_regs,
+					 i / BPF_REG_SIZE);
 	}
 }
 
-- 
1.9.3
