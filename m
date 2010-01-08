From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: Make descriptor ring
 allocations NUMA-aware
Date: Fri, 08 Jan 2010 00:31:22 -0800 (PST)
Message-ID: <20100108.003122.82929917.davem@davemloft.net>
References: <20100107044845.28605.42794.stgit@localhost.localdomain>
	<20100108.002139.234493705.davem@davemloft.net>
	<Pine.WNT.4.64.1001080023050.15320@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40245
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751298Ab0AHIbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:31:14 -0500
In-Reply-To: <Pine.WNT.4.64.1001080023050.15320@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Fri, 8 Jan 2010 00:25:26 -0800 (Pacific Standard Time)

> In our hardware (82598 and 82599), the CPU field in the DCA registers is 8 
> bits.
> 
> The reason I truncated this was to fit these values into the 
> first cacheline of the struct.  I also didn't figure we'd see a system 
> that would have 255 NUMA nodes before 10 GbE was something that was on the 
> shelf collecting dust.  :-)

The X86 port supports 9 for "NODES_SHIFT", and up to 4096 cpus.

Even when !MAXSMP, the cpu limit is 512.

Don't make the type ungeneric just because some current piece of
hardware has that limitation.  This is how subtle bugs slip into the
tree, and it makes auditing for such bugs a nightmare.

Thanks.
