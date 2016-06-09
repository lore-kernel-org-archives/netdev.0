From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH net-next v3 3/4] arm64: bpf: optimize JMP_CALL
Date: Wed,  8 Jun 2016 21:18:49 -0700
Message-ID: <1465445930-3960-4-git-send-email-zlim.lnx@gmail.com>
References: <1465445930-3960-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Yang Shi <yang.shi@linaro.org>, Daniel Borkmann <daniel@iogearbox.net>,
 Zi Shen Lim <zlim.lnx@gmail.com>, Alexei Starovoitov <ast@kernel.org>,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1465445930-3960-1-git-send-email-zlim.lnx@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
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
