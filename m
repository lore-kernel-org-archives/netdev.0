From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix multiqueue selection
Date: Wed, 11 Sep 2013 16:13:36 -0400 (EDT)
Message-ID: <20130911.161336.533952405072438938.davem@davemloft.net>
References: <1378580577.26319.26.camel@edumazet-glaptop>
	<522BF85B.3000909@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756848Ab3IKUNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 16:13:38 -0400
In-Reply-To: <522BF85B.3000909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Sat, 07 Sep 2013 21:08:59 -0700

> On 09/07/2013 12:02 PM, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> commit 416186fbf8c5b4e4465 ("net: Split core bits of netdev_pick_tx
>> into __netdev_pick_tx") added a bug that disables caching of queue
>> index in the socket.
>> 
>> This is the source of packet reorders for TCP flows, and
>> again this is happening more often when using FQ pacing.
>> 
>> Old code was doing 
>> 
>> if (queue_index != old_index)
>> 	sk_tx_queue_set(sk, queue_index);
>> 
>> Alexander renamed the variables but forgot to change sk_tx_queue_set()
>> 2nd parameter.
>> 
>> if (queue_index != new_index)
>> 	sk_tx_queue_set(sk, queue_index);
>> 
>> This means we store -1 over and over in sk->sk_tx_queue_mapping
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
 ...
> Ugh, my bad.  This is a nasty one too since the behaviour appeared to be
> correct for most cases.
> 
> It looks like this needs to go into stable for 3.9 - 3.11.
> 
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
> 

Applied and queued up for -stable, thanks.
