From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] net: phy: leds: Fix truncated LED trigger names
Date: Tue, 24 Jan 2017 21:03:39 +0100
Message-ID: <20170124200339.GT10895@lunn.ch>
References: <1485272470-3497-1-git-send-email-geert+renesas@glider.be>
 <1485272470-3497-3-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Zach Brown <zach.brown@ni.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Magnus =?iso-8859-1?Q?=D6berg?= <magnus.oberg@westermo.se>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1485272470-3497-3-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 5c9d2529685fe215..f6ab919528ab3627 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -25,7 +25,6 @@
>  #include <linux/timer.h>
>  #include <linux/workqueue.h>
>  #include <linux/mod_devicetable.h>
> -#include <linux/phy_led_triggers.h>
>  
>  #include <linux/atomic.h>
>  
> @@ -339,6 +338,8 @@ struct phy_c45_device_ids {
>  	u32 device_ids[8];
>  };
>  
> +#include <linux/phy_led_triggers.h>
> +
>  /* phy_device: An instance of a PHY
>   *
>   * drv: Pointer to the driver for this PHY instance
> diff --git a/include/linux/phy_led_triggers.h b/include/linux/phy_led_triggers.h
> index a2daea0a37d2ae14..69dffb4fc5a294e9 100644
> --- a/include/linux/phy_led_triggers.h
> +++ b/include/linux/phy_led_triggers.h
> @@ -20,9 +20,8 @@
>  #include <linux/leds.h>
>  
>  #define PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE	10
> -#define PHY_MII_BUS_ID_SIZE	(20 - 3)
>  
> -#define PHY_LINK_LED_TRIGGER_NAME_SIZE (PHY_MII_BUS_ID_SIZE + \
> +#define PHY_LINK_LED_TRIGGER_NAME_SIZE (MII_BUS_ID_SIZE + \
>  				       FIELD_SIZEOF(struct mdio_device, addr)+\
>  				       PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE)

Hi Geert

Using the macro is great, but it does seem a bit ugly having the
include in the middle of the file.

As far as i can see, phy.h only uses a pointer to a struct
phy_led_trigger, not struct phy_led_trigger itself. Could you try
removing the header file all together and just have a forward
declaration of phy_led_trigger?

Thanks
	Andrew
