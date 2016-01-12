From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 15:47:09 -0800
Message-ID: <20160112234707.GA36167@ast-mbp.thefacebook.com>
References: <20160112185121.GA34045@ast-mbp.thefacebook.com>
 <1452626228-15742-1-git-send-email-rabin@rab.in>
 <1452628118.1223.25.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160112195356.GA34598@ast-mbp.thefacebook.com>
 <5695653F.6030001@iogearbox.net>
 <20160112204620.GA35080@ast-mbp.thefacebook.com>
 <1452641302.1223.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Rabin Vincent <rabin@rab.in>, davem@davemloft.net,
	netdev@vger.kernel.org, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34070 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbcALXrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 18:47:13 -0500
Received: by mail-pa0-f47.google.com with SMTP id uo6so331229526pac.1
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 15:47:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452641302.1223.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2016 at 03:28:22PM -0800, Eric Dumazet wrote:
> On Tue, 2016-01-12 at 12:46 -0800, Alexei Starovoitov wrote:
> > On Tue, Jan 12, 2016 at 09:42:39PM +0100, Daniel Borkmann wrote:
> 
> > > >yep and we all know who was able to code hundreds of cBPF insns by hand ;)
> > > >But I'm sure that code doesn't have such broken shifts. :)))
> > > 
> > > libpcap certainly supports raw filters now thanks to Chema [1]. Alternative
> > > could be to just mask them here, but not in eBPF verifier, but that would be
> > > even more inconsistent (on the other hand, we also allow holes in BPF but not
> > > in eBPF, so wouldn't be the first time we make things different), hmm.
> > 
> > I would rather see broken classic bpf program fixed instead of continue
> > running them with undefined behavior.
> 
> This is your choice, because you are a developer.
> 
> Some people might be stuck with old software they can not update,
> because they do not have the money to pay developers.
> 
> And no, I did not code BPF programs like that, but maybe others did, and
> I feel the pain of customers that might be stuck.
> 
> Linus Torvalds always made clear we must provide backward compatibility,
> and really this discussion should not even take place.
> 
> As I said, we used to load such BPF program in the past.
> 
> The fact that ARM64 crashes because of a faulty JIT implementation is
> not an excuse.

I would agree if those loaded programs would do something sensible,
but they're broken. As shown arm and arm64 would execute them
differently without JIT, because HW treats such shifts differently.
I also checked that libpcap is sane and doesn't generate broken shifts.
imo we're not breaking backward compatiblity here.
