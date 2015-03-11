From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 11 Mar 2015 17:42:41 +1100
Message-ID: <20150311064241.GA7153@gondor.apana.org.au>
References: <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, David.Laight@aculab.com, davem@davemloft.net,
	tgraf@suug.ch, pablo@netfilter.org, johunt@akamai.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:52066 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbbCKGnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 02:43:42 -0400
Content-Disposition: inline
In-Reply-To: <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-02-25 at 17:14 +0100, Daniel Borkmann wrote:
> 
>> The nelems can be a percpu_counter where we have a batched sync
>> point and can make that dependent on the current table shift as
>> we don't need to be overly precise, we can just read the sync'ed
>> value. Currently, nelems are also being used by rhashtable users
>> outside of the core code to track if we are still allowed to
>> insert new elements, but I think we might also want to address
>> that at some point.
> 
> There is no need to track number of elements, using either an atomic_t
> or percpu_counter. This adds unnecessary burden.
> 
> 1) Automatic shrinking is a non issue. This will free very little
> memory, compared to previous peak usage (including objects put in
> rhashtable). If hash grown to a certain point, it's likely it will grow
> again later.
> 
> 2) Growing can be triggered when any bucket has more than X elems, and
> that is given for free at insert time.
> X could be log2(buckets)/2 I guess. (aka shift/2)
> 
> A global limit on number of elements should be controlled by rhashtable
> users - if needed -, not in the rhashtable itself.

I agree in the strongest terms :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
