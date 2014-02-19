From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] unix: add read side socket memory
 accounting for dgram sockets
Date: Wed, 19 Feb 2014 14:49:27 -0500 (EST)
Message-ID: <20140219.144927.1558282069067885839.davem@davemloft.net>
References: <20140217035826.GG8634@order.stressinduktion.org>
	<20140217130353.GA22833@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	eric.dumazet@gmail.com, xiyou.wangcong@gmail.com, dan@mindstab.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbaBST6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 14:58:11 -0500
In-Reply-To: <20140217130353.GA22833@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 17 Feb 2014 14:03:53 +0100

> We still allocate dgram packets with sock_alloc_send_pskb, which now
> does normally not block if the socket has too many packets in flight.

It seems like it does to me, it does sock_wait_for_wmem(), right?

Or are you trying to say that usually this is not the point at which
we block, but rather it's when we check the peer's receive queue?
