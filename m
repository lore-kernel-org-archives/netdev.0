From: David Miller <davem@davemloft.net>
Subject: Re: [v1 PATCH 0/14] rhashtable: Kill shift/Key netlink
 namespace/Merge jhash
Date: Mon, 16 Mar 2015 00:40:17 -0400 (EDT)
Message-ID: <20150316.004017.1903871383239941874.davem@davemloft.net>
References: <20150316041805.GA28946@gondor.apana.org.au>
	<20150316.003049.1368221798557474722.davem@davemloft.net>
	<20150316043359.GA29124@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbCPEkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:40:19 -0400
In-Reply-To: <20150316043359.GA29124@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 16 Mar 2015 15:33:59 +1100

> On Mon, Mar 16, 2015 at 12:30:49AM -0400, David Miller wrote:
>>
>> > Well if everybody used jhash the indirect call would go away...
>> 
>> The other issue is that some hashes are per-ns and thus don't
>> need the namespace hash and comparison, whilst others do.
> 
> That's just a matter of what goes into the key.  IOW if your
> table is global then you include the namespace in the hash,
> otherwise you don't.  It shouldn't change the hash function.
> 
> Have a look at what I did to netlink in patch 9.  If you wanted
> a per-namespace hash table it is as simple as getting rid of
> obj_hashfn and just reducing the key to have just the portid.

I know, reading the hash callback adjusting patches is what
prompted me to start this conversation about inlining the
lookup.

Patrick McHardy had mentioned to me his consternation about this issue
offhand the other week, and I've just failed to get around to bringing
it up :-)
