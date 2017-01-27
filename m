From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: phy: micrel: add support for KSZ8795
Date: Fri, 27 Jan 2017 10:55:22 -0800
Message-ID: <bce20c23-0d67-128b-3643-2aafc3648e68@gmail.com>
References: <20170127074623.9200-1-sean.nyekjaer@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch
To: Sean Nyekjaer <sean.nyekjaer@prevas.dk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33988 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdA0SzZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 13:55:25 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so7866484pgj.1
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 10:55:24 -0800 (PST)
In-Reply-To: <20170127074623.9200-1-sean.nyekjaer@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/2017 11:46 PM, Sean Nyekjaer wrote:
> This is adds support for the PHYs in the KSZ8795 5port managed switch.
> 
> It will allow to detect the link between the switch and the soc
> and uses the same read_status functions as the KSZ8873MLL switch.
> 
> Signed-off-by: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
> ---
> Changes in v2:
>  - Removed "switch" name
> 
>  drivers/net/phy/micrel.c   | 14 ++++++++++++++
>  include/linux/micrel_phy.h |  2 ++
>  2 files changed, 16 insertions(+)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index ea92d524d5a8..fab56c9350cf 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -1014,6 +1014,20 @@ static struct phy_driver ksphy_driver[] = {
>  	.get_stats	= kszphy_get_stats,
>  	.suspend	= genphy_suspend,
>  	.resume		= genphy_resume,
> +}, {
> +	.phy_id		= PHY_ID_KSZ8795,
> +	.phy_id_mask	= MICREL_PHY_ID_MASK,
> +	.name		= "Micrel KSZ8795",
> +	.features	= (SUPPORTED_Pause | SUPPORTED_Asym_Pause),

This is wrong, it should be PHY_GBIT_FEATURES or PHY_BASIC_FEATURES.
Including the Pause/AsymPause feature bits is not longer necessary, the
PHY library takes care of adding these automatically to let your MAC do
flow control auto-negotiation later on.

Please submit an incremental fix to that.

> +	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
> +	.config_init	= kszphy_config_init,
> +	.config_aneg	= ksz8873mll_config_aneg,
> +	.read_status	= ksz8873mll_read_status,
> +	.get_sset_count = kszphy_get_sset_count,
> +	.get_strings	= kszphy_get_strings,
> +	.get_stats	= kszphy_get_stats,
> +	.suspend	= genphy_suspend,
> +	.resume		= genphy_resume,
>  } };
>  
>  module_phy_driver(ksphy_driver);
> diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
> index 257173e0095e..f541da68d1e7 100644
> --- a/include/linux/micrel_phy.h
> +++ b/include/linux/micrel_phy.h
> @@ -35,6 +35,8 @@
>  #define PHY_ID_KSZ886X		0x00221430
>  #define PHY_ID_KSZ8863		0x00221435
>  
> +#define PHY_ID_KSZ8795		0x00221550
> +
>  /* struct phy_device dev_flags definitions */
>  #define MICREL_PHY_50MHZ_CLK	0x00000001
>  #define MICREL_PHY_FXEN		0x00000002
> 


-- 
Florian
