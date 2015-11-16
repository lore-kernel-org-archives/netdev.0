From: "Shi, Yang" <yang.shi@linaro.org>
Subject: Re: [PATCH V3 2/2] arm64: bpf: make BPF prologue and epilogue align
 with ARM64 AAPCS
Date: Mon, 16 Nov 2015 11:48:57 -0800
Message-ID: <564A3329.1070504@linaro.org>
References: <CABg9mct-hnEhvT6y9ZgCC8nMan5YbmByQa_ViUWzeea6ToqG4A@mail.gmail.com>	<1447438197-31838-1-git-send-email-yang.shi@linaro.org> <CABg9mcvomep=M1As_Vj=XuTNk=jiGwXQqQWbjotMXP2csKX=Bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: Z Lim <zlim.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36588 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbbKPTs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:48:59 -0500
Received: by pacdm15 with SMTP id dm15so184522462pac.3
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 11:48:59 -0800 (PST)
In-Reply-To: <CABg9mcvomep=M1As_Vj=XuTNk=jiGwXQqQWbjotMXP2csKX=Bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2015 6:39 PM, Z Lim wrote:
> Yang, I noticed another thing...
>
> On Fri, Nov 13, 2015 at 10:09 AM, Yang Shi <yang.shi@linaro.org> wrote:
>> Save and restore FP/LR in BPF prog prologue and epilogue, save SP to FP
>> in prologue in order to get the correct stack backtrace.
>>
>> However, ARM64 JIT used FP (x29) as eBPF fp register, FP is subjected to
>> change during function call so it may cause the BPF prog stack base address
>> change too.
>>
>> Use x25 to replace FP as BPF stack base register (fp). Since x25 is callee
>> saved register, so it will keep intact during function call.
>
> Can you please add save/restore for x25 also? :)

Sure. BTW, since PUSH invokes stp instruction and SP need 16-bytes 
alignment, so we have to save x26 with x25 together. Anyway, it won't 
introduce any harm overhead since one instruction saves two registers.

Yang

>
>> It is initialized in BPF prog prologue when BPF prog is started to run
>> everytime. When BPF prog exits, it could be just tossed.
>>
