From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: bpf debug info
Date: Tue, 13 Dec 2016 11:38:32 -0800
Message-ID: <CAADnVQKKjYDCqRGrB2UVKf=-KZBpt+5+M4nXXVuVefEGRv5MYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Thomas Graf <tgraf@suug.ch>, Wangnan <wangnan0@huawei.com>,
        He Kuang <hekuang@huawei.com>, Kernel Team <kernel-team@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35816 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932843AbcLMTwG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 14:52:06 -0500
Received: by mail-lf0-f68.google.com with SMTP id p100so4654626lfg.2
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 11:52:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 9:01 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
>> >If I try to run samples/bpf/test_cls_bpf.sh the verifier will complain:
>> >R0=imm0,min_value=0,max_value=0 R1=pkt(id=0,off=0,r=42) R2=pkt_end
>> >112: (0f) r4 += r3
>> >113: (0f) r1 += r4
>> >114: (b7) r0 = 2
>> >115: (69) r2 = *(u16 *)(r1 +2)
>> >invalid access to packet, off=2 size=2, R1(id=3,off=0,r=0)
>> >
>> >Now multiply 115 * 8 and convert to hex. This is address 0x398 in llvm-objdump:
>> >; struct udphdr *udp = data + tp_off;
>> >      388:       r1 += r4
>> >      390:       r0 = 2
>> >; if (udp->dest == htons(DEFAULT_PKTGEN_UDP_PORT) ||
>> >      398:       r2 = *(u16 *)(r1 + 2)
>> >      3a0:       if r2 == 2304 goto 16
>> >
>> >Now it's clear which line of C code is causing the verifier to reject.
>> [...]
>>
>> Could llvm-objdump switch line numbering for bpf same way as verifier
>> output, so mapping step is not really needed?
>
> you mean that llvm-objdump to print 113,114,115 ?
> I guess it's doable. Will give it a try.

Hi Daniel,

your feature request turned out to be pretty straightforward
to implement. Please pull the latest llvm and rebuild llvm-objdump.
It will be printing instruction numbers instead of absolute addresses.
No "multiply 115 * 8 and convert to hex" steps necessary anymore.

Thanks
