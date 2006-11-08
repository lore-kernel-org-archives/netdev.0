From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] Add support for configuring the PHY connection interface
Date: Wed, 8 Nov 2006 10:37:23 +0100
Message-ID: <200611081037.24039.netdev@axxeo.de>
References: <Pine.LNX.4.61.0611080009010.6936@ld0175-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:44715 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1754472AbWKHJhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 04:37:41 -0500
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <Pine.LNX.4.61.0611080009010.6936@ld0175-tx32.am.freescale.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andy,

Andy Fleming wrote:
> diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_soc.c
> index b4b5b4a..b053370 100644
> --- a/arch/powerpc/sysdev/fsl_soc.c
> +++ b/arch/powerpc/sysdev/fsl_soc.c
> @@ -211,6 +211,36 @@ static int __init gfar_set_flags(struct 
>  	return device_flags;
>  }
>  
> +/* Return the Linux interface mode type based on the
> + * specification in the device-tree */
> +static int __init gfar_get_interface(struct device_node *np)
> +{
> +	const char *istr;
> +	int interface = 0;
> +
> +	istr = get_property(np, "interface", NULL);
> +
> +	if (istr == NULL)
> +		istr = "GMII";
> +
> +	if (!strcasecmp(istr, "GMII"))
> +		interface = PHY_INTERFACE_MODE_GMII;
> +	else if (!strcasecmp(istr, "MII"))
> +		interface = PHY_INTERFACE_MODE_MII;
> +	else if (!strcasecmp(istr, "RGMII"))
> +		interface = PHY_INTERFACE_MODE_RGMII;
> +	else if (!strcasecmp(istr, "SGMII"))
> +		interface = PHY_INTERFACE_MODE_SGMII;
> +	else if (!strcasecmp(istr, "TBI"))
> +		interface = PHY_INTERFACE_MODE_TBI;
> +	else if (!strcasecmp(istr, "RMII"))
> +		interface = PHY_INTERFACE_MODE_RMII;
> +	else if (!strcasecmp(istr, "RTBI"))
> +		interface = PHY_INTERFACE_MODE_RTBI;
> +
> +	return interface;
> +}

If you change the modes into an enum (as suggested by Kumar), 
you can make a nice static lookup table indexed by mode with a for loop here.


Regards

Ingo Oeser
