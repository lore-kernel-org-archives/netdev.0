From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH V4 2/2] arm64: bpf: make BPF prologue and epilogue align
 with ARM64 AAPCS
Date: Mon, 16 Nov 2015 20:37:11 -0800
Message-ID: <CABg9mcvh+SLK-1iF28pCQgXt5WM_H4tH3ntgKSkMHCyMygThgw@mail.gmail.com>
References: <CABg9mcvomep=M1As_Vj=XuTNk=jiGwXQqQWbjotMXP2csKX=Bg@mail.gmail.com>
	<1447713335-29707-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: Yang Shi <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447713335-29707-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 16, 2015 at 2:35 PM, Yang Shi <yang.shi@linaro.org> wrote:
> Save and restore FP/LR in BPF prog prologue and epilogue, save SP to FP
> in prologue in order to get the correct stack backtrace.
>
> However, ARM64 JIT used FP (x29) as eBPF fp register, FP is subjected to
> change during function call so it may cause the BPF prog stack base address
> change too.
>
> Use x25 to replace FP as BPF stack base register (fp). Since x25 is callee
> saved register, so it will keep intact during function call.
> It is initialized in BPF prog prologue when BPF prog is started to run
> everytime. Save and restore x25/x26 in BPF prologue and epilogue to keep
> them intact for the outside of BPF. Actually, x26 is unnecessary, but SP
> requires 16 bytes alignment.
>
> So, the BPF stack layout looks like:
>
>                                  high
>          original A64_SP =>   0:+-----+ BPF prologue
>                                 |FP/LR|
>          current A64_FP =>  -16:+-----+
>                                 | ... | callee saved registers
>                                 +-----+
>                                 |     | x25/x26
>          BPF fp register => -80:+-----+
>                                 |     |
>                                 | ... | BPF prog stack
>                                 |     |
>                                 |     |
>          current A64_SP =>      +-----+
>                                 |     |
>                                 | ... | Function call stack
>                                 |     |
>                                 +-----+
>                                   low
>
> CC: Zi Shen Lim <zlim.lnx@gmail.com>
> CC: Xi Wang <xi.wang@gmail.com>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

Acked-by: Zi Shen Lim <zlim.lnx@gmail.com>
