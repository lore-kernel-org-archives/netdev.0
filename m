From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/9] alx: refactor descriptor allocation
Date: Sun, 23 Oct 2016 11:50:12 -0400 (EDT)
Message-ID: <20161023.115012.1557996279582284252.davem@davemloft.net>
References: <cover.1477044917.git.tobias.regnery@gmail.com>
        <cover.1477044917.git.tobias.regnery@gmail.com>
        <4118b3b705404f4ce27aaa389697c12f5319aaef.1477044918.git.tobias.regnery@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org
To: tobias.regnery@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54038 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753174AbcJWPuU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 11:50:20 -0400
In-Reply-To: <4118b3b705404f4ce27aaa389697c12f5319aaef.1477044918.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Regnery <tobias.regnery@gmail.com>
Date: Fri, 21 Oct 2016 12:49:44 +0200

> +	txq->tpd = alx->descmem.virt + offset;
> +	txq->tpd_dma = alx->descmem.dma + offset;

If all the crazy casting isn't necessary here...

> +	rxq->rrd = (void *)((u8 *)alx->descmem.virt + offset);
> +	rxq->rrd_dma = alx->descmem.dma + offset;
> +	offset += sizeof(struct alx_rrd) * alx->rx_ringsz;
> +
> +	rxq->rfd = (void *)((u8 *)alx->descmem.virt + offset);
> +	rxq->rfd_dma = alx->descmem.dma + offset;
> +	offset += sizeof(struct alx_rfd) * alx->rx_ringsz;

Then it certainly isn't necessary here either.

Void pointer arithmatic is very clearly defined as operating on byte
quantities, so the cast is not necessary for the arithmetic nor the
final pointer type.
