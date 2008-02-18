From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] net/8021q/vlan_dev.c - Use print_mac
Date: Mon, 18 Feb 2008 10:31:02 -0800
Message-ID: <1203359462.7181.80.camel@localhost>
References: <20080215104804.9870.15722.stgit@one>
	 <20080215.025855.202184003.davem@davemloft.net>
	 <1203097370.21308.18.camel@localhost>  <47B9A20C.10304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47B9A20C.10304-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-02-18 at 16:19 +0100, Patrick McHardy wrote:
> > @@ -404,11 +405,8 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >  
> >  	pr_debug("%s: about to send skb: %p to dev: %s\n",
> >  		__FUNCTION__, skb, skb->dev->name);
> > -	pr_debug("  " MAC_FMT " " MAC_FMT " %4hx %4hx %4hx\n",
> > -		 veth->h_dest[0], veth->h_dest[1], veth->h_dest[2],
> > -		 veth->h_dest[3], veth->h_dest[4], veth->h_dest[5],
> > -		 veth->h_source[0], veth->h_source[1], veth->h_source[2],
> > -		 veth->h_source[3], veth->h_source[4], veth->h_source[5],
> > +	pr_debug("  %s %s %4hx %4hx %4hx\n",
> > +		 print_mac(mac, veth->h_dest), print_mac(mac2, veth->h_source),
> This results in print_mac getting called twice per packet even without
> debugging. Whats the problem with MAC_FMT?

It's just a consistency thing.
It identifies code where MAC addresses are used.
an allyesconfig is a bit smaller (~.1%).
pr_debug is a noop when not debugging, print_mac is optimized away.
