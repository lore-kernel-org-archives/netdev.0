From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH 1/2] arm64: bpf: fix JIT frame pointer setup
Date: Thu, 12 Nov 2015 13:57:00 -0800
Message-ID: <1447365421-1309-2-git-send-email-yang.shi@linaro.org>
References: <1447365421-1309-1-git-send-email-yang.shi@linaro.org>
Cc: zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org, yang.shi@linaro.org
To: ast@kernel.org, daniel@iogearbox.net, catalin.marinas@arm.com,
	will.deacon@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447365421-1309-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BPF fp should point to the top of the BPF prog stack. The original
implementation made it point to the bottom incorrectly.
Move A64_SP to fp before reserve BPF prog stack space.

CC: Zi Shen Lim <zlim.lnx@gmail.com>
CC: Xi Wang <xi.wang@gmail.com>
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/arm64/net/bpf_jit_comp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index a44e529..ac8b548 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -161,12 +161,12 @@ static void build_prologue(struct jit_ctx *ctx)
 	if (ctx->tmp_used)
 		emit(A64_PUSH(tmp1, tmp2, A64_SP), ctx);
 
-	/* Set up BPF stack */
-	emit(A64_SUB_I(1, A64_SP, A64_SP, stack_size), ctx);
-
 	/* Set up frame pointer */
 	emit(A64_MOV(1, fp, A64_SP), ctx);
 
+	/* Set up BPF stack */
+	emit(A64_SUB_I(1, A64_SP, A64_SP, stack_size), ctx);
+
 	/* Clear registers A and X */
 	emit_a64_mov_i64(ra, 0, ctx);
 	emit_a64_mov_i64(rx, 0, ctx);
-- 
2.0.2
