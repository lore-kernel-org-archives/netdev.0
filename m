From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: remove synchronize_net() from
 netdev_set_master()
Date: Sun, 22 May 2011 21:03:26 -0400 (EDT)
Message-ID: <20110522.210326.1316361026223897933.davem@davemloft.net>
References: <1305869860.3156.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, jpirko@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727Ab1EWBDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 21:03:30 -0400
In-Reply-To: <1305869860.3156.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 May 2011 07:37:40 +0200

> In the old days, we used to access dev->master in __netif_receive_skb()
> in a rcu_read_lock section.
> 
> So one synchronize_net() call was needed in netdev_set_master() to make
> sure another cpu could not use old master while/after we release it.
> 
> We now use netdev_rx_handler infrastructure and added one
> synchronize_net() call in bond_release()/bond_release_all()
> 
> Remove the obsolete synchronize_net() from netdev_set_master() and add
> one in bridge del_nbp() after its netdev_rx_handler_unregister() call.
> 
> This makes enslave -d a bit faster.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jiri Pirko <jpirko@redhat.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>

Applied.
