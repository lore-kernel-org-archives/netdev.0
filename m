From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Sat, 21 Mar 2015 08:57:56 +1100
Message-ID: <20150320215756.GA24045@gondor.apana.org.au>
References: <20150316091415.GA31089@gondor.apana.org.au>
 <20150316111345.GA22070@acer.localdomain>
 <20150320085509.GA16748@gondor.apana.org.au>
 <20150320092216.GE21258@acer.localdomain>
 <20150320092703.GA17081@gondor.apana.org.au>
 <20150320095908.GG21258@acer.localdomain>
 <20150320101603.GA17662@gondor.apana.org.au>
 <20150320102701.GA28736@acer.localdomain>
 <20150320214712.GA23963@gondor.apana.org.au>
 <20150320215612.GA566@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:43046 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbbCTV6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:58:03 -0400
Content-Disposition: inline
In-Reply-To: <20150320215612.GA566@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 09:56:12PM +0000, Thomas Graf wrote:
> On 03/21/15 at 08:47am, Herbert Xu wrote:
> > On Fri, Mar 20, 2015 at 10:27:01AM +0000, Patrick McHardy wrote:
> > > On 20.03, Herbert Xu wrote:
> > >
> > > > Any hash function can be attacked.  That's why we need to be able
> > > > to rehash it.  And the best way to decide when to rehash is based
> > > > on chain length (otherwise you'd waste time rehashing periodically
> > > > like we used to do).  With name spaces these days anyone could be
> > > > an adversary.
> > > 
> > > We already had this discussion. I strongly do not believe this is
> > > the right way to fix namespace problems. There are millions of ways
> > > of creating CPU intensive workloads. You need to be able to put
> > > bounds on the entire namespace. Fixing individual spots will not
> > > solve that problem.
> > 
> > A CPU intensive workload that can be rescheduled is completely
> > different from one that is running under spin lock with BH disabled.
> 
> Just make the chain length based growth function configurable
> and nft_hash can disable it. nft_hash entries are not created by
> unprivileged users so attacking the table is out of the question.

Please read the quoted text, we're talking about potential attacks
on nft_hash.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
