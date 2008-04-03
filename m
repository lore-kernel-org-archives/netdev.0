From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] Change mii_bus id field to a string
Date: Thu, 3 Apr 2008 20:26:04 +0100
Message-ID: <20080403192603.GM21637@solarflare.com>
References: <1207176592-4224-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ncase@xes-inc.com
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:51585 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755100AbYDCT0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 15:26:15 -0400
Content-Disposition: inline
In-Reply-To: <1207176592-4224-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 5e43ae7..92a4829 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -63,8 +63,6 @@ typedef enum {
>  	PHY_INTERFACE_MODE_RTBI
>  } phy_interface_t;
>  
> -#define MII_BUS_MAX 4
> -
>  
>  #define PHY_INIT_TIMEOUT	100000
>  #define PHY_STATE_TIME		1
> @@ -74,20 +72,30 @@ typedef enum {
>  #define PHY_MAX_ADDR	32
>  
>  /* Used when trying to connect to a specific phy (mii bus id:phy device id) */
> -#define PHY_ID_FMT "%x:%02x"
> +#define PHY_ID_FMT "%s:%02x"
> +
> +/*
> + * Need to be a little smaller than phydev->dev.bus_id to leave room
> + * for the ":%02x"
> + */
> +#define MII_BUS_ID_SIZE	BUS_ID_SIZE - 3

The macro's definition should be parenthesised.

>  
> -/* The Bus class for PHYs.  Devices which provide access to
> - * PHYs should register using this structure */
> +/*
> + * The Bus class for PHYs.  Devices which provide access to
> + * PHYs should register using this structure
> + */ 

I'm not sure why you reformatted this and other comments.  If you really
think it's necessary to do that, you should probably post a separate patch
rather than combining it with this functional change.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
