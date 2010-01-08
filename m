From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: Make descriptor ring
 allocations NUMA-aware
Date: Fri, 08 Jan 2010 00:21:39 -0800 (PST)
Message-ID: <20100108.002139.234493705.davem@davemloft.net>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
	<20100107044845.28605.42794.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45479
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750848Ab0AHIVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:21:32 -0500
In-Reply-To: <20100107044845.28605.42794.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 06 Jan 2010 20:48:46 -0800

> @@ -147,7 +147,7 @@ struct ixgbe_ring {
>  
>  #ifdef CONFIG_IXGBE_DCA
>  	/* cpu for tx queue */
> -	int cpu;
> +	u8 cpu;
>  #endif
>  
>  	u16 work_limit;			/* max work per interrupt */

Is truncating cpu and node numbers to 8-bits ok?  I really don't
see how it can be fine, even for DCA.

This is especially the case since dca3_get_tag() and the
DCA ->get_tag() callback explicitly take an 'int' argument
too.
