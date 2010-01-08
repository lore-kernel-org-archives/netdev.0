From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: Make descriptor ring allocations
 NUMA-aware
Date: Fri, 8 Jan 2010 00:25:26 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.1001080023050.15320@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
 <20100107044845.28605.42794.stgit@localhost.localdomain>
 <20100108.002139.234493705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60881 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753239Ab0AHIZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2010 03:25:27 -0500
In-Reply-To: <20100108.002139.234493705.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jan 2010, David Miller wrote:

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 06 Jan 2010 20:48:46 -0800
> 
> > @@ -147,7 +147,7 @@ struct ixgbe_ring {
> >  
> >  #ifdef CONFIG_IXGBE_DCA
> >  	/* cpu for tx queue */
> > -	int cpu;
> > +	u8 cpu;
> >  #endif
> >  
> >  	u16 work_limit;			/* max work per interrupt */
> 
> Is truncating cpu and node numbers to 8-bits ok?  I really don't
> see how it can be fine, even for DCA.

In our hardware (82598 and 82599), the CPU field in the DCA registers is 8 
bits.

The reason I truncated this was to fit these values into the 
first cacheline of the struct.  I also didn't figure we'd see a system 
that would have 255 NUMA nodes before 10 GbE was something that was on the 
shelf collecting dust.  :-)

> This is especially the case since dca3_get_tag() and the
> DCA ->get_tag() callback explicitly take an 'int' argument
> too.

Cheers,
-PJ
