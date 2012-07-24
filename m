From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH RESEND net/for-next V1 1/1] IB/ipoib: break linkage to
 neighbouring system
Date: Mon, 23 Jul 2012 18:34:34 -0700 (PDT)
Message-ID: <20120723.183434.1181274244746651450.davem@davemloft.net>
References: <1342714502-11301-1-git-send-email-ogerlitz@mellanox.com>
	<1342714502-11301-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1342714502-11301-2-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Thu, 19 Jul 2012 19:15:02 +0300

> -static void neigh_add_path(struct sk_buff *skb, struct neighbour *n, struct net_device *dev)
> +static void neigh_add_path(struct sk_buff *skb, u8 *daddr,
> +				struct net_device *dev)

Please line up "struct net_device *dev" with the first column after the
openning parenthesis on the first line.

> +	return jhash(daddr+12, 8, 0xFFFFFF & *(u32 *) daddr) & htbl->mask;

It would be tons faster to go:

	u32 *daddr_32 = (u32 *) daddr;

	hv = jhash_3words(daddr_32[3], daddr_32[4], 0xFFFFFF & daddr_32[0], 0);
	hv &= htbl->mask;

Plain jhash() has loops and various conditions that are entirely
unnecessary when you know how much you are hashing ahead of time.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
