From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: add phy-handle support for the macb
Date: Sat, 13 Aug 2016 11:52:22 -0700 (PDT)
Message-ID: <20160813.115222.443333178659469072.davem@davemloft.net>
References: <1471082509-11764-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, nicolas.ferre@atmel.com,
	sergio.prado@e-labworks.com, gregory.clement@free-electrons.com,
	narmstrong@baylibre.com, michal.simek@xilinx.com,
	appanad@xilinx.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: appana.durga.rao@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989AbcHNI6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 04:58:23 -0400
In-Reply-To: <1471082509-11764-1-git-send-email-appanad@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Date: Sat, 13 Aug 2016 15:31:49 +0530

> @@ -445,7 +445,13 @@ static int macb_mii_init(struct macb *bp)
>  	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
>  
>  	np = bp->pdev->dev.of_node;
> -	if (np) {
> +	np1 = of_get_parent(bp->phy_node);
> +	if (np1) {
> +		of_node_put(np1);
> +		err = of_mdiobus_register(bp->mii_bus, np1);
> +		if (err)
> +			goto err_out_unregister_bus;
> +	} else if (np) {

I don't know about this, all OF nodes other than the root have a
parent node which is non-NULL.  This parent node can be anything.

Just blinding assuming that any parent node of the phy_node is
what we are looking for, without any other supplementary checks
at all, seems to be asking for trouble at the very least.
