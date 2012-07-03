From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/19] neigh: Convert over to dst_neigh_lookup_skb().
Date: Tue, 03 Jul 2012 16:18:38 -0700 (PDT)
Message-ID: <20120703.161838.1454152280922745017.davem@davemloft.net>
References: <20120703.024644.638173463391088464.davem@davemloft.net>
	<1341353309.2839.19.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913Ab2GCXSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 19:18:39 -0400
In-Reply-To: <1341353309.2839.19.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 3 Jul 2012 23:08:29 +0100

> On Tue, 2012-07-03 at 02:46 -0700, David Miller wrote:
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>  net/core/neighbour.c |   10 ++++++++--
>>  1 file changed, 8 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>> index a793af9..eb3efdc 100644
>> --- a/net/core/neighbour.c
>> +++ b/net/core/neighbour.c
>> @@ -1202,9 +1202,15 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
>>  
>>  			rcu_read_lock();
>>  			/* On shaper/eql skb->dst->neighbour != neigh :( */
> 
> It might be time to delete that comment too.

It's still accurate, so it needs to be adjusted rather then removed.
sch_teql creates this situation as well.

What this code is effectively doing is reinjecting the packet back to
the top-most neigh, and it will filter back down to the thing that
uses a different neigh for packet output.
