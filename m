From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next FIX] RDMA/cma: Fix build breakage when
 infiniband is built-in
Date: Sun, 10 Nov 2013 21:03:55 -0500 (EST)
Message-ID: <20131110.210355.1669362951389274888.davem@davemloft.net>
References: <1384090080-1862-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, eyalpe@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003Ab3KKCEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Nov 2013 21:04:00 -0500
In-Reply-To: <1384090080-1862-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 10 Nov 2013 15:28:00 +0200

> From: Eyal Perry <eyalpe@mellanox.com>
> 
> Commit eb072c4 ("RDMA/cma: Set IBoE SL (user-priority) by egress map when using
> vlans"), broke the build when CONFIG_VLAN_8021Q=m and CONFIG_INFINIBAND=y,
> because the rdma_cm module attempted to call vlan_dev_get_egress_qos_mask()
> which in that case is a modular code being called from built-in kernel code.
> 
> Fix this by adding a Kconfig dependency to prevent the rdma_cm code from being
> built in when 8021Q is built modular, in a similar manner we do with IPv6.
> 
> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
> 
> Dave, this fixes an issue with the mentioned commit which is in net-next

Please just move vlan_dev_get_egress_qos_mask into include/linux/if_vlan.h
and make it an inline function.

These Kconfig restrictions are just beyond silly and unnecessary.

I bet the IPV6 one already there can be killed by moving some things
into net/ipv6/*_core.c files as well.
