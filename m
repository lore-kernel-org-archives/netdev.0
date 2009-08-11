From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 12 Aug 2009 00:27:37 +0200
Message-ID: <87ws5af0km.fsf@basil.nowhere.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52682 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbZHKW1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 18:27:40 -0400
In-Reply-To: <20090811033210.6b422ed1.billfink@mindspring.com> (Bill Fink's message of "Tue, 11 Aug 2009 03:32:10 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink <billfink@mindspring.com> writes:
>
> I originally tried to just use alloc_pages_node() instead of alloc_pages(),
> but it didn't help.  As mentioned in an earlier e-mail, that seems to
> be because I discovered that doing:
>
> 	find /sys -name numa_node -exec grep . {} /dev/null \;
>
> revealed that the NUMA node associated with _all_ the PCI devices was
> always 0, when at least some of them should have been associated with
> NUMA node 2, including 6 of the 12 Myricom 10-GigE devices.

> I discovered today that the NUMA node cpulist/cpumap is also wrong.
> A cat of /sys/devices/system/node/node0/cpulist returns "0-7" (with a
> cpumask of 00000000,000000ff), while the cpulist for node2 is empty
> (with a cpumask of 00000000,00000000).  The distance is correct,
> with "10 20" for node 0 and "20 10" for node2.


When the CPU nodes are not correct the device nodes are unlikely
to correct either. In fact your system likely has no node 1 configured, 
right?

This information comes from the BIOS. So either your BIOS is broken
or you simply didn't enable NUMA mode in the BIOS, but configured
memory interleaving.

If you post dmesg output somewhere I can take a look.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.
