From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Thu, 14 May 2015 23:46:15 -0400 (EDT)
Message-ID: <20150514.234615.235930228362522399.davem@davemloft.net>
References: <20150513080640.GA27800@gondor.apana.org.au>
	<20150514.222217.1991822787577994078.davem@davemloft.net>
	<20150515030623.GA14994@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org, kaber@trash.net,
	tgraf@suug.ch, johannes.berg@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422675AbbEODqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 23:46:19 -0400
In-Reply-To: <20150515030623.GA14994@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 15 May 2015 11:06:23 +0800

> On Thu, May 14, 2015 at 10:22:17PM -0400, David Miller wrote:
>>
>> In my opinion, up to at least 2 X max_size, it's safe to allow the
>> insert.  Assuming a well choosen hash function and a roughly even
>> distribution.
> 
> OK I can make it 2 x max_size/table size.

The rest of my email after what you quoted was intended to get one
to consider this issue generally.  :-)

We wouldn't fail these inserts in any other hash table in the kernel.

Would we stop making new TCP sockets if the TCP ehash chains are 3
entries deep?  4?  5?  The answer to all of those is of course no
for any hash chain length of N whatsoever.

This new rhashtable behavior would be the default, and I seriously
doubt that's a behavior people who use a hash table, generally
speaking, desire or want.

Should there perhaps be hard protections for _extremely_ long hash
chains?  Sure, I'm willing to entertain that kind of idea.  But I
would do so at the very far end of the spectrum.  To the point where
the hash table is degenerating into a linked list.
