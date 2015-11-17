From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 2/2] arm64: bpf: make BPF prologue and epilogue
 align with ARM64 AAPCS
Date: Tue, 17 Nov 2015 14:44:58 -0500 (EST)
Message-ID: <20151117.144458.1305922349920062634.davem@davemloft.net>
References: <CABg9mcvomep=M1As_Vj=XuTNk=jiGwXQqQWbjotMXP2csKX=Bg@mail.gmail.com>
	<1447713335-29707-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, catalin.marinas@arm.com,
	will.deacon@arm.com, zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org
To: yang.shi@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447713335-29707-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yang Shi <yang.shi@linaro.org>
Date: Mon, 16 Nov 2015 14:35:35 -0800

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
 ...
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

Applied, thank you.
