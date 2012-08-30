From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] net/fsl_pq_mdio: streamline probing of MDIO nodes
Date: Thu, 30 Aug 2012 13:31:01 -0400 (EDT)
Message-ID: <20120830.133101.155514187705507717.davem@davemloft.net>
References: <1346263683-3664-1-git-send-email-timur@freescale.com>
	<1346263683-3664-5-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545Ab2H3RbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:31:04 -0400
In-Reply-To: <1346263683-3664-5-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Wed, 29 Aug 2012 13:08:01 -0500

> Make the device tree probe function more data-driven, so that it no longer
> searches the 'compatible' property more than once.  The of_device_id[] array
> allows for per-entry private data, so we use that to store details about each
> type of node that the driver supports.  This removes the need to check the
> 'compatible' property inside the probe function.
> 
> The driver supports four types on MDIO devices:
> 
> 1) Gianfar MDIO nodes that only map the MII registers
> 2) Gianfar MDIO nodes that map the full MDIO register set
> 3) eTSEC2 MDIO nodes (which map the full MDIO register set)
> 4) QE MDIO nodes (which map only the MII registers)
> 
> Gianfar, eTSEC2, and QE have different mappings for the TBIPA register, which
> is needed to initialize the TBI PHY.  In addition, the QE needs a special
> hack because of the way the device tree is ordered.
> 
> All of this information is encapsulated in the fsl_pq_mdio_data structure,
> so when an MDIO node is probed, per-device data and functions are used
> to determine how to initialize the device.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Applied to net-next.
