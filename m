From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET is
 enabled
Date: Tue, 3 Nov 2015 21:00:12 +0000
Message-ID: <BN1PR0301MB0770737810188CE2573A42CACA2B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <BN1PR0301MB07704B4966A54DC679505962CA2B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	<20151103.132015.944876907781932861.davem@davemloft.net>
	<BN1PR0301MB07708CE383BA67E83C161370CA2B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <20151103.145027.1401610638879230478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	KY Srinivasan <kys@microsoft.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0136.outbound.protection.outlook.com ([157.56.110.136]:21152
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755304AbbKCVPS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 16:15:18 -0500
In-Reply-To: <20151103.145027.1401610638879230478.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, November 3, 2015 2:50 PM
> To: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: eric.dumazet@gmail.com; KY Srinivasan <kys@microsoft.com>;
> edumazet@google.com; netdev@vger.kernel.org
> Subject: Re: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET
> is enabled
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Tue, 3 Nov 2015 18:49:05 +0000
> 
> >> -----Original Message-----
> >> From: David Miller [mailto:davem@davemloft.net]
> >> Sent: Tuesday, November 3, 2015 1:20 PM
> >> To: Haiyang Zhang <haiyangz@microsoft.com>
> >> Cc: eric.dumazet@gmail.com; KY Srinivasan <kys@microsoft.com>;
> >> edumazet@google.com; netdev@vger.kernel.org
> >> Subject: Re: [PATCH net-next] net: increase LL_MAX_HEADER if
> >> HYPERV_NET is enabled
> >>
> >> From: Haiyang Zhang <haiyangz@microsoft.com>
> >> Date: Tue, 3 Nov 2015 17:34:47 +0000
> >>
> >> > But we still keep this busy return in our code, just for "weird corner
> cases".
> >>
> >> The queue_stopped condition must be precise.
> >
> > The only case we return NETDEV_TX_BUSY is when the outgoing ring
> > buffer is full, which almost never happens because we stop the xmit queue
> if ring is <10% available.
> 
> I don't think you understand.
> 
> You must perform the queue stop operation such that it is impossible for
> your
> ->ndo_start_xmit() method to be invoked in a way such that you cannot
> ->transmit
> the SKB given to you immediately.

We already did the queue stop operation in the netvsc_send_pkt() in file netvsc.c:
		if (ring_avail < RING_AVAIL_PERCENT_LOWATER) {
			netif_tx_stop_queue(netdev_get_tx_queue(ndev, q_idx));
This flow control mechanism stops the tx queue when the outgoing buffer on vmbus 
is <10% available. So we can always transmit immediately when start_xmit is called.

The case of returning NETDEV_TX_BUSY is not expected to happen normally.

Thanks,
- Haiyang

> 
> It's quite tiring to keep trying to explain this over and over repeatedly.
