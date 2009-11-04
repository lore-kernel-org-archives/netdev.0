From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 19/25] mlx4: Randomizing mac addresses for slaves
Date: Wed, 04 Nov 2009 12:04:21 -0800
Message-ID: <adar5seys3e.fsf@cisco.com>
References: <4AF19E69.8070605@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AF19E69.8070605-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org> (Yevgeny Petrilin's message of
	"Wed, 04 Nov 2009 17:31:53 +0200")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


 > +#define MLX4_MAC_HEAD		0x2c9000000ULL
 > +			random_ether_addr(rand_mac);
 > +			caps->def_mac[i] = MLX4_MAC_HEAD | rand_mac[0] |
 > +				((u64)(rand_mac[1]) << 8) | ((u64)(rand_mac[2]) << 16);

Is this a good idea?  You're basically choosing 24 random bits within
your OUI... seems the chance of collision with another MAC used on the
same network is high enough that it could easily happen in practice on a
moderately big network.  Can you pick a reserved range or something?

Also I'm not sure if there's much point in using random_ether_addr if
you're going to override the high order part anyway, since
random_ether_addr just makes sure it doesn't pick a multicast address.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
