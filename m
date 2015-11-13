From: "Shi, Yang" <yang.shi@linaro.org>
Subject: Re: [PATCH 2/2] arm64: bpf: make BPF prologue and epilogue align
 with ARM64 AAPCS
Date: Fri, 13 Nov 2015 09:28:45 -0800
Message-ID: <56461DCD.4020701@linaro.org>
References: <1447365421-1309-1-git-send-email-yang.shi@linaro.org>	<1447365421-1309-3-git-send-email-yang.shi@linaro.org> <CABg9mctTj2M7Mw+bPgkDYtorW21uTuLxWnxLFucWPtM4TQ-7VA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>, daniel@iogearbox.net,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: Z Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABg9mctTj2M7Mw+bPgkDYtorW21uTuLxWnxLFucWPtM4TQ-7VA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/12/2015 7:28 PM, Z Lim wrote:
> On Thu, Nov 12, 2015 at 1:57 PM, Yang Shi <yang.shi@linaro.org> wrote:
>>
>> Save and restore FP/LR in BPF prog prologue and epilogue, save SP to FP
>> in prologue in order to get the correct stack backtrace.
>>
>> However, ARM64 JIT used FP (x29) as eBPF fp register, FP is subjected to
>> change during function call so it may cause the BPF prog stack base address
>> change too.
>>
>> Use x25 to replace FP as BPF stack base register (fp). Since x25 is callee
>> saved register, so it will keep intact during function call.
>> It is initialized in BPF prog prologue when BPF prog is started to run
>> everytime. When BPF prog exits, it could be just tossed.
>>
>> So, the BPF stack layout looks like:
>>
>>                                   high
>>           original A64_SP =>   0:+-----+ BPF prologue
>>                                  |     | FP/LR and callee saved registers
>>           BPF fp register => -64:+-----+
>>                                  |     |
>>                                  | ... | BPF prog stack
>>                                  |     |
>>                                  |     |
>>           current A64_SP/FP =>   +-----+
>>                                  |     |
>>                                  | ... | Function call stack
>>                                  |     |
>>                                  +-----+
>>                                    low
>>
>
> Yang, for stack unwinding to work, shouldn't it be something like the following?

Yes, thanks for catching this. v3 will be post soon.

Yang

>
>            | LR |
> A64_FP => | FP |
>            | .. |
>
