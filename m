From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [flamebait] xdp Was: Re: bpf bounded loops. Was: [flamebait] xdp
Date: Mon, 5 Dec 2016 22:04:59 -0800
Message-ID: <20161206060457.GA92032@ast-mbp.thefacebook.com>
References: <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
 <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
 <20161202183903.GC54949@ast-mbp.thefacebook.com>
 <2f3ce25c-3f59-9120-7d09-619be9b58e7a@stressinduktion.org>
 <1480707761.3858425.806609417.2E2C5E07@webmail.messagingengine.com>
 <20161202233430.GA58522@ast-mbp>
 <eee898ad-9a77-2987-c38d-984231139475@stressinduktion.org>
 <20161206030525.GA89307@ast-mbp.thefacebook.com>
 <CALx6S34zRN0MJOLR=xA9V936QtJ5FHzUHvQT9QK_383Eozu-CQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34191 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbcLFGFF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 01:05:05 -0500
Received: by mail-pf0-f195.google.com with SMTP id y68so18122498pfb.1
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 22:05:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALx6S34zRN0MJOLR=xA9V936QtJ5FHzUHvQT9QK_383Eozu-CQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 05, 2016 at 09:08:36PM -0800, Tom Herbert wrote:
> On Mon, Dec 5, 2016 at 7:05 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Sun, Dec 04, 2016 at 05:05:28PM +0100, Hannes Frederic Sowa wrote:
> >>
> >> If one of those eBPF verifiers only accepts a certain number of INSN, as
> >> fundamental as backwards jumps, we might end up with two compiler?
> >
> > two compilers? We already have five. There is gcc bpf backend (unmaintained)
> > and now lua, python and ply project can generate bpf code without llvm.
> > The kernel verifier has to become smarter. Right now it understands
> > only certain instruction patterns which caused all five bpf generators to
> > do extra work to satisfy the verifier. The solution is to do
> > data flow analysis using proper compiler techniques.
> >
> >> program thinks). Ergo, more complexity. What do you do when one of those
> >> two systems fail? What is the reference data? What do you do if on a
> >> highly busy box during DoS constant reloading of your vmalloc happens (I
> >> don't know if it is a problem under DoS)?
> >
> > ddos is one of the key use cases for xdp. If the system is about to oom
> > during ddos, it has to be fixed. The faster we move with xdp development
> > the sooner we will find and fix those issues.
> > And xdp being a core component of the linux kernel we will fix ddos
> > for the whole internet. Anyone going dpdk route are simply in
> > business of selling ddos protection with proprietary solutions.
> >
> Hi Alexei,
> 
> I am wondering exactly how XDP fixes DDOS in a non-proprietary
> fashion. While the XDP infrastructure is part of the core kernel, the
> programs are not part of the kernel as you mention below. So what will
> a DDOS solution based on XDP for the whole Internet look like? Do you
> envision a set of "blessed" DDOS programs that various sites can use
> and configure (maybe some maintained open source repository), or will
> each site need to come up with their own XDP programs for DDOS?

At some point we would need a repository of these 'blessed' programs.
Some of them will not be programs, but program generators
similar to existing Cloudflare bpf setup:
https://github.com/cloudflare/bpftools
and instead of doing things like:
https://github.com/cloudflare/lua-aho-corasick
and reimplementing them in proprietary c++,
the dfa/aho-corasick will be implemented as a kernel helper.
That's what I was alluding to in
https://github.com/iovisor/bcc/issues/471
Then all of the research in that area like:
https://ir.nctu.edu.tw/bitstream/11536/26033/1/000288319400006.pdf
will be applicable and researchers will be sharing
these detector programs.
Of course, not everyone will open up their secret sauce,
but a lot of folks will do and it will drive the innovation.
