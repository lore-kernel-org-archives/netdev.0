From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] gro: introduce gro_mac_header_len
Date: Mon, 06 Feb 2012 11:31:45 -0500 (EST)
Message-ID: <20120206.113145.1284864994961472499.davem@davemloft.net>
References: <1328541706.2220.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4F2FF050.7040400@mellanox.com>
	<1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 06 Feb 2012 17:27:07 +0100

> Shlomo Pongratz reported GRO L2 header check was suited for Ethernet
> only, and failed on IB/ipoib traffic.
> 
> He provided a patch faking a zeroed header to let GRO aggregates frames.
> 
> Roland Dreier, Herbert Xu, and others suggested we change GRO L2 header
> check to be more generic.
> 
> This patch introduces a new netdevice field, gro_mac_header_len, giving
> L2 header length, default to ETH_HLEN (14 bytes)
> 
> A device setup function can override this default value.
> 
> __napi_gro_receive() has special handling for the common case (Ethernet)
> to avoid a memcmp() call and use an inline optimized function instead.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Reported-by: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

We really need an explanation, probably both in the commit message and
the comments next to this new struct member, explaining why in the world
we can't use ->hard_header_len for this.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
