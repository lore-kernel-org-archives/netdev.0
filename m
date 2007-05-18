From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [PATCH 2/2] tbf scheduler: TSO support (update 2)
Date: Fri, 18 May 2007 11:35:07 +0900 (JST)
Message-ID: <20070518.113507.41839122.taka@valinux.co.jp>
References: <20070515.203953.03891900.taka@valinux.co.jp>
	<20070515.204148.114469367.taka@valinux.co.jp>
	<20070517135530.GA4381@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, linux-net@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070517135530.GA4381@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > @@ -924,7 +926,9 @@ cbq_dequeue_prio(struct Qdisc *sch, int 
> >  				cl->xstats.borrows += skb->len;
> >  #endif
> >  			}
> > -			q->tx_len = skb->len;
> > +			q->tx_segs = skb_shinfo(skb)->gso_segs ? :
> > +			  skb_shinfo(skb)->gso_size ? skb->len/skb_shinfo(skb)->gso_size + 1 : 1;
> > +			q->tx_len = (skb->len - 1)/q->tx_segs + 1;
> 
> This isn't safe for Xen (and potentially other virtualisation
> environments) since qdisc code runs before dev_hard_start_xmit
> which is where we verify the sanity of gso_segs.  So you could
> be using some arbitrary value from an untrusted source.
> 
> If you really want to use it, you should test for SKB_GSO_DODGY
> on the packet which will be set if gso_segs can't be trusted.

Yep, you have a point that some sanity check should be added.
I think a simple check would be enough not to crash CBQ
as the accurate checking will be done in dev_hard_start_xmit or
device drivers.

Thanks,
Hirokazu Takahashi.

