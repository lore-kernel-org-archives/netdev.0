From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: Add 405EX support to new EMAC driver
Date: Fri, 02 Nov 2007 07:37:01 +1100
Message-ID: <1193949421.6541.10.camel@pasglop>
References: <200711011554.04935.sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39236 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752271AbXKAUmi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 16:42:38 -0400
In-Reply-To: <200711011554.04935.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2007-11-01 at 15:54 +0100, Stefan Roese wrote:
> This patch adds support for the 405EX to the new EMAC driver.
> 
> Tested on AMCC Kilauea.

 .../...

> diff --git a/drivers/net/ibm_newemac/rgmii.c b/drivers/net/ibm_newemac/rgmii.c
> index de41695..e393f68 100644
> --- a/drivers/net/ibm_newemac/rgmii.c
> +++ b/drivers/net/ibm_newemac/rgmii.c
> @@ -140,9 +140,6 @@ void rgmii_get_mdio(struct of_device *ofdev, int input)
>  
>  	RGMII_DBG2(dev, "get_mdio(%d)" NL, input);
>  
> -	if (dev->type != RGMII_AXON)
> -		return;
> -
>  	mutex_lock(&dev->lock);

That will break 440GX boards that need to use the RGMII for data and the
ZMII for MDIO.

You may want to change the name RGMII_AXON something like RGMII_HAS_MDIO
instead and set that for 405EX as well instead.

Ben.


