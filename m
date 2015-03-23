From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: arp_hash
Date: Mon, 23 Mar 2015 22:01:33 +1100
Message-ID: <20150323110133.GA13359@gondor.apana.org.au>
References: <20150322213408.GC7925@gondor.apana.org.au>
 <20150322.185714.1793567801322787489.davem@davemloft.net>
 <20150322234218.GA9243@gondor.apana.org.au>
 <20150322.195315.643961269309745827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roland@purestorage.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:34772 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbbCWLBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 07:01:37 -0400
Content-Disposition: inline
In-Reply-To: <20150322.195315.643961269309745827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 07:53:15PM -0400, David Miller wrote:
>
> We want no reference counting of the neighbour entries, that's one of
> the main points of all this.
> 
> That way packets getting stuck do not run into the classic
> dreaded "Neighbour table overflow", remember that?

Right.

> THAT is what is attackable when people have /8 subnets and
> someone just spam pings every host on that subnet.
> 
> That is a more serious exposure than this hashing issue.
> 
> At least with ref-less use, as we have now, we could trim hash chains
> that get too large with almost no barriers whatsoever because nearly
> every neigh entry has no external references outside of these demux
> sequences.

Yes if we trim the buckets to keep the chain length under a limit
it should be good enough I think.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
