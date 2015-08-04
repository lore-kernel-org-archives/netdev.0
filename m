From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fix skb_set_peeked use-after-free bug
Date: Tue, 4 Aug 2015 17:20:59 +0800
Message-ID: <20150804092059.GA27668@gondor.apana.org.au>
References: <CAMUH3-WyNR+2tsKgZ2qMNR=p+2Q3WDjcPrQcVSZfVSVyPA1qoA@mail.gmail.com>
 <20150804074247.GA29951@gondor.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB7275E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"khlebnikov@yandex-team.ru" <khlebnikov@yandex-team.ru>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:60202 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbbHDJVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 05:21:09 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB7275E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 04, 2015 at 09:15:13AM +0000, David Laight wrote:
>
> You've introduced a memory leak if skb_clone() fails.

No I have not.

> >  	nskb = skb_clone(skb, GFP_ATOMIC);
> >  	if (!nskb)
> > -		return -ENOMEM;
> > +		return ERR_PTR(-ENOMEM);
> 
> Here the original skb is still allocated.
> 
> > -				error = skb_set_peeked(skb);
> > -				if (error)
> > +				skb = skb_set_peeked(skb);
> 
> You've now lost the address of the original skb.

It doesn't matter because we will take the error path and return
the ENOMEM error.  We must not free the skb as it's still on the
recv queue.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
