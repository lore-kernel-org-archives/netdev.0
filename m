From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] gro: introduce gro_mac_header_len
Date: Mon, 06 Feb 2012 12:00:15 -0500 (EST)
Message-ID: <20120206.120015.1104308784569339801.davem@davemloft.net>
References: <1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120206.113145.1284864994961472499.davem@davemloft.net>
	<4F300353.2080705@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F300353.2080705-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Mon, 6 Feb 2012 18:44:03 +0200

> As I wrote earlier on this thread, the reason is that in order to be
> able to xmit skb's for which the stack doesn't provide a neighbour,
> IPoIB makes sure to have extra INFINIBAND_ALEN bytes headroom on
> skbs. Such that the ipoib hard_header functions writes a
> "ipoib_pseudoheader" (= hw address) on the skb and the xmit function
> grabs it from there and use that pseudoheader to search for the actual
> IB L2 address handle kept for that dest. Example such skbs are unicast
> ARP replies and multicast. see below some relevant code sections from
> ipoib_main.c

Then IPoIB is broken and must be fixed, see my other reply.

We're not adding a bogus member to the netdevice just because IPoIB
tries to do path resolution and neighbour validation behind the
neighbour cache's back.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
