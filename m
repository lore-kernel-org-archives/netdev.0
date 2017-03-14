From: David Daney <david.daney@cavium.com>
Subject: [PATCH v2 3/5] MIPS: BPF: Use unsigned access for unsigned SKB fields.
Date: Tue, 14 Mar 2017 14:21:42 -0700
Message-ID: <20170314212144.29988-4-david.daney@cavium.com>
References: <20170314212144.29988-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>,
        David Daney <david.daney@cavium.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
        James Hogan <james.hogan@imgtec.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0055.outbound.protection.outlook.com ([104.47.41.55]:28802
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753150AbdCNVWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 17:22:09 -0400
In-Reply-To: <20170314212144.29988-1-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SKB vlan_tci and queue_mapping fields are unsigned, don't sign
extend these in the BPF JIT.  In the vlan_tci case, the value gets
masked so the change is not needed for correctness, but do it anyway
for agreement with the types defined in struct sk_buff.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/net/bpf_jit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 880e329..a68cd36 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1156,7 +1156,7 @@ static int build_body(struct jit_ctx *ctx)
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
 						  vlan_tci) != 2);
 			off = offsetof(struct sk_buff, vlan_tci);
-			emit_half_load(r_s0, r_skb, off, ctx);
+			emit_half_load_unsigned(r_s0, r_skb, off, ctx);
 			if (code == (BPF_ANC | SKF_AD_VLAN_TAG)) {
 				emit_andi(r_A, r_s0, (u16)~VLAN_TAG_PRESENT, ctx);
 			} else {
@@ -1183,7 +1183,7 @@ static int build_body(struct jit_ctx *ctx)
 			BUILD_BUG_ON(offsetof(struct sk_buff,
 					      queue_mapping) > 0xff);
 			off = offsetof(struct sk_buff, queue_mapping);
-			emit_half_load(r_A, r_skb, off, ctx);
+			emit_half_load_unsigned(r_A, r_skb, off, ctx);
 			break;
 		default:
 			pr_debug("%s: Unhandled opcode: 0x%02x\n", __FILE__,
-- 
2.9.3
