From: Yann Ylavic <ylavic.dev@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 23:40:30 +0100
Message-ID: <CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
References: <20151219070009.GA4634@1wt.eu>
	<CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
	<20151221204127.GC8018@1wt.eu>
	<CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
	<20160324061222.GA6807@1wt.eu>
	<1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160324142222.GB7237@1wt.eu>
	<1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160324153053.GA7569@1wt.eu>
	<1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160324165047.GA7585@1wt.eu>
	<1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALx6S36Ej1es8qFi2Q3=199f+rmG=Za02N5ZBWT5DCRqrBEWvQ@mail.gmail.com>
	<56F42A00.7050002@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Willy Tarreau <w@1wt.eu>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Craig Gallek <cgallek@google.com>,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:33984 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbcCXWkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 18:40:31 -0400
Received: by mail-qg0-f68.google.com with SMTP id j35so1704795qge.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 15:40:31 -0700 (PDT)
In-Reply-To: <56F42A00.7050002@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 6:55 PM, Daniel Borkmann wrote:
> On 03/24/2016 06:26 PM, Tom Herbert wrote:
>>
>> On Thu, Mar 24, 2016 at 10:01 AM, Eric Dumazet wrote:
>>>
>>> Really, when BPF can be the solution, we wont allow adding new stuff in
>>> the kernel in the old way.
>>
>> I completely agree with this, but I wonder if we now need a repository
>> of useful BPF modules. So in the case of implementing functionality
>> like in SO_REUSEPORT_LISTEN_OFF that might just become a common BPF
>> program we could direct people to use.
>
> Good point. There's tools/testing/selftests/net/ containing already
> reuseport
> BPF example, maybe it could be extended.

FWIW, I find:

    const struct bpf_insn prog[] = {
        /* BPF_MOV64_REG(BPF_REG_6, BPF_REG_1) */
        { BPF_ALU64 | BPF_MOV | BPF_X, BPF_REG_6, BPF_REG_1, 0, 0 },
        /* BPF_LD_ABS(BPF_W, 0) R0 = (uint32_t)skb[0] */
        { BPF_LD | BPF_ABS | BPF_W, 0, 0, 0, 0 },
        /* BPF_ALU64_IMM(BPF_MOD, BPF_REG_0, mod) */
        { BPF_ALU64 | BPF_MOD | BPF_K, BPF_REG_0, 0, 0, mod },
        /* BPF_EXIT_INSN() */
        { BPF_JMP | BPF_EXIT, 0, 0, 0, 0 }
    };
(and all the way to make it run)

something quite unintuitive from a web server developper perspective,
simply to make SO_REUSEPORT work with forked TCP listeners (probably
as it should out of the box)...

Regards,
Yann.
