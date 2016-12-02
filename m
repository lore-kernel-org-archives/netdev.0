From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: bpf bounded loops. Was: [flamebait] xdp
Date: Fri, 02 Dec 2016 20:42:41 +0100
Message-ID: <1480707761.3858425.806609417.2E2C5E07@webmail.messagingengine.com>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain>
 <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
 <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
 <20161202183903.GC54949@ast-mbp.thefacebook.com>
 <2f3ce25c-3f59-9120-7d09-619be9b58e7a@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:37718 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752264AbcLBTmw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 14:42:52 -0500
In-Reply-To: <2f3ce25c-3f59-9120-7d09-619be9b58e7a@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 2, 2016, at 20:25, Hannes Frederic Sowa wrote:
> On 02.12.2016 19:39, Alexei Starovoitov wrote:
> > On Thu, Dec 01, 2016 at 10:27:12PM +0100, Hannes Frederic Sowa wrote:
> >> like") and the problematic of parsing DNS packets in XDP due to string
> >> processing and looping inside eBPF.
> > 
> > Hannes,
> > Not too long ago you proposed a very interesting idea to add
> > support for bounded loops without adding any new bpf instructions and
> > changing llvm (which was way better than my 'rep' like instructions
> > I was experimenting with). I thought systemtap guys also wanted bounded
> > loops and you were cooperating on the design, so I gave up on my work and
> > was expecting an imminent patch from you. I guess it sounds like you know
> > believe that bounded loops are impossible or I misunderstand your statement ?
> 
> Your argument was that it would need a new verifier as the current first
> pass checks that we indeed can lay out the basic blocks as a DAG which
> the second pass depends on. This would be violated.
> 
> Because eBPF is available by non privileged users this would need a lot
> of effort to rewrite and verify (or indeed keep two verifiers in the
> kernel for priv and non-priv). The verifier itself is exposed to
> unprivileged users.
> 
> Also, by design, if we keep the current limits, this would not give you
> more instructions to operate on compared to the flattened version of the
> program, it would merely reduce the numbers of optimizations in LLVM
> that let the verifier reject the program.
> 
> Only enabling the relaxed verifier for root users seemed thus being
> problematic as programs wouldn't be portable between nonprivileged and
> privileged users.

Quick addendum:

The only solution to protect the verifier, which I saw, would be to
limit it by time and space, thus making loading of eBPF programs
depending on how fast and hot (thermal throttling) one CPU thread is.

Those are the complexity problems I am talking and concerned about.

Bye,
Hannes
