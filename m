From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: fixup xdp tx irq to match rx
Date: Fri, 14 Oct 2016 11:14:21 -0400 (EDT)
Message-ID: <20161014.111421.755793293161214884.davem@davemloft.net>
References: <20161013201311.20844-1-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        ttoukan.linux@gmail.com, gerlitz.or@gmail.com,
        saeedm@dev.mellanox.co.il, brouer@redhat.com
To: bblanco@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48174 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752443AbcJNPOX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 11:14:23 -0400
In-Reply-To: <20161013201311.20844-1-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco <bblanco@plumgrid.com>
Date: Thu, 13 Oct 2016 13:13:11 -0700

> In cases where the number of tx rings is not a multiple of the number of
> rx rings, the tx completion event will be handled on a different core
> from the transmit and population of the ring. Races on the ring will
> lead to a double-free of the page, and possibly other corruption.
> 
> The rings are initialized by default with a valid multiple of rings,
> based on the number of cpus, therefore an invalid configuration requires
> ethtool to change the ring layout. For instance 'ethtool -L eth0 rx 9 tx
> 8' will cause packets received on rx0, and XDP_TX'd to tx48, to be
> completed on cpu3 (48 % 9 == 3).
> 
> Resolve this discrepancy by shifting the irq for the xdp tx queues to
> start again from 0, modulo rx_ring_num.
> 
> Fixes: 9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")
> Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Applied and queued up for -stable, thanks.
