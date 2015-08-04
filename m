From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Fix skb_set_peeked use-after-free bug
Date: Tue, 4 Aug 2015 09:24:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB727D0@AcuExch.aculab.com>
References: <CAMUH3-WyNR+2tsKgZ2qMNR=p+2Q3WDjcPrQcVSZfVSVyPA1qoA@mail.gmail.com>
 <20150804074247.GA29951@gondor.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB7275E@AcuExch.aculab.com>
 <20150804092059.GA27668@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"khlebnikov@yandex-team.ru" <khlebnikov@yandex-team.ru>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:64933 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932416AbbHDJ1n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 05:27:43 -0400
In-Reply-To: <20150804092059.GA27668@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> Sent: 04 August 2015 10:21
> On Tue, Aug 04, 2015 at 09:15:13AM +0000, David Laight wrote:
> >
> > You've introduced a memory leak if skb_clone() fails.
> 
> No I have not.
> 
> > >  	nskb = skb_clone(skb, GFP_ATOMIC);
> > >  	if (!nskb)
> > > -		return -ENOMEM;
> > > +		return ERR_PTR(-ENOMEM);
> >
> > Here the original skb is still allocated.
> >
> > > -				error = skb_set_peeked(skb);
> > > -				if (error)
> > > +				skb = skb_set_peeked(skb);
> >
> > You've now lost the address of the original skb.
> 
> It doesn't matter because we will take the error path and return
> the ENOMEM error.  We must not free the skb as it's still on the
> recv queue.

In that case, what happens to the receive queue when skb_clone()
takes a copy of the skb - freeing the original one?

	David
