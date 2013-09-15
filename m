From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Sun, 15 Sep 2013 20:57:01 +0200
Message-ID: <20130915205701.5c61a444@skate>
References: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>
To: Ethan Tuttle <ethan@ethantuttle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:52815 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751978Ab3IOS5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 14:57:11 -0400
In-Reply-To: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ethan,

On Sat, 14 Sep 2013 18:05:32 -0700, Ethan Tuttle wrote:
> When I upgraded my mirabox from 3.11-rc4 to 3.11, I started seeing
> oopses while receiving network traffic (see below).  Sending a flood
> ping will trigger the oops within a few minutes.
> 
> The stack looks similar, but not identical to, the one reported
> earlier by Jochen De Smet[1].  In my case the PC is always
> __rcu_read_lock.
> 
> A git bisect found a878764 "Merge
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net" to be the
> first bad commit... interesting, because neither of the merge parents
> produce the oops.  I rebased the net changes onto the other merge
> parent and bisected that series, which identified 702821f "net: revert
> 8728c544a9c ("net: dev_pick_tx() fix")" as the first bad commit.
> Indeed, reverting 702821f from 3.11 produces a kernel which stands up
> to a ping flood for hours.
> 
> Each of the times I reproduced this, it was identified as "Unhandled
> prefetch abort: unknown 25 (0x409) at 0xc0036ea0", except once when I
> got "unknown 16 (0x400)".
> 
> I'm assuming this is an mvneta bug that was exposed by 702821f.
> That's just a guess, and I don't have the skills to debug this any
> further.  In any case, I figured the maintainers would want to know
> about it.

Thanks a lot for the report and the detailed investigation.
Unfortunately, I don't have Armada 370 hardware with me this week, so
I'm unable to test and reproduce the issue.

However, I've added a bunch of Armada 370 people/maintainers in Cc,
hopefully they can at least try to reproduce and confirm that reverting
this patch makes the problem go away, which would confirm that we
should look for a bug in the mvneta driver around this problem.

Thanks!

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
