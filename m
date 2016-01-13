From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 18:24:16 -0800
Message-ID: <20160113022415.GA37041@ast-mbp.thefacebook.com>
References: <20160112185121.GA34045@ast-mbp.thefacebook.com>
 <1452626228-15742-1-git-send-email-rabin@rab.in>
 <1452628118.1223.25.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160112195356.GA34598@ast-mbp.thefacebook.com>
 <5695653F.6030001@iogearbox.net>
 <20160112204620.GA35080@ast-mbp.thefacebook.com>
 <1452641302.1223.35.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160112234707.GA36167@ast-mbp.thefacebook.com>
 <1452651098.1223.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Rabin Vincent <rabin@rab.in>, davem@davemloft.net,
	netdev@vger.kernel.org, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36051 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbcAMCYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 21:24:23 -0500
Received: by mail-pa0-f50.google.com with SMTP id yy13so256972229pab.3
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 18:24:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452651098.1223.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2016 at 06:11:38PM -0800, Eric Dumazet wrote:
> On Tue, 2016-01-12 at 15:47 -0800, Alexei Starovoitov wrote:
> 
> > I would agree if those loaded programs would do something sensible,
> > but they're broken. As shown arm and arm64 would execute them
> > differently without JIT, because HW treats such shifts differently.
> > I also checked that libpcap is sane and doesn't generate broken shifts.
> > imo we're not breaking backward compatiblity here.
> > 
> 
> How did you prove a particular code path was even taken in a BPF
> program ? This is new to me.

Simple. I only found absolute constants for shift instructions
in libpcap source.

> As I said, it is possible some guys never noticed their BPF program were
> 'broken' because this invalid shift was hidden in a dead code part.
> 
> So a program might appear as 'weak' when in fact its behavior was
> absolutely correct.
> 
> You assume everybody uses libpcap, this is wrong, and for very obvious
> reasons.

I didn't imply that.
Obviously there is chromium, libsecomp, lxd, dhclient, nmap and tons
of other apps. The point was for the library the most frequently
associated with classic bpf.

I think adding pr_err_once() to bpf_check_classic() as you
suggested makes the most sense to me at this point.
If anyone wants to submit a patch that masks K &= 31, I would ok with
it as well, but imo it's a disservice to classic bpf users.
Leaving it as-is and waiting for other jits to blow up is not an option.
