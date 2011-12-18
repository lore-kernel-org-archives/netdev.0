From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Sat, 17 Dec 2011 21:56:30 -0500 (EST)
Message-ID: <20111217.215630.640392276998191183.davem@davemloft.net>
References: <4EED3A3D.9080503@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: kumba@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180Ab1LRC4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 21:56:51 -0500
In-Reply-To: <4EED3A3D.9080503@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joshua Kinard <kumba@gentoo.org>
Date: Sat, 17 Dec 2011 19:56:29 -0500

> +/* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
> + * MACE Ethernet uses a 64 element hash table based on the Ethernet CRC.
> + */
> +static int multicast_filter_limit = 32;
> +
> +

Unnecessary empty line, only one is sufficient.  I also don't see a reason
to even define this value.  If it's a constant then use a const type.

> +	/* Multicast filter. */
> +	unsigned long mcast_filter;
> +
 ...
> +		priv->mcast_filter = 0xffffffffffffffffUL;

You're assuming that unsigned long is 64-bits here.  You need to use a
type which matches your expections regardless of the architecture that
the code is built on.

> +		netdev_for_each_mc_addr(ha, dev)
> +			set_bit((ether_crc(ETH_ALEN, ha->addr) >> 26),
> +				    (volatile long unsigned int *)&priv->mcast_filter);

This makes an assumption not only about the size of the "unsigned long"
type, but also of the endianness of the architecture this runs on.

Please recode this to remove both assumptions.
