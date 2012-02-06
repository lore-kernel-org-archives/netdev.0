From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 06 Feb 2012 11:58:59 -0500 (EST)
Message-ID: <20120206.115859.1384761795375582044.davem@davemloft.net>
References: <1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120206.113145.1284864994961472499.davem@davemloft.net>
	<1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 06 Feb 2012 17:47:14 +0100

[ Roland Dreier CC:'d ]

> gro_max_header_len can be different than hard_header_len because as Or
> Gerlitz said :
> 
> 	IPoIB advertizes hard_header_len which is bigger than the
> 	IPoIB header len, this is done such that skbs sent by the
> 	network stack have enough headroom for a "pseudoheader"
> 	which for few flows (e.g unicast arp replies and multicast)
> 	is placed there by the ipoib hard_header function and later
> 	used by the xmit function.

Translation: IPoIB's path resolution mechanism is garbage

So if IPoIB path resolution was properly integrated into the neighbour
cache state machine, instead of being implemented awkwardly in the
device transmit path, this crap wouldn't be necessary right?

So here we have yet another incredibly painful side effect of how
IPoIB path resolution works.

Roland, I want you to seriously consider a way, any way, to get rid of
how IPoIB does path resolution.  It must be fully integrated into the
neighbour layer, the neighbour layer must be knowledgable about how
path resolution is a necessary step for a neighbour entry to enter the
valid state, and I want all of this awkward neighbour handling code
removed from the transmit path of IPoIB.

And finally it must not lie about it's hardware header length.

Then we won't need crap like what is being proposed here, a
"no_this_is_the_real_hard_header_len" struct member.  That's just
rediculious.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
