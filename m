From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/ipv4: Use non-atomic allocation of udp
 offloads structure instance
Date: Thu, 30 Jan 2014 16:26:27 -0800 (PST)
Message-ID: <20140130.162627.1742758630829288487.davem@davemloft.net>
References: <1391011739-8597-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492AbaAaA02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 19:26:28 -0500
In-Reply-To: <1391011739-8597-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 29 Jan 2014 18:08:59 +0200

> Since udp_add_offload() can be called from non-sleepable context e.g
> under this call tree from the vxlan driver use case:
> 
>   vxlan_socket_create() <-- holds the spinlock
>   -> vxlan_notify_add_rx_port()
>      -> udp_add_offload()  <-- schedules
> 
> we should allocate the udp_offloads structure in atomic manner.
> 
> Fixes: b582ef0 ('net: Add GRO support for UDP encapsulating protocols')
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied.
