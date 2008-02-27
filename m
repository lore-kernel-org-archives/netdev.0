From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
	netif_rx()
Date: Wed, 27 Feb 2008 07:20:41 +0000
Message-ID: <20080227072041.GA4000@ff.dom.local>
References: <20080226.182120.183405235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:13853 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818AbYB0HTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 02:19:38 -0500
Received: by ug-out-1314.google.com with SMTP id z38so204775ugc.16
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 23:19:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080226.182120.183405235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27-02-2008 03:21, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 21 Feb 2008 19:51:52 +0100
> 
>> Following patch directly calls netif_receive_skb() and avoids lot of 
>> atomic operations.
>> (atomic_inc(&dev->refcnt), set_and_set_bit(NAPI_STATE_SCHED, &n->state), ...
>>   atomic_dec(&dev->refcnt)...), cache line ping-pongs on device refcnt, 
>> but also softirq overhead.
>>
>> This gives a nice boost on tbench for example (5 % on my machine)
> 
> My only concern is stack usage.
...

I wonder why overloading with net processing is no concern here?
There would be no napi control around this  netif_receive_skb().

Another concern might be a code which depends on softirq context
here (unless it was checked already)?

Regards,
Jarek P.
