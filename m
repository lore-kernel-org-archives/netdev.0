From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 16:24:24 -0700 (PDT)
Message-ID: <20080505.162424.176435653.davem@davemloft.net>
References: <1210000923.8245.26.camel@johannes.berg>
	<20080505.160328.203996832.davem@davemloft.net>
	<1210029435.8012.25.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1210029435.8012.25.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 06 May 2008 01:17:14 +0200

> Also, should there be some sort of timer that resets the rx_alloc_extra
> again so that when you bridge it once with p54 (needs heaps of headroom)
> you don't suffer forever?

We're talking about, what, up to 128 bytes or something like that?
If you're bridging over your wireless device you've already invested
in assuming those kinds of costs.

I don't think this aspect is really worth worrying about.  The current
behavior is so much incredibly worse. :-)

> > @@ -255,11 +255,12 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
> >  		unsigned int length, gfp_t gfp_mask)
> >  {
> >  	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
> > +	unsigned int extra = dev->rx_alloc_extra + NET_SKB_PAD;
> >  	struct sk_buff *skb;
> >  
> > -	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
> > +	skb = __alloc_skb(length + extra, gfp_mask, 0, node);
> >  	if (likely(skb)) {
> > -		skb_reserve(skb, NET_SKB_PAD);
> > +		skb_reserve(skb, extra);
> 
> Doesn't that break alignment though?

Good catch, we'll have to align the rx_alloc_extra to some modulus or
similar.  Ideally, at the spot where rx_alloc_extra is set instead
of here.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
