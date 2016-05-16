From: "Shi, Yang" <yang.shi@linaro.org>
Subject: Re: [PATCH net-next] bpf: arm64: remove callee-save registers use for
 tmp registers
Date: Mon, 16 May 2016 16:47:41 -0700
Message-ID: <8d153729-f2c8-adc2-f10f-6f9a2318746c@linaro.org>
References: <1463440193-31934-1-git-send-email-yang.shi@linaro.org>
 <CABg9mcv8ekAxy98VZqq-Aev3rv3wx7UJDM++6AjOJqscJUN5NQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Z Lim <zlim.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34984 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbcEPXro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 19:47:44 -0400
Received: by mail-pf0-f177.google.com with SMTP id 77so72170018pfv.2
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 16:47:44 -0700 (PDT)
In-Reply-To: <CABg9mcv8ekAxy98VZqq-Aev3rv3wx7UJDM++6AjOJqscJUN5NQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/16/2016 4:45 PM, Z Lim wrote:
> Hi Yang,
>
> On Mon, May 16, 2016 at 4:09 PM, Yang Shi <yang.shi@linaro.org> wrote:
>> In the current implementation of ARM64 eBPF JIT, R23 and R24 are used for
>> tmp registers, which are callee-saved registers. This leads to variable size
>> of JIT prologue and epilogue. The latest blinding constant change prefers to
>> constant size of prologue and epilogue. AAPCS reserves R9 ~ R15 for temp
>> registers which not need to be saved/restored during function call. So, replace
>> R23 and R24 to R10 and R11, and remove tmp_used flag.
>>
>> CC: Zi Shen Lim <zlim.lnx@gmail.com>
>> CC: Daniel Borkmann <daniel@iogearbox.net>
>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>> ---
>
> Couple suggestions, but otherwise:
> Acked-by: Zi Shen Lim <zlim.lnx@gmail.com>
>
> 1. Update the diagram. I think it should now be:
>
> -        * BPF fp register => -80:+-----+ <= (BPF_FP)
> +        * BPF fp register => -64:+-----+ <= (BPF_FP)

Nice catch. I forgot the stack diagram.

>
> 2. Add a comment in commit log along the lines of: this is an
> optimization saving 2 instructions per jited BPF program.

Sure, will address in V2.

Thanks,
Yang

>
> Thanks :)
>
> z
>
>> Apply on top of Daniel's blinding constant patchset.
>>
>>  arch/arm64/net/bpf_jit_comp.c | 32 ++++----------------------------
>>  1 file changed, 4 insertions(+), 28 deletions(-)
>>
