From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5 2.6.22-rc6] L2TP: Changes to existing ppp and
 socket kernel headers for L2TP
Date: Wed, 27 Jun 2007 15:48:48 -0700 (PDT)
Message-ID: <20070627.154848.112982936.davem@davemloft.net>
References: <200706272220.l5RMKcv9004943@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53356
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758839AbXF0Ws3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 18:48:29 -0400
In-Reply-To: <200706272220.l5RMKcv9004943@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Wed, 27 Jun 2007 23:20:38 +0100

> Add struct sockaddr_pppol2tp to carry L2TP-specific address
> information for the PPPoX (PPPoL2TP) socket. Unfortunately we can't
> use the union inside struct sockaddr_pppox because the L2TP-specific
> data is larger than the current size of the union and we must preserve
> the size of struct sockaddr_pppox for binary compatibility.
> 
> Also add a PPPIOCGL2TPSTATS ioctl to allow userspace to obtain
> L2TP counters and state from the kernel.
> 
> Add new if_pppol2tp.h header.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

...

> +/* For PPPIOCGL2TPSTATS */
> +struct pppol2tp_ioc_stats {
> +	__u16	tunnel_id;	/* redundant */
> +	__u16	session_id;	/* if zero, get tunnel stats */
> +	__u32	using_ipsec:1;	/* valid only for session_id == 0 */
> +	__u64	tx_packets;
> +	__u64	tx_bytes;
> +	__u64	tx_errors;
> +	__u64	rx_packets;
> +	__u64	rx_bytes;
> +	__u64	rx_seq_discards;
> +	__u64	rx_oos_packets;
> +	__u64	rx_errors;
> +};

This is going to cause problems on compat platforms where
__u64 is aligned on an 8-byte boundary on the 64-bit
variant but it is not on the 32-bit cpu variant.

A way to avoid this is to use the aligned_u64 type from
linux/types.h which ensures 8-byte alignment on all
platforms and thus you won't need to provide s compat
ioctl() handler for your statistics ioctl().

I'll make this change for you so we don't have to go
back and forth again just for this.
