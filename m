From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/2] of_mdio: Honour "status=disabled" property of device
Date: Thu, 29 Nov 2012 17:36:30 +0000
Message-ID: <20121129173630.3EC073E0A04@localhost>
References: <50B71290.2060200@sysgo.com>
Cc: alexander sverdlin <alexander.sverdlin.ext@nsn.com>,
	w.sang@pengutronix.de, Barry.Song@csr.com, netdev@vger.kernel.org
To: Alexander Sverdlin <asv@sysgo.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	devicetree-discuss@lists.ozlabs.org,
	Rob Herring <rob.herring@calxeda.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:52120 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003Ab2K2Rgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:36:35 -0500
Received: by mail-wi0-f170.google.com with SMTP id hq7so5720763wib.1
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 09:36:33 -0800 (PST)
In-Reply-To: <50B71290.2060200@sysgo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Nov 2012 08:45:20 +0100, Alexander Sverdlin <asv@sysgo.com> wrote:
> From: Alexander Sverdlin <alexander.sverdlin@sysgo.com>
> 
> of_mdio: Honour "status=disabled" property of device
> 
> Currently of_mdiobus_register() function registers all PHY devices,
> independetly from their status property in device tree. According to
> "ePAPR 1.1" spec, device should only be registered if there is no
> "status" property, or it has "ok" (or "okay") value (see
> of_device_is_available()). In case of "platform devices",
> of_platform_device_create_pdata() checks for "status" and ensures
> that disabled devices are not pupulated. But such check for MDIO buses
> was missing until now. Fix it.
> 
> Signed-off-by: Alexander Sverdlin <alexander.sverdlin@sysgo.com>

Applied, thanks.

g.

> ---
> --- linux.orig/drivers/of/of_mdio.c
> +++ linux/drivers/of/of_mdio.c
> @@ -53,7 +53,7 @@ int of_mdiobus_register(struct mii_bus *
>  		return rc;
>  
>  	/* Loop over the child nodes and register a phy_device for each one */
> -	for_each_child_of_node(np, child) {
> +	for_each_available_child_of_node(np, child) {
>  		const __be32 *paddr;
>  		u32 addr;
>  		int len;

-- 
Grant Likely, B.Sc, P.Eng.
Secret Lab Technologies, Ltd.
