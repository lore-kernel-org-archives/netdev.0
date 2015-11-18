From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH] arm64: bpf: fix buffer pointer
Date: Wed, 18 Nov 2015 13:41:40 -0800
Message-ID: <CABg9mcud=quxDbAGwXo0CyHjDa4aOL_yuk9hwRp1asu-z+fOAQ@mail.gmail.com>
References: <1447836962-4086-1-git-send-email-zlim.lnx@gmail.com>
	<564CE886.5010109@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Network Development <netdev@vger.kernel.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564CE886.5010109@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 18, 2015 at 1:07 PM, Shi, Yang <yang.shi@linaro.org> wrote:
> On 11/18/2015 12:56 AM, Zi Shen Lim wrote:
>>                 emit_a64_mov_i64(r3, size, ctx);
>> -               emit(A64_ADD_I(1, r4, fp, MAX_BPF_STACK), ctx);
>> +               emit(A64_SUB_I(1, r4, fp, STACK_SIZE), ctx);
>
>
> Should not it sub MAX_BPF_STACK?

No, if it's at (BPF_FP - MAX_BPF_STACK), we'll be writing into the BPF
stack area, which should only be used by the BPF program.

> If you sub STACK_SIZE here, the buffer pointer will point to bottom of the
> reserved area.

Yes, that's the idea. The buffer is allocated in here. Right now we're
using this "reserved" space for this buffer only.

>
> You stack layout change also shows this:
>
> +        *                        +-----+ <= (BPF_FP - MAX_BPF_STACK)
> +        *                        |RSVD | JIT scratchpad
> +        * current A64_SP =>      +-----+ <= (BPF_FP - STACK_SIZE)

Yes, this diagram reflects the code and intention.


Thanks for reviewing, we definitely need more of these :)
