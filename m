From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] xfrm: Fix crash observed during device
 unregistration and decryption
Date: Wed, 23 Mar 2016 22:08:20 -0400 (EDT)
Message-ID: <20160323.220820.1513725139701314911.davem@davemloft.net>
References: <1458754165.10868.41.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160324004514.GA3110@gondor.apana.org.au>
	<1458783597.10868.60.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, subashab@codeaurora.org,
	steffen.klassert@secunet.com, netdev@vger.kernel.org,
	jeromes@codeaurora.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38093 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbcCXCIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 22:08:23 -0400
In-Reply-To: <1458783597.10868.60.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Mar 2016 18:39:57 -0700

> On Thu, 2016-03-24 at 08:45 +0800, Herbert Xu wrote:
>> On Wed, Mar 23, 2016 at 10:29:25AM -0700, Eric Dumazet wrote:
>> >
>> > OK, but before calling netif_rx() are we properly testing dev->flags
>> > IFF_UP status ?
>> > 
>> > Otherwise, we still allow packets being queued after flush_backlog() had
>> > been called.
>> 
>> That's the first thing enqueue_to_backlog tests.
>> 
>> Cheers,
> 
> Seems to be very recent stuff ( commit
> e9e4dd3267d0c5234c5c0f47440456b10875dec9 in linux-4.2)
> 
> In the old days the test was done in callers, since in most cases NIC
> drivers do not need it.
> 
> Lets make sure this was backported to all stable trees.
> 
> And then we probably can cleanup some callers as well.

Anyways this patch needs to be redone because it is corrupted by the
submitter's email client.

I'll queue it up and make sure e9e4dd3267d0c5234c5c0f47440456b10875dec9
ends up in -stable where needed.

Thanks.
