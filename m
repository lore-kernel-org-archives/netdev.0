From: Andres Freund <andres@anarazel.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 ( possibly?caused by netem)
Date: Fri, 3 Jul 2009 14:30:00 +0200
Message-ID: <200907031430.00946.andres@anarazel.de>
References: <200907030331.32531.andres@anarazel.de> <200907031326.21822.andres@anarazel.de> <20090703120301.GD4847@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.anarazel.de ([217.115.131.40]:49708 "EHLO smtp.anarazel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbZGCMaC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jul 2009 08:30:02 -0400
In-Reply-To: <20090703120301.GD4847@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 03 July 2009 14:03:01 Jarek Poplawski wrote:
> On Fri, Jul 03, 2009 at 01:26:21PM +0200, Andres Freund wrote:
> > On Friday 03 July 2009 08:12:13 Jarek Poplawski wrote:
> > > On Fri, Jul 03, 2009 at 03:31:31AM +0200, Andres Freund wrote:
> > > ...
> > >
> > > > Ok. I finally see the light. I bisected the issue down to
> > > > eea08f32adb3f97553d49a4f79a119833036000a :  timers: Logic to move non
> > > > pinned timers
> > > >
> > > > Disabling timer migration like provided in the earlier commit stops
> > > > the issue from occuring.
> > > >
> > > > That it is related to timers is sensible in the light of my findings,
> > > > that I could trigger the issue only when using delay in netem - that
> > > > is the codepath using qdisc_watchdog...
> > > Andres, thanks for your work and time. It saved me a lot of searching,
> > > because I wasn't able to trigger this on my old box.
> > Thanks. It allowed me to go through some of my remaining paperwork ;-)
> > Does anybody of you have an idea where the problem actually resides?
> Do you mean possibly broken timers are not enough?
I have no ideas how/if the timers are actually broken or if the problem does 
reside somewhere else and is just made visible by the timer changes.

I would have expected more problem with completely borked timers ;-)


> > Aside from that - is the whole PSCHED_TICKS2NS/PSCHED_NS2TICKS conversion
> > business purely backward compatibility?
> The whole PSCHED_ conversion was to get finer resolution without
> breaking backward compatibility, I hope.;-)
I haven't seen any problems - just curious ;-)

Andres
