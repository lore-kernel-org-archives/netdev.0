From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Mon, 18 May 2015 16:12:01 -0400 (EDT)
Message-ID: <20150518.161201.1959117179761854761.davem@davemloft.net>
References: <20150515063057.GA16440@gondor.apana.org.au>
	<20150516.180946.2182730749654333791.davem@davemloft.net>
	<20150517013829.GB5161@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org, kaber@trash.net,
	tgraf@suug.ch, johannes.berg@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932302AbbERUME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 16:12:04 -0400
In-Reply-To: <20150517013829.GB5161@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 17 May 2015 09:38:29 +0800

> On Sat, May 16, 2015 at 06:09:46PM -0400, David Miller wrote:
>>
>> Obviously something like 50 or 100 is too much.
>> 
>> Perhaps something between 5 and 10.
> 
> You are even more parsimonious than I :) Because the maximum chain
> length grows at a rate of logN * loglogN, I had chosen the number
> 16 which should be sufficient even if you had a 2^32 table (which
> you currently can't as we max out somewhere below that).
> 
> FWIW Thomas did some numbers on this and apparent 10 gets breached
> in a 2^24 table at 100% utilisation.

Ok, this of course depends upon the distribution of the input data
and the strength/suitability of the hash function.

I'm a little bit disappointed in what Thomas found.  I would expect
the distribution to be at least a little bit better.
