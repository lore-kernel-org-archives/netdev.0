From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Mon, 22 May 2017 15:01:16 +0200
Message-ID: <5922E11C.4070307@iogearbox.net>
References: <CAHgaXdKsO2xoKYp7g91g+n+d_1KHSSByLjzBB-WjVXSjhB7qxw@mail.gmail.com> <20170510.212952.1440495072777358778.davem@davemloft.net> <CAHgaXdK8LEEUPm4jTRRzCnjwdWAauHmmB=caZsSFY8MmStH89Q@mail.gmail.com> <20170510.215218.2185526627014393313.davem@davemloft.net> <CAHgaXdKZ_v+iO7uqEDx7PA7D+xcp1FngGvJ1SRSsGXNQ-iWWDQ@mail.gmail.com> <CAHgaXdLJoVUXXGTYs7FYXay5wx=sA-O+=dYhX+r7AQT7vSNfGQ@mail.gmail.com> <CAGXu5j+2q4Wwfhuk_DnDaV894A9ZOD=A_AvAU_OZG6KQv0_KMg@mail.gmail.com> <CAHgaXdL7GcVzs+ANPke_NywhcgHbe_fzi1sTDEy+Ni1-o82GYQ@mail.gmail.com> <591A07A1.1030006@iogearbox.net> <CAHgaXdKKbRVSpX-036TXpV5z=1=QCnPoku0+CeHxHco8-aasPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
        David Miller <davem@davemloft.net>,
        Mircea Gherzan <mgherzan@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>, ast@fb.com
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33660 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdEVNBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 09:01:32 -0400
In-Reply-To: <CAHgaXdKKbRVSpX-036TXpV5z=1=QCnPoku0+CeHxHco8-aasPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2017 10:01 PM, Shubham Bansal wrote:
[...]
> Before I send the patch, I have tested the JIT compiler on ARMv7 but
> not on ARMv5 or ARMv6. So can you tell me which arch versions I should
> test it for?
> Also for my testing, CONFIG_FRAME_POINTER and CONFIG_CPU_BIG_ENDIAN
> are both disabled. But I need to test JIT with these flags as well.
> Whenever I put these flags in .config file, the arm kernel is not
> getting compiler with these flags. Can you tell me why? If you need
> more information regarding this, please let me know.

Maybe Mircea, Kees or someone from linux-arm-kernel can help you out
on that.

With regards to the below benchmark, I was mentioning how it compares
to the interpreter. With only the numbers for jit it's hard to compare.
So would be great to see the output for the following three cases:

1) Interpreter:

echo 0 > /proc/sys/net/core/bpf_jit_enable

2) JIT enabled:

echo 1 > /proc/sys/net/core/bpf_jit_enable

3) JIT + blinding enabled:

echo 1 > /proc/sys/net/core/bpf_jit_enable
echo 2 > /proc/sys/net/core/bpf_jit_harden

> With current config for ARMv7, benchmarks are :
>
> [root@vexpress modules]# insmod test_bpf.ko
> [   25.797766] test_bpf: #0 TAX jited:1 180 170 169 PASS
> [   25.811395] test_bpf: #1 TXA jited:1 93 89 111 PASS
> [   25.815073] test_bpf: #2 ADD_SUB_MUL_K jited:1 94 PASS
> [   25.816779] test_bpf: #3 DIV_MOD_KX jited:1 983 PASS
> [   25.827310] test_bpf: #4 AND_OR_LSH_K jited:1 94 93 PASS
> [   25.829843] test_bpf: #5 LD_IMM_0 jited:1 83 PASS
> [   25.831260] test_bpf: #6 LD_IND jited:1 338 266 305 PASS
[...]

Thanks,
Daniel
