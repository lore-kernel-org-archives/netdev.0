From: dormando <dormando@rydia.net>
Subject: Re: kmem_cache_alloc panic in 3.10+
Date: Thu, 30 Jan 2014 19:52:39 -0800 (PST)
Message-ID: <alpine.DEB.2.10.1401301951060.5516@dinf>
References: <alpine.DEB.2.10.1401180036020.18419@dinf> <1390062576.31367.519.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.DEB.2.02.1401181101220.579@dtop> <alpine.DEB.2.02.1401292301070.5905@dtop> <1391134615.28432.83.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAADnVQ+vCikFY-te2U8wD+ustNW-o6Cqs8ye5ZfyNcU6vPQzNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([69.46.88.68]:60072 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753707AbaAaDwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jan 2014 22:52:45 -0500
In-Reply-To: <CAADnVQ+vCikFY-te2U8wD+ustNW-o6Cqs8ye5ZfyNcU6vPQzNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, Jan 30, 2014 at 6:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2014-01-29 at 23:05 -0800, dormando wrote:
> >
> >> We hit the routing code fairly hard. Any hints for what to look at or how
> >> to instrument it? Or if it's fixed already? It's a real pain to iterate
> >> since it takes ~30 days to crash, usually. Sometimes.
>
> sounds like adding mdelay() didn't help to crash it sooner. Then I don't
> see how my dst fix was causing it to crash more often. Something odd.
> fyi just to check it more thoroughly I've been running with mdelay()
> and config_slub_debug_on for a week without issues.

Sorry, I'm actually trying to deal with two separate crashes at once :/
One is this 3.10.15 one, and one was the regression in 3.10.23 - I haven't
had time to attempt the mdelay test yet. The two crashes have fairly
distinct traces.

For what it's worth though the machines I have with that one patch
reverted are still running fine.

> > I really wonder... it looks like a possible in SLUB. (might be already
> > fixed)
> >
> > Could you try using SLAB instead ?
>
> try config_slub_debug_on=y ? it should catch double free and other things.
>

Any slowdowns/issues with that?
