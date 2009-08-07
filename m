From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 7 Aug 2009 18:55:25 -0400
Message-ID: <20090807185525.602c1607.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<4A7C9A14.7070600@inria.fr>
	<20090807175112.a1f57407.billfink@mindspring.com>
	<4A7CA24E.4080503@inria.fr>
	<20090807180840.b27ce794.billfink@mindspring.com>
	<4A7CA7F0.60704@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>, gallatin@myri.com
To: Brice Goglin <Brice.Goglin@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:41165 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755314AbZHGWzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 18:55:25 -0400
In-Reply-To: <4A7CA7F0.60704@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 08 Aug 2009, Brice Goglin wrote:

> Bill Fink wrote:
> > OK.  The tests were run on a 2.6.29.6 kernel so presumably should
> > have included the fix you mentioned.
> 
> Yes, but I wanted to emphasize that new platforms sometime need some new
> code to handle this kind of things. Some Nehalem-specific changes might
> be needed now.

Thanks for the clarification.

> >>>> Is the corresponding local_cpus sysfs file wrong as well ?
> >>>>         
> >>> All sysfs local_cpus values are the same (00000000,000000ff),
> >>> so yes they are also wrong.
> >>>       
> >> And hyperthreading is enabled, right?
> >>     
> >
> > No, hyperthreading is disabled.  It's a dual quad-core system so there
> > are a total of 8 cores, 4 on NUMA node 0 and 4 on NUMA node2.
> 
> So numa_node says that the device is close to node 0 while local_cpus
> says that it's close to all 8 cores ie close to both node0 and node2
> (which may well be wrong as well).

I believe it is wrong.  The basic system arcitecture is:

      Memory----CPU1----QPI----CPU2----Memory
                  |              |
                  |              |
                 QPI            QPI
                  |              |
                  |              |
                5520----QPI----5520
                ||||           ||||
                ||||           ||||
                ||||           ||||
                PCIe           PCIe

There are 2 x8, 1 x16, and 1 x4 PCIe 2.0 interfaces on each of the
Intel 5520 I/O Hubs.  The Myricom dual-port 10-GigE NICs are in the
six x8 or better slots.  eth2 through eth7 are on the second
Intel 5520 I/O Hub, so they should presumably show up on NUMA node 2,
and have local CPUs 1, 3, 5, and 7.  eth8 through eth13 are on the
first Intel 5520 I/O Hub, and thus should be on NUMA node 0 with
local CPUs 0, 2, 4, and 6 (CPU info derived from /proc/cpinfo).

						-Bill

