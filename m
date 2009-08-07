From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 7 Aug 2009 17:51:12 -0400
Message-ID: <20090807175112.a1f57407.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<4A7C9A14.7070600@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>, gallatin@myri.com
To: Brice Goglin <Brice.Goglin@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:47277
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753272AbZHGVvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 17:51:12 -0400
In-Reply-To: <4A7C9A14.7070600@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Aug 2009, Brice Goglin wrote:

> Bill Fink wrote:
> > This could be because I discovered that if I did:
> >
> > 	find /sys -name numa_node -exec grep . {} /dev/null \;
> >
> > that the numa_node associated with all the PCI devices was always 0,
> > and if IIUC then I believe some of the PCI devices should have been
> > associated with NUMA node 2.  Perhaps this is what is causing all
> > the memory pages allocated by the myri10ge driver to be on NUMA
> > node 0, and thus causing the major performance issue.
> >   
> 
> I've seen some cases in the past where numa_node was always 0 on
> quad-Opteron machines with a PCI bus on node 1. IIRC it got fixed in
> later kernels thanks to patches from Yinghai Lu (CC'ed).

By later kernels do you mean 2.6.30 or 2.6.31?

> Is the corresponding local_cpus sysfs file wrong as well ?

All sysfs local_cpus values are the same (00000000,000000ff),
so yes they are also wrong.

> Maybe your kernel doesn't properly handle the NUMA location of PCI
> devices on Nehalem machines yet?

I assume so, unless there's some secret NUMA system setting that
I'm unaware of that would affect this and needs changing for my
setup.

						-Thanks

						-Bill
