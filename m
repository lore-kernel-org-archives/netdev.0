From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvlan: fix a race on port dismantle and possible
 skb leaks
Date: Sat, 25 Oct 2014 16:24:21 -0400 (EDT)
Message-ID: <20141025.162421.21065553248053378.davem@davemloft.net>
References: <1414032226.2094.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141023032858.GA1836@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbaJYUYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 16:24:23 -0400
In-Reply-To: <20141023032858.GA1836@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 23 Oct 2014 11:28:58 +0800

> On Wed, Oct 22, 2014 at 07:43:46PM -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> We need to cancel the work queue after rcu grace period,
>> otherwise it can be rescheduled by incoming packets.
>> 
>> We need to purge queue if some skbs are still in it.
>> 
>> We can use __skb_queue_head_init() variant in
>> macvlan_process_broadcast()
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Fixes: 412ca1550cbec ("macvlan: Move broadcasts into a work queue")
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Good catch! Your fix looks good to me.

Applied and queued up for -stable, thanks everyone.
