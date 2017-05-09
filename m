From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Tue, 09 May 2017 22:25:59 +0200
Message-ID: <591225D7.9090500@iogearbox.net>
References: <CAHgaXd+EKJ0FWaaPojsNJtgY_YpdQXu6eMEp97uOpTFAWs4qTQ@mail.gmail.com> <CAGXu5jLo8UvpNSQZBHjWZoO959ha6KFQxFzmg7SK44wz=R_QSg@mail.gmail.com> <CAHgaXdJL92XRjHae2Nb9j9SerSe65=N=ErDHTQf23sdBxwthzw@mail.gmail.com> <20170315.145512.1542025976162251828.davem@davemloft.net> <CAHgaXd+4QkFxnt-_iCqH8AyCN_Y8gXwr+y=iugz38NKSWspsbA@mail.gmail.com> <58DAF908.8010404@iogearbox.net> <CAHgaXdKfbob3WHMho32JSh_dmfp2A=cjcePqk+NfajVpShPE6Q@mail.gmail.com> <CAHgaXdJ1M4W3p9=B2hJmtxByPsA5-XHae8U6YtDH_2r_XMaR5A@mail.gmail.com> <58E639E0.1010700@iogearbox.net> <CAHgaXd+xb5dN90sH___RtxgSC3usnH2jXkA5r3=fQJc3pOY5xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Kees Cook <keescook@chromium.org>,
        Mircea Gherzan <mgherzan@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        linux-arm-kernel@lists.infradead.org, ast@fb.com
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36516 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdEIU0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 16:26:06 -0400
In-Reply-To: <CAHgaXd+xb5dN90sH___RtxgSC3usnH2jXkA5r3=fQJc3pOY5xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2017 10:12 PM, Shubham Bansal wrote:
> Hi Daniel,
>
> I just tried running test_bpf.ko module.
>
> $ echo 2 >>  /proc/sys/net/core/bpf_jit_enable
> $ insmod test_bpf.ko
>
> test_bpf: #0 TAX
> bpf_jit: flen=14 proglen=212 pass=2 image=7f15a83c from=insmod pid=730
> JIT code: 00000000: f0 05 2d e9 40 d2 4d e2 00 40 a0 e3 0c 42 8d e5
> JIT code: 00000010: 08 42 8d e5 00 00 20 e0 01 10 21 e0 20 62 9d e5
> JIT code: 00000020: 20 72 9d e5 06 70 27 e0 20 72 8d e5 24 62 9d e5
> JIT code: 00000030: 24 72 9d e5 06 70 27 e0 24 72 8d e5 00 40 a0 e1
> JIT code: 00000040: 01 50 a0 e1 01 00 a0 e3 00 10 a0 e3 20 02 8d e5
> JIT code: 00000050: 24 12 8d e5 02 00 a0 e3 00 10 a0 e3 20 62 9d e5
> JIT code: 00000060: 06 00 80 e0 00 10 a0 e3 00 00 60 e2 00 10 a0 e3
> JIT code: 00000070: 20 02 8d e5 24 12 8d e5 54 40 90 e5 20 62 9d e5
> JIT code: 00000080: 06 00 80 e0 00 10 a0 e3 20 02 8d e5 24 12 8d e5
> JIT code: 00000090: 04 00 a0 e1 01 10 a0 e3 20 62 9d e5 06 10 81 e0
> JIT code: 000000a0: 01 20 a0 e3 04 32 8d e2 bc 68 0a e3 11 60 48 e3
> JIT code: 000000b0: 36 ff 2f e1 01 10 21 e0 00 00 50 e3 04 00 00 0a
> JIT code: 000000c0: 00 00 d0 e5 01 00 00 ea 40 d2 8d e2 f0 05 bd e8
> JIT code: 000000d0: 1e ff 2f e1
> jited:1
> Unhandled fault: page domain fault (0x01b) at 0x00000051
> pgd = 871d0000
> [00000051] *pgd=671b7831, *pte=00000000, *ppte=00000000
> Internal error: : 1b [#1] SMP ARM
> Modules linked in: test_bpf(+)
> CPU: 0 PID: 730 Comm: insmod Not tainted 4.11.0+ #5
> Hardware name: ARM-Versatile Express
> task: 87023700 task.stack: 8718a000
> PC is at 0x7f15a8b4
> LR is at test_bpf_init+0x5bc/0x1000 [test_bpf]
> pc : [<7f15a8b4>]    lr : [<7f1575bc>]    psr: 80000013
> sp : 8718bd7c  ip : 00000015  fp : 7f005008
> r10: 7f005094  r9 : 893ba020  r8 : 893ba000
> r7 : 00000000  r6 : 00000001  r5 : 00000000  r4 : 00000000
> r3 : 7f15a83c  r2 : 893ba020  r1 : 00000000  r0 : fffffffd
> Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
> Control: 10c5387d  Table: 671d0059  DAC: 00000051
> Process insmod (pid: 730, stack limit = 0x8718a210)
> Stack: (0x8718bd7c to 0x8718c000)
> bd60:                                                                00000000
> bd80: 00002710 870db300 c302e7e8 7f004010 893ba000 7f005094 00000000 00000000
> bda0: 00000000 00000000 00000000 00000001 00000001 00000000 014000c0 00150628
> bdc0: 7f0050ac 7f154840 1234aaaa 1234aaab c302e7e8 0000000f 00000000 893ba000
> bde0: 0000000b 7f004010 87fd54a0 ffffe000 7f157000 00000000 871b6fc0 00000001
> be00: 78e4905c 00000024 7f154640 8010179c 80a06544 8718a000 00000001 80a54980
> be20: 80a3066c 00000007 809685c0 80a54700 80a54700 07551000 80a54700 60070013
> be40: 7f154640 801f3fc8 78e4905c 7f154640 00000001 871b6fe4 7f154640 00000001
> be60: 871b6b00 00000001 78e4905c 801eaa94 00000001 871b6fe4 8718bf44 00000001
> be80: 871b6fe4 80196e4c 7f15464c 00007fff 7f154640 80193f10 87127000 7f154640
> bea0: 7f154688 80703800 7f154770 807037e4 8081b184 807bec60 807becc4 807bec6c
> bec0: 7f15481c 8010c1b8 93600000 76ed8028 00000f60 00000000 00000000 00000000
> bee0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> bf00: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00003f80
> bf20: 76f5cf88 00000000 93684f80 8718a000 00160fda 00000051 00000000 801973b0
> bf40: 87671a00 93501000 00183f80 93684760 93684574 936788e0 00155000 00155290
> bf60: 00000000 00000000 00000000 00001f64 00000032 00000033 0000001d 00000000
> bf80: 00000017 00000000 00000000 00183f80 756e694c 00000080 80107684 fffffffd
> bfa0: 00000000 801074c0 00000000 00183f80 76dd9008 00183f80 00160fda 00000000
> bfc0: 00000000 00183f80 756e694c 00000080 00000001 7eabae2c 00172f8c 00000000
> bfe0: 7eabaae0 7eabaad0 0004017f 00013172 60070030 76dd9008 00000000 00000000
> [<7f1575bc>] (test_bpf_init [test_bpf]) from [<7f157000>]
> (test_bpf_init+0x0/0x1000 [test_bpf])
> [<7f157000>] (test_bpf_init [test_bpf]) from [<78e4905c>] (0x78e4905c)
> Code: e2600000 e3a01000 e58d0220 e58d1224 (e5904054)
> ---[ end trace a36398923b914fe2 ]---
> Segmentation fault
>
> Why is trying to execute TAX which is a cBPF instruction?

Kernel translates this to eBPF internally (bpf_prepare_filter() ->
bpf_migrate_filter()), no cBPF will see the JIT directly.

Is your implementation still using bpf_jit_compile() callback as
opposed to bpf_int_jit_compile()?!

Cheers,
Daniel
