From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] sunvnet: make transmit path zero-copy in
 the kernel
Date: Mon, 29 Sep 2014 14:58:15 -0400 (EDT)
Message-ID: <20140929.145815.1751251065603753225.davem@davemloft.net>
References: <54299407.7010705@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	Raghuram.Kothakota@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbaI2S6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 14:58:17 -0400
In-Reply-To: <54299407.7010705@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Mon, 29 Sep 2014 13:16:55 -0400

> This patch removes pre-allocated transmit buffers and instead directly maps
> pending packets on demand. This saves O(n^2) maximum-sized transmit buffers,
> for n hosts on a vswitch, as well as a copy to those buffers.
> 
> Single-stream TCP throughput linux-solaris dropped ~5% for 1500-byte MTU,
> but linux-linux at 1500-bytes increased ~20%.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

Awesome!!!

However:

>  	dr->ncookies = ncookies;
>  +	for (i = 0; i < VNET_TX_RING_SIZE; ++i) {
> +		struct vio_net_desc *d;
> 

I see a lot of this, I think your patch is corrupted.
