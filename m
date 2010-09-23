From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [net-next-2.6 RFC PATCH] e1000e: NUMA changes, add Node=
 parameter
Date: Thu, 23 Sep 2010 09:46:21 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1009230932300.5948@jbrandeb-desk1.amr.corp.intel.com>
References: <20100923032534.11274.77976.stgit@localhost.localdomain> <20100922.203642.02274207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55618 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755701Ab0IWQqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 12:46:21 -0400
In-Reply-To: <20100922.203642.02274207.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 22 Sep 2010, David Miller wrote:

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 22 Sep 2010 20:28:10 -0700
> 
> > Although a module parameter is not the preferred way for
> > in-tree modules, this problem is not solvable in ethtool without
> > mod params because of needing the information at probe time to
> > control early allocations of memory.  Ideally there would even be
> > a way to control the node where the memory of the netdev struct
> > would be allocated also.
> 
> Sorry, no.
> 
> Various folks are working on infrastructure such that the Numa node of
> everything other than the netdev struct can be dynamically choosen.
> 
> I'm sure we can find a way to dynamically reallocate and re-attach the
> netdev structure as well.

okay, thanks for your comments, we can carry this patch out-of-tree.  

Unfortunately as I said in the comments there is really no way around this 
*now* other than some fixed binding scheme, none of which are one size 
fits all, which is why I (reluctantly) supplied the module parameter 
patch.

I'm interested to hear more about the "various folks' infrastructure" 
plans, I'll do some research.  I can definitely provide testing.

The big gains from this patch come in router set ups, or really anything 
with lots of small-ish packets.  The cross node traffic *really* impacts 
I/O workloads, and when trying to tune a system for performance, the lack 
of being able to control where the hot path memory for an adapter is 
allocated can cause extremely difficult to diagnose performance problems.  

We don't generally post numbers, but if it would help get this patch 
accepted I could run some "for example" numbers with my 12 port 1G e1000e 
routing setup, maybe
1) irqbalance only,
2) taskset modprobe/ifup, irq bind (basically everything you can do 
without the patch)
3) patch applied, with nodes set, irq bind

If that would be useful let me know, I don't want to waste yours or my 
time.
