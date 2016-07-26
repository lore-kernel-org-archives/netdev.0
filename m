From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/2] Mellanox 100G mlx5 minimum inline
 header mode
Date: Mon, 25 Jul 2016 17:54:36 -0700 (PDT)
Message-ID: <20160725.175436.969233393280158279.davem@davemloft.net>
References: <1469365960-27100-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, hadarh@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868AbcGZAyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 20:54:37 -0400
In-Reply-To: <1469365960-27100-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Sun, 24 Jul 2016 16:12:38 +0300

> This small series from Hadar adds the support for minimum inline
> header mode query in mlx5e NIC driver.
> 
> Today on TX the driver copies to the HW descriptor only up to L2
> header which is the default required mode and sufficient for today's
> needs.
> 
> The header in the HW descriptor is used for HW loopback steering
> decision, without it packets will go directly to the wire with no
> questions asked.
> 
> For TX loopback steering according to L2/L3/L4 headers, ConnectX-4
> requires to copy the corresponding headers into the send queue(SQ)
> WQE HW descriptor so it can decide whether to loop it back or to
> forward to wire.
> 
> For legacy E-Switch mode only L2 headers copy is required.  For
> advanced steering (E-Switch offloads) more header layers may be
> required to be copied, the required mode will be advertised by FW to
> each VF and PF according to the corresponding E-Switch
> configuration.
> 
> Changes V2:
>  - Allocate query_nic_vport_context_out on the stack

Applied, but even doing an eth_get_headlen() every transmitted packet
it really too expensive.

You shouldn't be touching networking headers so much when forwarding
frames.
