From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH net-next 3/3] arm64: bpf: optimize LD_ABS, LD_IND
Date: Sat,  4 Jun 2016 15:00:30 -0700
Message-ID: <1465077630-633-3-git-send-email-zlim.lnx@gmail.com>
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

Remove superfluous stack frame, saving us 3 instructions for every
LD_ABS or LD_IND.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/net/bpf_jit_comp.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 7ae304e..b2fc97a 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -731,11 +731,8 @@ emit_cond_jmp:
 		emit_a64_mov_i64(r3, size, ctx);
 		emit(A64_SUB_I(1, r4, fp, STACK_SIZE), ctx);
 		emit_a64_mov_i64(r5, (unsigned long)bpf_load_pointer, ctx);
-		emit(A64_PUSH(A64_FP, A64_LR, A64_SP), ctx);
-		emit(A64_MOV(1, A64_FP, A64_SP), ctx);
 		emit(A64_BLR(r5), ctx);
 		emit(A64_MOV(1, r0, A64_R(0)), ctx);
-		emit(A64_POP(A64_FP, A64_LR, A64_SP), ctx);
 
 		jmp_offset = epilogue_offset(ctx);
 		check_imm19(jmp_offset);
-- 
1.9.1
