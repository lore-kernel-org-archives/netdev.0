From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] macvlan: add multiqueue capability
Date: Thu, 03 Sep 2009 19:54:04 +0200
Message-ID: <4AA002BC.3050507@trash.net>
References: <4A9F9661.7020301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44450 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753642AbZICRyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 13:54:05 -0400
In-Reply-To: <4A9F9661.7020301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> macvlan devices are currently not multi-queue capable.
> 
> We can do that defining rtnl_link_ops method,
> get_tx_queues(), called from rtnl_create_link()
> 
> This new method gets num_tx_queues/real_num_tx_queues
> from lower device.
> 
> macvlan_get_tx_queues() is a copy of vlan_get_tx_queues().
> 
> Because macvlan_start_xmit() has to update netdev_queue
> stats only (and not dev->stats), I chose to change
> tx_errors/tx_aborted_errors accounting to tx_dropped,
> since netdev_queue structure doesnt define tx_errors /
> tx_aborted_errors.

The patch looks fine, but it just occured to me that this won't
have any effect since both VLAN and macvlan use a tx_queue_len of 0,
so they will by default have queueing disabled. In fact this
will increase costs for the default case since we're now hashing
every packet.
