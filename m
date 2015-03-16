From: David Miller <davem@davemloft.net>
Subject: Re: [v1 PATCH 0/14] rhashtable: Kill shift/Key netlink
 namespace/Merge jhash
Date: Mon, 16 Mar 2015 00:30:49 -0400 (EDT)
Message-ID: <20150316.003049.1368221798557474722.davem@davemloft.net>
References: <20150315104306.GA21999@gondor.apana.org.au>
	<20150316.000113.1803291537029624713.davem@davemloft.net>
	<20150316041805.GA28946@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbbCPEav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:30:51 -0400
In-Reply-To: <20150316041805.GA28946@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 16 Mar 2015 15:18:05 +1100

> On Mon, Mar 16, 2015 at 12:01:13AM -0400, David Miller wrote:
>> From: Herbert Xu <herbert@gondor.apana.org.au>
>> Date: Sun, 15 Mar 2015 21:43:06 +1100
>> 
>> > PS I'd love to kill the indirect call on the hash but I think
>> > you guys need something other than jhash for sockets.  Presumably
>> > they are not exposed to untrusted parties.  But I really wonder
>> > whether that is still the case given things like namespaces where
>> > even root may be untrusted.
>> 
>> In my opinion the biggest architectural fault of rhashtables is
>> these damn callbacks, look at the assembler for a simple hash
>> lookup, it's disgusting.
> 
> Well if everybody used jhash the indirect call would go away...

The other issue is that some hashes are per-ns and thus don't
need the namespace hash and comparison, whilst others do.
