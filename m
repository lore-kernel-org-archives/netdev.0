From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/14] net: extend busy polling support
Date: Wed, 18 Nov 2015 16:18:26 -0500 (EST)
Message-ID: <20151118.161826.1686345343654337694.davem@davemloft.net>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eliezer.tamir@linux.intel.com,
	eli@mellanox.com, eugenia@mellanox.com, ariel.elior@qlogic.com,
	willemb@google.com, rida@google.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757179AbbKRVSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 16:18:31 -0500
In-Reply-To: <1447857063-618-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed, 18 Nov 2015 06:30:49 -0800

> This patch series extends busy polling range to tunnels devices,
> and adds busy polling generic support to all NAPI drivers.
> 
> No need to provide ndo_busy_poll() method and extra synchronization
> between ndo_busy_poll() and normal napi->poll() method.
> This was proven very difficult and bug prone.
> 
> mlx5 driver is changed to support busy polling using this new method,
> and a second mlx5 patch adds napi_complete_done() support and proper
> SNMP accounting.
> 
> bnx2x and mlx4 drivers are converted to new infrastructure,
> reducing kernel bloat and improving performance.
> 
> Latest patch, adding generic support, adds a new requirement :
> 
>  -free_netdev() and netif_napi_del() must be called from process context.
> 
> Since this might not be the case in some drivers, we might have to
> either : fix the non conformant drivers (by disabling busy polling on them)
> or revert this last patch.

I like this series a lot, and hope we can fix any fallout quickly and
painlessly.

Applied to net-next.
