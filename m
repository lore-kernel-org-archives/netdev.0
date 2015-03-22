From: David Miller <davem@davemloft.net>
Subject: Re: arp_hash
Date: Sun, 22 Mar 2015 19:53:15 -0400 (EDT)
Message-ID: <20150322.195315.643961269309745827.davem@davemloft.net>
References: <20150322213408.GC7925@gondor.apana.org.au>
	<20150322.185714.1793567801322787489.davem@davemloft.net>
	<20150322234218.GA9243@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@purestorage.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbbCVXxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 19:53:17 -0400
In-Reply-To: <20150322234218.GA9243@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 23 Mar 2015 10:42:18 +1100

> On Sun, Mar 22, 2015 at 06:57:14PM -0400, David Miller wrote:
>> From: Herbert Xu <herbert@gondor.apana.org.au>
>> Date: Mon, 23 Mar 2015 08:34:08 +1100
>> 
>> > So what scales we are talking about, twice, three times? Have you
>> > considered more modern hashes such as SipHash or SpookyHash
>> > (successor to jhash/lookup3 and supposedly faster)?
>> 
>> I want it to be one cycle or two.
>> 
>> Every single transmitted packet hits this hash demux.
> 
> For hosts can we cache this? For routers I guess this is just
> the mummified remains of the route cache :)

We want no reference counting of the neighbour entries, that's one of
the main points of all this.

That way packets getting stuck do not run into the classic
dreaded "Neighbour table overflow", remember that?

THAT is what is attackable when people have /8 subnets and
someone just spam pings every host on that subnet.

That is a more serious exposure than this hashing issue.

At least with ref-less use, as we have now, we could trim hash chains
that get too large with almost no barriers whatsoever because nearly
every neigh entry has no external references outside of these demux
sequences.
