From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Mon, 17 Aug 2009 09:53:02 -0700
Message-ID: <20090817095302.0c41ef68@jbarnes-g45>
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
	<20090814163155.968872fe.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-28.bluehost.com ([69.89.17.198]:52686 "HELO
	outbound-mail-28.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757380AbZHQQ7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 12:59:41 -0400
In-Reply-To: <20090814163155.968872fe.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Aug 2009 16:31:55 -0400
Bill Fink <billfink@mindspring.com> wrote:

> On Wed, 12 Aug 2009, Bill Fink wrote:
> 
> > On Tue, 11 Aug 2009, Brandeburg, Jesse wrote:
> > 
> > > Bill Fink wrote:
> > > > On Sat, 8 Aug 2009, Neil Horman wrote:
> > > > 
> > > >> On Sat, Aug 08, 2009 at 02:21:36PM -0400, Andrew Gallatin
> > > >> wrote:
> > > >>> Neil Horman wrote:
> > > >>>> On Sat, Aug 08, 2009 at 07:08:20AM -0400, Andrew Gallatin
> > > >>>> wrote:
> > > >>>>> Bill Fink wrote:
> > > >>>>>> On Fri, 07 Aug 2009, Andrew Gallatin wrote:
> > > >>>>>> 
> > > >>>>>>> Bill Fink wrote:
> > > >>>>>>> 
> > > >>>>>>>> All sysfs local_cpus values are the same
> > > >>>>>>>> (00000000,000000ff), so yes they are also wrong.
> > > 
> > > bill, I recently helped Jesse Barnes push a patch that addresses
> > > this kind of issue on CoreI7, the root cause was the numa_node
> > > variable was initialized based on slot on AMD systems, but needed
> > > to be set to -1 by default on systems with a uniform IOH to slot
> > > architecture.
> > > 
> > > here is the commit ID:
> > > http://git.kernel.org/?p=linux/kernel/git/sfr/linux-next.git;a=commit;h=3c38
> > > d674be519109696746192943a6d524019f7f
> > > 
> > > I'm not sure it is in linus' tree yet, this link is to net-next
> > > 
> > > Maybe see if it helps?
> > 
> > It's worth a shot.
> > 
> > Hopefully I can get a chance to build a new kernel tomorrow to check
> > out some of the suggestions, like this one, the setting of
> > ACPI_DEBUG, and the new ftrace module for checking NUMA affinity of
> > skbs.
> 
> I applied this patch to my 2.6.29.6 kernel (from Fedora 11).
> 
> Now when I do:
> 
> 	find /sys -name numa_node -exec grep . {} /dev/null \;
> 
> the numa_node for _all_ PCI devices is -1.

Yeah, that sounds right (indicates they're not really tied to a
specific node).

> When I do:
> 
> 	find /sys -name local_cpus -exec grep . {} /dev/null \;
> 
> I find that local_cpus is always 00000000,00000000.
> 
> Is that OK or should it be 00000000,000000ff (for my dual quad-core
> Xeon 5580 system with no hyperthreading)?

Hm, yeah it probably should have the full CPU mask...

> Also, is it just not possible on this type of Intel Xeon system to
> properly associate the PCI devices with the nearest NUMA node?

All the PCI devices hang off the root complex, which is the same
distance to each node of memory (at least that's my understanding for
current platforms).

> In any event, the patch didn't help (or hurt).  The transmit
> performance remained at ~100 Gbps while the receive performance
> remained at 55 Gbps.

Maybe the other Jesse has some ideas here.

-- 
Jesse Barnes, Intel Open Source Technology Center
