From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: Make descriptor ring allocations
 NUMA-aware
Date: Fri, 8 Jan 2010 00:36:01 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.1001080034340.15300@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20100107044845.28605.42794.stgit@localhost.localdomain>
 <20100108.002139.234493705.davem@davemloft.net>
 <Pine.WNT.4.64.1001080023050.15320@ppwaskie-MOBL2.amr.corp.intel.com>
 <20100108.003122.82929917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62601 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191Ab0AHIgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2010 03:36:02 -0500
In-Reply-To: <20100108.003122.82929917.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jan 2010, David Miller wrote:

> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Fri, 8 Jan 2010 00:25:26 -0800 (Pacific Standard Time)
> 
> > In our hardware (82598 and 82599), the CPU field in the DCA registers is 8 
> > bits.
> > 
> > The reason I truncated this was to fit these values into the 
> > first cacheline of the struct.  I also didn't figure we'd see a system 
> > that would have 255 NUMA nodes before 10 GbE was something that was on the 
> > shelf collecting dust.  :-)
> 
> The X86 port supports 9 for "NODES_SHIFT", and up to 4096 cpus.
> 
> Even when !MAXSMP, the cpu limit is 512.
> 
> Don't make the type ungeneric just because some current piece of
> hardware has that limitation.  This is how subtle bugs slip into the
> tree, and it makes auditing for such bugs a nightmare.
> 
> Thanks.

Understood.  Let me see if I can shuffle things around in the struct to 
keep my cacheline packed, and not screw with the data type sizes.  I'll 
respin and have Jeff push a new patch once I get it sorted out.

Thanks for the review Dave,

-PJ
