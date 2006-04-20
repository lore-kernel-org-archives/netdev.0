From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb->truesize assertion checking for TCP
Date: Wed, 19 Apr 2006 23:17:03 -0700 (PDT)
Message-ID: <20060419.231703.35841080.davem@davemloft.net>
References: <20060419.215513.13034269.davem@davemloft.net>
	<20060420050406.GA22105@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28365
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751102AbWDTGRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 02:17:23 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060420050406.GA22105@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 20 Apr 2006 15:04:06 +1000

> On Wed, Apr 19, 2006 at 09:55:13PM -0700, David S. Miller wrote:
> > +static inline void skb_truesize_check(struct sk_buff *skb)
> > +{
> > +	if (unlikely((int)skb->truesize < sizeof(struct sk_buff)))
> > +		skb_truesize_bug(skb);
> > +}
> 
> I think we can go for the stronger test:
> 
> skb->truesize < sizeof(struct sk_buff) + skb->len

Agreed, let me see if that triggers on my machine before
I commit this :-)
