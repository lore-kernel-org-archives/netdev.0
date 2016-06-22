From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] team: Fix possible deadlock during team enslave
Date: Wed, 22 Jun 2016 16:32:55 -0400 (EDT)
Message-ID: <20160622.163255.468340273801025129.davem@davemloft.net>
References: <1466412800-18400-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	lucien.xin@gmail.com
To: idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbcFVUdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 16:33:02 -0400
In-Reply-To: <1466412800-18400-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>
Date: Mon, 20 Jun 2016 11:53:20 +0300

> Both dev_uc_sync_multiple() and dev_mc_sync_multiple() require the
> source device to be locked by netif_addr_lock_bh(), but this is missing
> in team's enslave function, so add it.
> 
> This fixes the following lockdep warning:
> 
> Possible interrupt unsafe locking scenario:
> 
>         CPU0                    CPU1
>         ----                    ----
>    lock(_xmit_ETHER/1);
>                                 local_irq_disable();
>                                 lock(&(&mc->mca_lock)->rlock);
>                                 lock(&team_netdev_addr_lock_key);
>    <Interrupt>
>      lock(&(&mc->mca_lock)->rlock);
> 
>   *** DEADLOCK ***
> 
> Fixes: cb41c997d444 ("team: team should sync the port's uc/mc addrs when add a port")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>

Applied.
