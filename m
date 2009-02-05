From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH NET-NEXT 01/10] clocksource: allow usage independent of
	timekeeping.c
Date: Wed, 04 Feb 2009 16:18:13 -0800
Message-ID: <1233793093.15119.147.camel@desktop>
References: <1233752517-30010-1-git-send-email-patrick.ohly@intel.com>
	 <1233752517-30010-2-git-send-email-patrick.ohly@intel.com>
	 <1233756235.15119.54.camel@desktop> <1233758796.15940.198.camel@ecld0pohly>
	 <1233760170.15119.76.camel@desktop>
	 <1233775542.6994.13.camel@localhost.localdomain>
	 <1233776421.15119.125.camel@desktop>
	 <1233777982.6994.51.camel@localhost.localdomain>
	 <1233781499.15119.135.camel@desktop>
	 <1233782100.6994.82.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
To: john stultz <johnstul@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fifo99.com ([67.223.236.141]:38780 "EHLO fifo99.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320AbZBEASP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 19:18:15 -0500
In-Reply-To: <1233782100.6994.82.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-04 at 13:15 -0800, john stultz wrote:
> On Wed, 2009-02-04 at 13:04 -0800, Daniel Walker wrote:
> > On Wed, 2009-02-04 at 12:06 -0800, john stultz wrote:
> > 
> > > The duplication is only at a very low level. He could not reuse the
> > > established clocksource system without really breaking its semantics.
> > 
> > He gave a link to the first version,
> > 
> > http://kerneltrap.org/mailarchive/linux-netdev/2008/11/19/4164204
> > 
> > What specific semantics is he breaking there? 
> 
> His re-usage of cycle_last and xtime_nsec for other means then how
> they're defined.
> 
> In that case his use of xtime_nsec doesn't even store the same unit.

Those values to me are timekeeping ornaments .. It's not part of the
clocksource it's stuff you added from timekeeping. He could easily add
his own ornaments to the clocksource instead of re-use , then they could
be merged later .. It's not perfect, but it's at least a start.

> Plus he adds other accessors to the clocksource structure that are not
> compatible with the clocksources registered for timekeeping.

It's akin to vread, I think. I'd prefer to see the read() used instead,
but I can see why there could be a need for a structure getting passed.

> He's really doing something different here, and while it does access a
> counter, and it does translate that into nanoseconds, its not the same
> as whats done in the timekeeping core which the clocksource was designed
> around.

I think it's different from _timekeeping_. However the clocksource isn't
getting used differently. Like you said the lowlevel parts are the same,
ultimately that's all the clocksource should be.

It sounds like that's what you want anyway .. You can merge the lowlevel
parts with different sets of ornaments, that seems fairly acceptable to
me.

Daniel

