From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 14 Aug 2009 16:31:55 -0400
Message-ID: <20090814163155.968872fe.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<4A7C9A14.7070600@inria.fr>
	<20090807175112.a1f57407.billfink@mindspring.com>
	<4A7CCEFC.7020308@myri.com>
	<20090807213557.d0faec23.billfink@mindspring.com>
	<4A7D5CA4.3030307@myri.com>
	<20090808112636.GB18518@localhost.localdomain>
	<4A7DC230.6060206@myri.com>
	<20090808183251.GA23300@localhost.localdomain>
	<20090811033210.6b422ed1.billfink@mindspring.com>
	<F169D4F5E1F1974DBFAFABF47F60C10A36523146@orsmsx507.amr.corp.intel.com>
	<20090812003824.26c9c8fb.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:46187 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932855AbZHNUcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 16:32:06 -0400
In-Reply-To: <20090812003824.26c9c8fb.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Aug 2009, Bill Fink wrote:

> On Tue, 11 Aug 2009, Brandeburg, Jesse wrote:
> 
> > Bill Fink wrote:
> > > On Sat, 8 Aug 2009, Neil Horman wrote:
> > > 
> > >> On Sat, Aug 08, 2009 at 02:21:36PM -0400, Andrew Gallatin wrote:
> > >>> Neil Horman wrote:
> > >>>> On Sat, Aug 08, 2009 at 07:08:20AM -0400, Andrew Gallatin wrote:
> > >>>>> Bill Fink wrote:
> > >>>>>> On Fri, 07 Aug 2009, Andrew Gallatin wrote:
> > >>>>>> 
> > >>>>>>> Bill Fink wrote:
> > >>>>>>> 
> > >>>>>>>> All sysfs local_cpus values are the same (00000000,000000ff),
> > >>>>>>>> so yes they are also wrong.
> > 
> > bill, I recently helped Jesse Barnes push a patch that addresses this kind
> > of issue on CoreI7, the root cause was the numa_node variable was
> > initialized based on slot on AMD systems, but needed to be set to -1 by
> > default on systems with a uniform IOH to slot architecture.
> > 
> > here is the commit ID:
> > http://git.kernel.org/?p=linux/kernel/git/sfr/linux-next.git;a=commit;h=3c38
> > d674be519109696746192943a6d524019f7f
> > 
> > I'm not sure it is in linus' tree yet, this link is to net-next
> > 
> > Maybe see if it helps?
> 
> It's worth a shot.
> 
> Hopefully I can get a chance to build a new kernel tomorrow to check
> out some of the suggestions, like this one, the setting of ACPI_DEBUG,
> and the new ftrace module for checking NUMA affinity of skbs.

I applied this patch to my 2.6.29.6 kernel (from Fedora 11).

Now when I do:

	find /sys -name numa_node -exec grep . {} /dev/null \;

the numa_node for _all_ PCI devices is -1.

When I do:

	find /sys -name local_cpus -exec grep . {} /dev/null \;

I find that local_cpus is always 00000000,00000000.

Is that OK or should it be 00000000,000000ff (for my dual quad-core
Xeon 5580 system with no hyperthreading)?

Also, is it just not possible on this type of Intel Xeon system to
properly associate the PCI devices with the nearest NUMA node?

In any event, the patch didn't help (or hurt).  The transmit
performance remained at ~100 Gbps while the receive performance
remained at 55 Gbps.

						-Thanks

						-Bill
