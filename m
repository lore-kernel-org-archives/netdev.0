From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH 1/2] of_mdio: Honour "status=disabled" property of device
Date: Thu, 29 Nov 2012 11:12:02 -0600
Message-ID: <50B79762.2040009@gmail.com>
References: <50B71290.2060200@sysgo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Warren <swarren@wwwdotorg.org>,
	devicetree-discuss@lists.ozlabs.org,
	Rob Herring <rob.herring@calxeda.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, Barry.Song@csr.com, w.sang@pengutronix.de,
	alexander sverdlin <alexander.sverdlin.ext@nsn.com>
To: Alexander Sverdlin <asv@sysgo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:38561 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab2K2RML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:12:11 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so14729805oag.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 09:12:10 -0800 (PST)
In-Reply-To: <50B71290.2060200@sysgo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2012 01:45 AM, Alexander Sverdlin wrote:
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
> ---

Applied.

Rob

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
> _______________________________________________
> devicetree-discuss mailing list
> devicetree-discuss@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/devicetree-discuss
> 
