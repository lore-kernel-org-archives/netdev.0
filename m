From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net-next] net: phy: add BCM7425 and BCM7429 PHYs
Date: Wed, 01 Oct 2014 11:59:14 -0700
Message-ID: <542C4F02.3030507@gmail.com>
References: <20141001185802.4479F100A08@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:62348 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbaJAS7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 14:59:44 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so759775pad.8
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 11:59:44 -0700 (PDT)
In-Reply-To: <20141001185802.4479F100A08@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2014 11:58 AM, Petri Gynther wrote:
> Signed-off-by: Petri Gynther <pgynther@google.com>

Acked-by: Florian Fainelli <f.fainelli@gmai.com>

Thanks Petri!

> ---
>  drivers/net/phy/bcm7xxx.c | 28 ++++++++++++++++++++++++++++
>  include/linux/brcmphy.h   |  2 ++
>  2 files changed, 30 insertions(+)
> 
> diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
> index daae699..1d211d3 100644
> --- a/drivers/net/phy/bcm7xxx.c
> +++ b/drivers/net/phy/bcm7xxx.c
> @@ -350,6 +350,32 @@ static struct phy_driver bcm7xxx_driver[] = {
>  	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439, "Broadcom BCM7439"),
>  	BCM7XXX_28NM_GPHY(PHY_ID_BCM7445, "Broadcom BCM7445"),
>  {
> +	.phy_id         = PHY_ID_BCM7425,
> +	.phy_id_mask    = 0xfffffff0,
> +	.name           = "Broadcom BCM7425",
> +	.features       = PHY_GBIT_FEATURES |
> +			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
> +	.flags          = 0,
> +	.config_init    = bcm7xxx_config_init,
> +	.config_aneg    = genphy_config_aneg,
> +	.read_status    = genphy_read_status,
> +	.suspend        = bcm7xxx_suspend,
> +	.resume         = bcm7xxx_config_init,
> +	.driver         = { .owner = THIS_MODULE },
> +}, {
> +	.phy_id         = PHY_ID_BCM7429,
> +	.phy_id_mask    = 0xfffffff0,
> +	.name           = "Broadcom BCM7429",
> +	.features       = PHY_GBIT_FEATURES |
> +			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
> +	.flags          = PHY_IS_INTERNAL,
> +	.config_init    = bcm7xxx_config_init,
> +	.config_aneg    = genphy_config_aneg,
> +	.read_status    = genphy_read_status,
> +	.suspend        = bcm7xxx_suspend,
> +	.resume         = bcm7xxx_config_init,
> +	.driver         = { .owner = THIS_MODULE },
> +}, {
>  	.phy_id		= PHY_BCM_OUI_4,
>  	.phy_id_mask	= 0xffff0000,
>  	.name		= "Broadcom BCM7XXX 40nm",
> @@ -381,6 +407,8 @@ static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
>  	{ PHY_ID_BCM7250, 0xfffffff0, },
>  	{ PHY_ID_BCM7364, 0xfffffff0, },
>  	{ PHY_ID_BCM7366, 0xfffffff0, },
> +	{ PHY_ID_BCM7425, 0xfffffff0, },
> +	{ PHY_ID_BCM7429, 0xfffffff0, },
>  	{ PHY_ID_BCM7439, 0xfffffff0, },
>  	{ PHY_ID_BCM7445, 0xfffffff0, },
>  	{ PHY_BCM_OUI_4, 0xffff0000 },
> diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
> index 3f626fe..7ccd928 100644
> --- a/include/linux/brcmphy.h
> +++ b/include/linux/brcmphy.h
> @@ -16,6 +16,8 @@
>  #define PHY_ID_BCM7250			0xae025280
>  #define PHY_ID_BCM7364			0xae025260
>  #define PHY_ID_BCM7366			0x600d8490
> +#define PHY_ID_BCM7425			0x03625e60
> +#define PHY_ID_BCM7429			0x600d8730
>  #define PHY_ID_BCM7439			0x600d8480
>  #define PHY_ID_BCM7445			0x600d8510
>  
> 
