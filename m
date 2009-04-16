From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 22:19:18 +0100
Message-ID: <1239916758.3203.57.camel@achroite>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com>
	 <1239905279.3203.30.camel@achroite>
	 <alpine.DEB.1.10.0904161500020.15835@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:50794 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752501AbZDPVTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 17:19:22 -0400
In-Reply-To: <alpine.DEB.1.10.0904161500020.15835@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-16 at 15:02 -0400, Christoph Lameter wrote:
> On Thu, 16 Apr 2009, Ben Hutchings wrote:
> 
> > On Thu, 2009-04-16 at 12:10 -0400, Christoph Lameter wrote:
> > > The following are results of lantency measurements using udpping
> > > (available from http://gentwo.org/ll). It shows that significant latencies
> > > were added since 2.6.27. I surely wish we could get back to times below 90
> > > microseconds.
> > [...]
> >
> > This "90 microseconds" figure is specific to a particular driver and
> > hardware.  Have you verified that it applies to others?  The variation
> > you've reported is tiny compared to the improvements that can be made or
> > lost by hardware tuning.
> 
> The RX delay can influence this of course and so can the driver. But the
> measurements are with the same RX delay and the same driver. Variations
> are up to 20% which is not tiny and its only due to different kernel
> versions.

I just ran netperf UDP_RR against sfc (the out-of-tree version, so that
driver changes should not be a factor) on "my" test rig (a couple of
servers from 2005; don't quote these figures).  The transaction rates
were:

2.6.22:   38584.58
2.6.27:   35312.01
2.6.29.1: 38006.50

So for this hardware and driver, 2.6.27 has slightly _higher_ latency.
This is why I'm asking whether you tested with multiple drivers, so you
are not measuring changes in tg3 (or whichever driver it was).

Note also that 1G Ethernet is hardly representative of HPC hardware.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

