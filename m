From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH net-next 2/3] arm64: bpf: optimize JMP_CALL
Date: Sat,  4 Jun 2016 15:00:29 -0700
Message-ID: <1465077630-633-2-git-send-email-zlim.lnx@gmail.com>
References: <1465077630-633-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, Yang Shi <yang.shi@linaro.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465077630-633-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove superfluous stack frame, saving us 3 instructions for
every JMP_CALL.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/net/bpf_jit_comp.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 51abc97..7ae304e 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -578,11 +578,8 @@ emit_cond_jmp:
 		const u64 func = (u64)__bpf_call_base + imm;
 
 		emit_a64_mov_i64(tmp, func, ctx);
-		emit(A64_PUSH(A64_FP, A64_LR, A64_SP), ctx);
-		emit(A64_MOV(1, A64_FP, A64_SP), ctx);
 		emit(A64_BLR(tmp), ctx);
 		emit(A64_MOV(1, r0, A64_R(0)), ctx);
-		emit(A64_POP(A64_FP, A64_LR, A64_SP), ctx);
 		break;
 	}
 	/* tail call */
-- 
1.9.1
