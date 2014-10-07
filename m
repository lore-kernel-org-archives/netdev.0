From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_en: remove NETDEV_TX_BUSY
Date: Tue, 07 Oct 2014 13:21:02 -0400 (EDT)
Message-ID: <20141007.132102.2147742408943394634.davem@davemloft.net>
References: <1412599904.11091.66.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412613035.11091.72.camel@edumazet-glaptop2.roam.corp.google.com>
	<5433A48E.1040505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, idos@mellanox.com
To: amirv@mellanox.com, amirv.mellanox@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371AbaJGRVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:21:05 -0400
In-Reply-To: <5433A48E.1040505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv.mellanox@gmail.com>
Date: Tue, 07 Oct 2014 11:30:06 +0300

> On 10/6/2014 7:30 PM, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> Drivers should avoid NETDEV_TX_BUSY as much as possible.
>> 
>> They should stop the tx queue before qdisc even tries to push another
>> packet, to avoid requeues.
>> 
>> For a driver supporting skb->xmit_more, this is likely to be a prereq
>> anyway, otherwise we could have a tx deadlock : We need to force a
>> doorbell if TX ring is full.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> ---
> 
> Reviewed. Also verified that it fixes the deadlock (by sending a large
> burst - larger than ring size). Before this fix, last packet of the
> burst wasn't sent, therefore no doorbell was rang, and the queue was
> stalled.
> 
> BTW, another nice optimization that we hope to send soon, is not to arm
> the CQ unless ringing the doorbell.
> 
> Acked-by: Amir Vadai <amirv@mellanox.com>

Applied, thanks everyone.
