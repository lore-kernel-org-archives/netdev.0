From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 1/3] net: phy: Remove TI DP83822 from DP83848 driver
Date: Mon, 9 Oct 2017 09:44:29 -0700
Message-ID: <b1dc0e7e-7024-7111-1a15-59a114207555@gmail.com>
References: <20171009120302.23611-1-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Woojung.Huh@microchip.com, afd@ti.com
To: Dan Murphy <dmurphy@ti.com>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35932 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754197AbdJIQoc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 12:44:32 -0400
Received: by mail-qk0-f194.google.com with SMTP id z14so16705821qkg.3
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 09:44:32 -0700 (PDT)
In-Reply-To: <20171009120302.23611-1-dmurphy@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2017 05:03 AM, Dan Murphy wrote:
> Removing the DP83822 device from the DP83848 to
> support the TI DP83822 dedicated driver that will
> initially support WoL settings.
Hi Dan,

The ordering of patch 1 and 2 may have to be reversed, otherwise you are
leaving people with the Generic PHY driver matching the DP83822 PHY
after applying patch 1, and without proper interrupt management again
unless they apply patch 2.

It may even be better to combine patch 1 and 2 actually to have a
cleaner transition.

Sorry for noticing this so late in the series...

> 
> Signed-off-by: Dan Murphy <dmurphy@ti.com>
> ---
> 
> v3 - No changes made
> v2 - There was no v1 on this patch this is new.
> 
>  drivers/net/phy/dp83848.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
> index 3de4fe4dda77..3966d43c5146 100644
> --- a/drivers/net/phy/dp83848.c
> +++ b/drivers/net/phy/dp83848.c
> @@ -20,7 +20,6 @@
>  #define TI_DP83620_PHY_ID		0x20005ce0
>  #define NS_DP83848C_PHY_ID		0x20005c90
>  #define TLK10X_PHY_ID			0x2000a210
> -#define TI_DP83822_PHY_ID		0x2000a240
>  
>  /* Registers */
>  #define DP83848_MICR			0x11 /* MII Interrupt Control Register */
> @@ -80,7 +79,6 @@ static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
>  	{ NS_DP83848C_PHY_ID, 0xfffffff0 },
>  	{ TI_DP83620_PHY_ID, 0xfffffff0 },
>  	{ TLK10X_PHY_ID, 0xfffffff0 },
> -	{ TI_DP83822_PHY_ID, 0xfffffff0 },
>  	{ }
>  };
>  MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
> @@ -110,7 +108,6 @@ static struct phy_driver dp83848_driver[] = {
>  	DP83848_PHY_DRIVER(NS_DP83848C_PHY_ID, "NS DP83848C 10/100 Mbps PHY"),
>  	DP83848_PHY_DRIVER(TI_DP83620_PHY_ID, "TI DP83620 10/100 Mbps PHY"),
>  	DP83848_PHY_DRIVER(TLK10X_PHY_ID, "TI TLK10X 10/100 Mbps PHY"),
> -	DP83848_PHY_DRIVER(TI_DP83822_PHY_ID, "TI DP83822 10/100 Mbps PHY"),
>  };
>  module_phy_driver(dp83848_driver);
>  
> 


-- 
Florian
