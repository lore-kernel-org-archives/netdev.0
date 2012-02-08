From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Wed, 08 Feb 2012 15:18:37 -0500 (EST)
Message-ID: <20120208.151837.75403230557283008.davem@davemloft.net>
References: <20120202101141.GC23142@secunet.com>
	<20120206.152916.224032109057159733.davem@davemloft.net>
	<20120208073037.GI23142@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab2BHUT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 15:19:57 -0500
In-Reply-To: <20120208073037.GI23142@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 8 Feb 2012 08:30:37 +0100

> On Mon, Feb 06, 2012 at 03:29:16PM -0500, David Miller wrote:
>> 
>> Thinking about this, it seems overkill to check this on every metric
>> access.
>> 
>> You have an opportunity to validate metrics when the peer is bound to
>> the route.
>> 
>> This is because any change to the FIB metrics, is in turn a change
>> to the FIB, which therefore invalidates the entire routing cache.
>> 
>> So you can be sure that a new route cache entry will be created, and
>> at that creation time you can ensure that we'll respect the updated
>> FIB metrics if encessary.
> 
> Not sure if I get you right here, but that's what this patchset
> does. It invalidates the metrics on the peer by incrementing
> peer_genid in rt_cache_invalidate() which is invoked on every FIB
> change. Then, on slowpath route lookup it checks in rt_init_metrics()
> whether the peer_genid changed. If it changed, it exchanges the
> invalidated merics with new ones and copies the informations from
> the FIB into it.

If the routing cache is invalided, you'll "see" this updated inetpeer
because every single routing cache entry will get rebuilt.
