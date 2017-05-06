From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Sun, 7 May 2017 03:47:08 +0530
Message-ID: <CAHgaXdLsUYEmY86Nz3rC50repRA_rz-CVYx_i90k1Q5G1E-mCw@mail.gmail.com>
References: <CAHgaXdJ1M4W3p9=B2hJmtxByPsA5-XHae8U6YtDH_2r_XMaR5A@mail.gmail.com>
 <58E639E0.1010700@iogearbox.net> <CAHgaXdK1XjDnhTqtk=nCq2crrigHiuCaLhF+1GupJt9bPThwZw@mail.gmail.com>
 <20170506.143816.2259768618578706384.davem@davemloft.net> <CAHgaXd+2vF=d5zpWTg+a=vSnv2ZA+8LCR_MXT_MDKn4r2s8sig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Kees Cook <keescook@chromium.org>,
        Mircea Gherzan <mgherzan@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        linux-arm-kernel@lists.infradead.org, ast@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34544 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753442AbdEFWRJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 18:17:09 -0400
Received: by mail-oi0-f51.google.com with SMTP id b204so19065931oii.1
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 15:17:09 -0700 (PDT)
In-Reply-To: <CAHgaXd+2vF=d5zpWTg+a=vSnv2ZA+8LCR_MXT_MDKn4r2s8sig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Okay. My mistake. I just checked the verify function.

Apologies.
Best,
Shubham Bansal


On Sun, May 7, 2017 at 1:57 AM, Shubham Bansal
<illusionist.neo@gmail.com> wrote:
> Thanks David.
>
> Hi all,
>
> I have two questions about the code at arch/arm64/net/bpf_jit_comp.c.
>
> 1. At line 708, " const u8 r1 = bpf2a64[BPF_REG_1]; /* r1: struct
> sk_buff *skb */ ".
>     Why is this code using BPF_REG_1 before saving it? As far as I
> know, BPF_REG_1 has pointer to bpf program context and this code
> clearly is overwriting that pointer which makes that pointer useless
> for future usage. It clearly looks like a bug.
>
> 2. At line 256, " emit(A64_LDR64(prg, tmp, r3), ctx); ".
>     This line of code is used to load an array( of pointers ) element,
> where r3 is used as an index of that array. Shouldn't it be be
> arithmetic left shifted by 3 or multiplied by 8 to get the right
> address in that array of pointers ?
>
> Apologies if any of the above question is stupid to ask.
>
> Best,
> Shubham
> Best,
> Shubham Bansal
>
>
> On Sun, May 7, 2017 at 12:08 AM, David Miller <davem@davemloft.net> wrote:
>> From: Shubham Bansal <illusionist.neo@gmail.com>
>> Date: Sat, 6 May 2017 22:18:16 +0530
>>
>>> Hi Daniel,
>>>
>>> Thanks for the last reply about the testing of eBPF JIT.
>>>
>>> I have one issue though, I am not able to find what BPF_ABS and
>>> BPF_IND instruction does exactly.
>>
>> They are not instructions, they are modifiers for the BPF_LD
>> instruction which indicate an SKB load is to be performed.
>>
>> You never need to ask what a BPF instruction does, it is clear
>> defined in the BPF interperter found in kernel/bpf/core.c
>>
>> Look for the case statement LD_ABS_W and friends in __bpf_prog_run().
