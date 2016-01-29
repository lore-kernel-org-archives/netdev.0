From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net/mlx5e: Use a private copy of netdev ops
Date: Thu, 28 Jan 2016 20:00:38 -0800 (PST)
Message-ID: <20160128.200038.1283811216884732396.davem@davemloft.net>
References: <1453906945-25414-1-git-send-email-ogerlitz@mellanox.com>
	<1453906945-25414-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, saeedm@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbcA2EAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 23:00:42 -0500
In-Reply-To: <1453906945-25414-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 27 Jan 2016 17:02:25 +0200

> From: Saeed Mahameed <saeedm@mellanox.com>
> 
> Currently our netdevice ops is a static global variable which
> is referenced by all mlx5e netdevice instances. This can be
> problematic when different driver instances do not share same
> HW capabilities (e.g SRIOV PF and VFs probed to the host).
> 
> Remove the global variable and add a private net_device_ops
> field in netdevice private data, which is initialized at
> netdev construction.
> 
> Fixes: 66e49dedada6 ("net/mlx5e: Add support for SR-IOV ndos")
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

This is not the canonical way to fix this.  Please look at how
other drivers handle this situation before inventing your own
way of solving the problem.

The proper way is to have multiple netdevice ops instances, and simply
choose the one which is correct for the chip in question.

You should also mark the ops as const.  They should never _ever_ be
modified at runtime.
