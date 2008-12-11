From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Default offload settings in Ethernet drivers
Date: Thu, 11 Dec 2008 19:29:28 +0000
Message-ID: <1229023768.3006.37.camel@achroite>
References: <49415EDB.3030006@computer.org>  <20081211105459.3e615be8@s6510>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:48704 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759988AbYLKT3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 14:29:37 -0500
In-Reply-To: <20081211105459.3e615be8@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-12-11 at 10:54 -0800, Stephen Hemminger wrote:
> On Thu, 11 Dec 2008 19:41:31 +0100
> Jan Ceuleers <jan.ceuleers@computer.org> wrote:
> 
> > Hi!
> > 
> > A discussion recently took place on the power mailing list on the 
> > subject of the impact of (hardware-assisted) offload functions on the 
> > power efficiency of the overall system.
> > 
> > The discussion was brought on by me noticing that not all drivers enable 
> >   all of their offload features by default (case in point: r8169).
> > 
> > Although the discussion may not be complete, early indications are that:
> > 
> > 1. Hardware-assisted offloads improve power efficiency unless 
> > implemented in a separate CPU (TOE / Total Offloading);
> > 
> > 2. It would probably be a good idea to enable hardware-assisted offloads 
> > other than TOE by default given the above.
> > 
> > I would therefore like to sollicit views here:
> > 
> > 1. Would changing default offload settings in Ethernet drivers help to 
> > save the planet?
> > 
> > 2. Which offload settings does it make sense to enable by default?
> 
> Go get a kill-a-watt meter and real hardware and measure.
[...]

Even then, the results will be highly dependent on the CPU's power-
saving capabilities and on settings that affect the pattern of IRQs like
interrupt moderation and number of queues used by multiqueue-capable
drivers, not just on the offload settings.  I would expect checksum
generation/validation and segmentation in an ASIC to take less power
than in a CPU, but on an already-busy CPU this might not be the case.

Power usage also depends on throughput, of course.  If the test involves
pushing data as fast as possible rather than simulating a specific
workload then offload features may well probably increase throughput
without reducing power consumption.  So maybe the metric should be
power/throughput... but there is unlikely to be a linear relationship
between the two, so a single figure for this may be misleading.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

