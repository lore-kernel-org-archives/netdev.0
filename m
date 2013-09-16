From: Willy Tarreau <w@1wt.eu>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Mon, 16 Sep 2013 08:50:47 +0200
Message-ID: <20130916065047.GH27487@1wt.eu>
References: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com> <20130915205701.5c61a444@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ethan Tuttle <ethan@ethantuttle.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory =?iso-8859-1?Q?Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:39279 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971Ab3IPGvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 02:51:44 -0400
Content-Disposition: inline
In-Reply-To: <20130915205701.5c61a444@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On Sun, Sep 15, 2013 at 08:57:01PM +0200, Thomas Petazzoni wrote:
> Hello Ethan,
> 
> On Sat, 14 Sep 2013 18:05:32 -0700, Ethan Tuttle wrote:
> > When I upgraded my mirabox from 3.11-rc4 to 3.11, I started seeing
> > oopses while receiving network traffic (see below).  Sending a flood
> > ping will trigger the oops within a few minutes.
> > 
> > The stack looks similar, but not identical to, the one reported
> > earlier by Jochen De Smet[1].  In my case the PC is always
> > __rcu_read_lock.
> > 
> > A git bisect found a878764 "Merge
> > git://git.kernel.org/pub/scm/linux/kernel/git/davem/net" to be the
> > first bad commit... interesting, because neither of the merge parents
> > produce the oops.  I rebased the net changes onto the other merge
> > parent and bisected that series, which identified 702821f "net: revert
> > 8728c544a9c ("net: dev_pick_tx() fix")" as the first bad commit.
> > Indeed, reverting 702821f from 3.11 produces a kernel which stands up
> > to a ping flood for hours.
> > 
> > Each of the times I reproduced this, it was identified as "Unhandled
> > prefetch abort: unknown 25 (0x409) at 0xc0036ea0", except once when I
> > got "unknown 16 (0x400)".
> > 
> > I'm assuming this is an mvneta bug that was exposed by 702821f.
> > That's just a guess, and I don't have the skills to debug this any
> > further.  In any case, I figured the maintainers would want to know
> > about it.
> 
> Thanks a lot for the report and the detailed investigation.
> Unfortunately, I don't have Armada 370 hardware with me this week, so
> I'm unable to test and reproduce the issue.
> 
> However, I've added a bunch of Armada 370 people/maintainers in Cc,
> hopefully they can at least try to reproduce and confirm that reverting
> this patch makes the problem go away, which would confirm that we
> should look for a bug in the mvneta driver around this problem.

I'm currently testing on 3.11.1 (which I had here) and am not getting
any issue after 50M packets. My kernel is running in thumb mode and
without SMP.

Ethan, we'll need your config I guess.

Thanks,
Willy
