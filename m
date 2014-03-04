From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] unix: add read side socket memory
 accounting for dgram sockets
Date: Tue, 04 Mar 2014 15:37:32 -0500 (EST)
Message-ID: <20140304.153732.1314382655798460205.davem@davemloft.net>
References: <20140226202154.GA9626@order.stressinduktion.org>
	<20140226.154232.1642777813885536970.davem@davemloft.net>
	<20140304201336.GB26307@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	eric.dumazet@gmail.com, xiyou.wangcong@gmail.com, dan@mindstab.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623AbaCDUhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 15:37:34 -0500
In-Reply-To: <20140304201336.GB26307@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 4 Mar 2014 21:13:36 +0100

> Just a small followup:
> 
> Because of the additional sock_wfree during skb handover in unix_dgram_sendmsg
> the spinlock in __wake_up_sync_key is hit more often thus more cacheline
> bouncing.
> 
> Deferring the POLLOUT notification after the sock_rfree in unix_dgram_recvmsg
> already halfed the number of context switches with the new patch.
> 
> I try to play with some other ideas this week and will submit new patch with
> performance numbers.
> 
> Haven't noticed any problems with the additional atomic operations
> performance-wise so far.

Ok, thanks for the update.
