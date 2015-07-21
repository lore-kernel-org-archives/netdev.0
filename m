From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH V2 net-next 2/3] ARM: net: add support for BPF_ANC | SKF_AD_PAY_OFFSET in ARM JIT.
Date: Tue, 21 Jul 2015 14:16:39 +0200
Message-ID: <1437481000-22835-3-git-send-email-nschichan@freebox.fr>
References: <1437481000-22835-1-git-send-email-nschichan@freebox.fr>
Cc: Russell King <linux@arm.linux.org.uk>,
	Alexei Starovoitov <ast@plumgrid.com>
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437481000-22835-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 arch/arm/net/bpf_jit_32.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 67a2d44..fe28beb 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -884,6 +884,14 @@ b_epilogue:
 			off = offsetof(struct sk_buff, queue_mapping);
 			emit(ARM_LDRH_I(r_A, r_skb, off), ctx);
 			break;
+		case BPF_ANC | SKF_AD_PAY_OFFSET:
+			ctx->seen |= SEEN_SKB | SEEN_CALL;
+
+			emit(ARM_MOV_R(ARM_R0, r_skb), ctx);
+			emit_mov_i(ARM_R3, (unsigned int)skb_get_poff, ctx);
+			emit_blx_r(ARM_R3, ctx);
+			emit(ARM_MOV_R(r_A, ARM_R0), ctx);
+			break;
 		case BPF_LDX | BPF_W | BPF_ABS:
 			/*
 			 * load a 32bit word from struct seccomp_data.
-- 
1.9.1
