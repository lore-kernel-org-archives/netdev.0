From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sat, 03 May 2008 16:32:02 -0700 (PDT)
Message-ID: <20080503.163202.48704621.davem@davemloft.net>
References: <20080501.034950.261408566.davem@davemloft.net>
	<1209641914.3904.0.camel@johannes.berg>
	<1209857088.3920.4.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209857088.3920.4.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Sun, 04 May 2008 01:24:48 +0200

> 
> > > @@ -699,6 +699,12 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
> > >  	if (skb_shared(skb))
> > >  		BUG();
> > >  
> > > +	if (unlikely((nhead || ntail) && skb->sk)) {
> > > +		printk(KERN_ERR "SKB BUG: Illegal pskb expand (%d:%d) "
> > > +		       "with socket attached\n",
> > > +		       nhead, ntail);
> > > +	}
> > > +
> > >  	size = SKB_DATA_ALIGN(size);
> > 
> > Ok I think I'm starting to understand this a little better. However,
> > shouldn't this function update skb->truesize so if the skb is later
> > attached to a different socket again it has the right size?
> 
> Judging from some of the callers, the caller should. Why?!

Relax :-)

We certainly could check that there is no socket attached here,
and make the truesize adjustment right at this spot.

It just never happened before in practice in a way that matters.

That's why we have the truesize assertion, to discover situations
like this and thus be able to fix it.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
