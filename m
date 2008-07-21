From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [crash] kernel BUG at net/core/dev.c:1328!
Date: Mon, 21 Jul 2008 20:46:16 +0200
Message-ID: <20080721184616.GA8442@elte.hu>
References: <20080720.104411.81744468.davem@davemloft.net> <20080721133059.GA30637@elte.hu> <20080721134506.GA27598@elte.hu> <20080721182318.GA20940@elte.hu> <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753751AbYGUSqw@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, 21 Jul 2008, Ingo Molnar wrote:
> >
> > [   24.434799] kernel BUG at net/core/dev.c:1328!
> 
> Ok, it is now a WARN_ON_ONCE() in my tree (which I _just_ pushed out). 
> 
> So it's going to cause irritating messages (once), but the machine should 
> hopefully work.
> 
> > Should i spend time on bisecting this, or is this known already?
> 
> It's going to bisect down to the same commit you already bisected 
> once, it's the networking code that changed some of the rules, so 
> various network drivers that didn't follow the expected rules are now 
> unhappy.
> 
> Maybe the network drivers are few enough that it will get fixed, or 
> maybe the WARN_ON_ONCE() will just be removed and the rule not 
> reinforced.

ok, have updated the testboxes to your latest push.

Btw., otherwise the big networking pull held up pretty well on a healthy 
range of testboxes i have, it looked a lot scarier to me in the morning 
than it turned out to be during the day. A couple of hundred tests 
passed already and no indication of any runtime fragility so far. Boot 
crashes/warnings can be annoying and hard to get a proper log of but 
once the log is available they are normally quite easy for developers to 
act upon.

	Ingo
