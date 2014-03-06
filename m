From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] gianfar: Make multi-queue polling optional
Date: Thu, 06 Mar 2014 16:52:36 -0500 (EST)
Message-ID: <20140306.165236.1656673150420499957.davem@davemloft.net>
References: <1394008119-27899-1-git-send-email-claudiu.manoil@freescale.com>
	<1394008119-27899-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbaCFVwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 16:52:38 -0500
In-Reply-To: <1394008119-27899-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 5 Mar 2014 10:28:39 +0200

> For the newer controllers (etsec2 models) the driver currently
> supports 8 Tx and Rx DMA rings (aka HW queues).  However, there
> are only 2 pairs of Rx/Tx interrupt lines, as these controllers
> are integrated in low power SoCs with 2 CPUs at most.  As a result,
> there are at most 2 NAPI instances that have to service multiple
> Tx and Rx queues for these devices.  This complicates the NAPI
> polling routine having to iterate over the mutiple Rx/Tx queues
> hooked to the same interrupt lines.  And there's also an overhead
> at HW level, as the controller needs to service all the 8 Tx rings
> in a round robin manner.  The cumulated overhead shows up for mutiple
> parrallel Tx flows transmitted by the kernel stack, when the driver
> usually starts returning NETDEV_TX_BUSY and leading to NETDEV WATCHDOG
> Tx timeout triggering if the Tx path is congested for too long.
> 
> As an alternative, this patch makes the driver support only one
> Tx/Rx DMA ring per NAPI instace (per interrupt group or pair
> of Tx/Rx interrupt lines) by default.  The simplified single queue
> polling routine (gfar_poll_sq) will be the default napi poll routine
> for the etsec2 devices too.  Only small adjustments needed to be made
> to link the Tx/Rx HW queues with each NAPI instance (2 in this case).
> The gfar_poll_sq() is already succefully used by older SQ_SG (single
> interrupt group) controllers.  And there's also a significat memory
> footprint reduction by supporting 2 Rx/Tx DMA rings (at most), instead
> of 8.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

This patch is not OK.

First of all, you are disabling multi-queue for other devices.

You're adding a CPP check for a macro that is set by nothing.

Determine the condition to limit the number of queues at run-time.
