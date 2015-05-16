From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Sat, 16 May 2015 18:09:46 -0400 (EDT)
Message-ID: <20150516.180946.2182730749654333791.davem@davemloft.net>
References: <20150515030623.GA14994@gondor.apana.org.au>
	<20150514.234615.235930228362522399.davem@davemloft.net>
	<20150515063057.GA16440@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org, kaber@trash.net,
	tgraf@suug.ch, johannes.berg@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbbEPWJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 18:09:48 -0400
In-Reply-To: <20150515063057.GA16440@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 15 May 2015 14:30:57 +0800

> On Thu, May 14, 2015 at 11:46:15PM -0400, David Miller wrote:
>> 
>> We wouldn't fail these inserts in any other hash table in the kernel.
>> 
>> Would we stop making new TCP sockets if the TCP ehash chains are 3
>> entries deep?  4?  5?  The answer to all of those is of course no
>> for any hash chain length of N whatsoever.
> 
> I would agree with you if this was a fixed sized table.  If your
> table grows with you (which is the whole point of rhashtable) then
> we should never hit this until you run out of memory.
> 
> When you are running out of memory whether you fail when the table
> growth fails or later when you can't even allocate an entry is
> immaterial because failure is inevitable.
> 
> In my view everybody should be using rhashtable without a maximum
> size.  The only place where it would make sense to have a maximum
> size limit is if you also had a limit on the number of entries.
> In which cas you might as well make that the limit on the hash table
> size.

Ok, agreed.

>> Should there perhaps be hard protections for _extremely_ long hash
>> chains?  Sure, I'm willing to entertain that kind of idea.  But I
>> would do so at the very far end of the spectrum.  To the point where
>> the hash table is degenerating into a linked list.
> 
> Do you have any suggestions of what such a limit should be?

Good question.

Obviously something like 50 or 100 is too much.

Perhaps something between 5 and 10.

That's just my gut instinct speaking.
