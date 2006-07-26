From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Wed, 26 Jul 2006 17:27:27 +0400
Message-ID: <20060726132727.GA10167@ms2.inr.ac.ru>
References: <20060725211725.GA24366@ms2.inr.ac.ru> <E1G5Z62-00083O-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:61856 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1750705AbWGZN2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 09:28:22 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1G5Z62-00083O-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

HellO!

> I like this.  However, since the cloned skb is either discarded in case
> of error, or queued in which case the caller discards its reference right
> away, wouldn't it be simpler to just do this?

Well, if we wanted just to cheat those checking tools, it is nice.
But if we want clarity, it does not look so sweet.

I _loved_ the tricks with skb refcnt a lot (look into netlink.c :-))
until the day, when pskb_expand_head() and Co appeared. It is so much
more handy and so hates refcnt.

I would seriously review all the uses of refcnt and leave it internal
to skbuff.c and use it externally only in a few places,
where it is obviously safe (MSG_PEEK, mostly) 

Alexey
