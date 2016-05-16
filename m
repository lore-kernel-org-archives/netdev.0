From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH net-next] bpf: arm64: remove callee-save registers use for
 tmp registers
Date: Mon, 16 May 2016 16:45:19 -0700
Message-ID: <CABg9mcv8ekAxy98VZqq-Aev3rv3wx7UJDM++6AjOJqscJUN5NQ@mail.gmail.com>
References: <1463440193-31934-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: Yang Shi <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463440193-31934-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yang,

On Mon, May 16, 2016 at 4:09 PM, Yang Shi <yang.shi@linaro.org> wrote:
> In the current implementation of ARM64 eBPF JIT, R23 and R24 are used for
> tmp registers, which are callee-saved registers. This leads to variable size
> of JIT prologue and epilogue. The latest blinding constant change prefers to
> constant size of prologue and epilogue. AAPCS reserves R9 ~ R15 for temp
> registers which not need to be saved/restored during function call. So, replace
> R23 and R24 to R10 and R11, and remove tmp_used flag.
>
> CC: Zi Shen Lim <zlim.lnx@gmail.com>
> CC: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---

Couple suggestions, but otherwise:
Acked-by: Zi Shen Lim <zlim.lnx@gmail.com>

1. Update the diagram. I think it should now be:

-        * BPF fp register => -80:+-----+ <= (BPF_FP)
+        * BPF fp register => -64:+-----+ <= (BPF_FP)

2. Add a comment in commit log along the lines of: this is an
optimization saving 2 instructions per jited BPF program.

Thanks :)

z

> Apply on top of Daniel's blinding constant patchset.
>
>  arch/arm64/net/bpf_jit_comp.c | 32 ++++----------------------------
>  1 file changed, 4 insertions(+), 28 deletions(-)
>
