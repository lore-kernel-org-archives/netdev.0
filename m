From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: mlx4_en_netpoll shouldn't call
 napi_schedule when port is down
Date: Mon, 29 Sep 2014 13:47:04 -0400 (EDT)
Message-ID: <20140929.134704.646626597842088240.davem@davemloft.net>
References: <1411988695-30547-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: idos@mellanox.com, netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbaI2RrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 13:47:07 -0400
In-Reply-To: <1411988695-30547-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon, 29 Sep 2014 14:04:55 +0300

> From: Ido Shamay <idos@mellanox.com>
> 
> mlx4_en_netpoll, which is mlx4_en ndo_poll_controller callback,
> might be called when port is down, causing a napi_schedule when
> napi->poll callback in NULL. mutex_trylock is needed to acquire
> the port_state lock, since other threads may grab it and stop
> the port while we are in napi scheduling. Using trylock since in atomic
> context.
> 
> Signed-off-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

I don't think netpoll should 'variably succeed' on poll controller's
ability to immediately take a trylock.

You need to find a way to make this code always process the queues
when it is called, the approach you are taking here is not a correct.

If you've designed things in such a way that the locking here is
difficult, that's unfortunate but you still have to make this
function behave properly.
