From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast
 groups
Date: Sat, 2 Jul 2011 00:37:56 +0200
Message-ID: <20110701223756.GG2613105@jupiter.n2.diac24.net>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	davem@davemloft.net
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:51424 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757676Ab1GAWiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 18:38:05 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 01, 2011 at 10:21:44PM +0100, Nick Carter wrote:
> Introduce sysfs ../bridge/group_fwd_mask attribute so users can
> configure which group mac addresses are forwarded.
> 
> These diffs do not change the default behaviour of bridge.ko.  By
> changing the group_fwd_mask value users can select any combination of
> the 01-80-C2-00-00-00 - 01-80-C2-00-00-0F addresses to be forwarded.
> 
> Signed-off-by: Nick Carter <ncarter100@gmail.com>

Hm. Makes it very easy to shoot yourself in the foot, but...

> +	br->group_fwd_mask = 0;

... but the default is safe, so we're following the unix philosophy of
handing out the gun to shoot yourself :)

Reviewed-by: David Lamparter <equinox@diac24.net>


PS:
> @@ -166,6 +166,9 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb)
>  		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
>  			goto forward;

Not sure if we still need the STP one when we have the mask, it should
probably go away for consistency. It would change existing behaviour
though... either way it can be a separate patch.

> +		if (p->br->group_fwd_mask & (1 << dest[5]))
> +			goto forward;
> +
>  		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
>  			    NULL, br_handle_local_finish))
>  			return NULL;	/* frame consumed by filter */
