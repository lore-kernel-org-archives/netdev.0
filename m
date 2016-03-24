From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 15:49:48 -0700
Message-ID: <1458859788.6473.2.camel@edumazet-glaptop3.roam.corp.google.com>
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
	 <CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, Willy Tarreau <w@1wt.eu>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Craig Gallek <cgallek@google.com>,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Yann Ylavic <ylavic.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35966 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbcCXWtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 18:49:51 -0400
Received: by mail-pa0-f44.google.com with SMTP id tt10so32980483pab.3
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 15:49:51 -0700 (PDT)
In-Reply-To: <CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-24 at 23:40 +0100, Yann Ylavic wrote:

> FWIW, I find:
> 
>     const struct bpf_insn prog[] = {
>         /* BPF_MOV64_REG(BPF_REG_6, BPF_REG_1) */
>         { BPF_ALU64 | BPF_MOV | BPF_X, BPF_REG_6, BPF_REG_1, 0, 0 },
>         /* BPF_LD_ABS(BPF_W, 0) R0 = (uint32_t)skb[0] */
>         { BPF_LD | BPF_ABS | BPF_W, 0, 0, 0, 0 },
>         /* BPF_ALU64_IMM(BPF_MOD, BPF_REG_0, mod) */
>         { BPF_ALU64 | BPF_MOD | BPF_K, BPF_REG_0, 0, 0, mod },
>         /* BPF_EXIT_INSN() */
>         { BPF_JMP | BPF_EXIT, 0, 0, 0, 0 }
>     };
> (and all the way to make it run)
> 
> something quite unintuitive from a web server developper perspective,
> simply to make SO_REUSEPORT work with forked TCP listeners (probably
> as it should out of the box)...


That is why EBPF has LLVM backend.

Basically you can write your "BPF" program in C, and let llvm convert it
into EBPF.

Sure, you still can write BPF manually, as you could write HTTPS server
in assembly.
