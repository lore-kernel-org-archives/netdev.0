From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Wed, 07 May 2014 15:56:13 -0400 (EDT)
Message-ID: <20140507.155613.630399521517455317.davem@davemloft.net>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cooldavid@cooldavid.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbaEGT4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 15:56:15 -0400
In-Reply-To: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon,  5 May 2014 14:51:47 -0400

> The jme driver forgot to check the return status from pci_map_page in its tx
> path, causing a dma api warning on unmap.  Easy fix, just do the check and
> augment the tx path to tell the stack that the driver is busy so we re-queue the
> frame.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied thanks Neil.

Probably we should eventually come up with a perhaps more suitable recovery
scheme in the generic netdev queuing layer for these situations.

If a mapping fails, usually it's because of resource exhaustion and that's
a "wait and try again" type situation in hoping that whatever releases
are keeping the allocation from happening will get released.

But that's not exactly what we do right now when NETDEV_TX_BUSY is
signalled.  We'll just loop over and over in the TX software interrupt
handler for the qdisc.

Perhaps an hrtimer or similar would be more appropriate.
