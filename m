From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: bpf bounded loops. Was: [flamebait] xdp
Date: Fri, 2 Dec 2016 20:25:15 +0100
Message-ID: <2f3ce25c-3f59-9120-7d09-619be9b58e7a@stressinduktion.org>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain>
 <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
 <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
 <20161202183903.GC54949@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:50028 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751451AbcLBT0d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 14:26:33 -0500
In-Reply-To: <20161202183903.GC54949@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 02.12.2016 19:39, Alexei Starovoitov wrote:
> On Thu, Dec 01, 2016 at 10:27:12PM +0100, Hannes Frederic Sowa wrote:
>> like") and the problematic of parsing DNS packets in XDP due to string
>> processing and looping inside eBPF.
> 
> Hannes,
> Not too long ago you proposed a very interesting idea to add
> support for bounded loops without adding any new bpf instructions and
> changing llvm (which was way better than my 'rep' like instructions
> I was experimenting with). I thought systemtap guys also wanted bounded
> loops and you were cooperating on the design, so I gave up on my work and
> was expecting an imminent patch from you. I guess it sounds like you know
> believe that bounded loops are impossible or I misunderstand your statement ?

Your argument was that it would need a new verifier as the current first
pass checks that we indeed can lay out the basic blocks as a DAG which
the second pass depends on. This would be violated.

Because eBPF is available by non privileged users this would need a lot
of effort to rewrite and verify (or indeed keep two verifiers in the
kernel for priv and non-priv). The verifier itself is exposed to
unprivileged users.

Also, by design, if we keep the current limits, this would not give you
more instructions to operate on compared to the flattened version of the
program, it would merely reduce the numbers of optimizations in LLVM
that let the verifier reject the program.

Only enabling the relaxed verifier for root users seemed thus being
problematic as programs wouldn't be portable between nonprivileged and
privileged users.

> As far as pattern search for DNS packets...
> it was requested by Cloudflare guys back in March:
> https://github.com/iovisor/bcc/issues/471
> and it is useful for several tracing use cases as well.
> Unfortunately no one had time to implement it yet.

The string operations you proposed on the other hand, which would count
as one eBPF instructions, would give a lot more flexibility and allow
more cycles to burn, but don't help parsing binary protocols like IPv6
extension headers.

Bye,
Hannes
