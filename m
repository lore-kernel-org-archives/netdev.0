From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: Add support for SMSC LAN8740 PHY
Date: Sat, 9 Jan 2016 02:36:55 +0100
Message-ID: <20160109013655.GA28813@lunn.ch>
References: <1452301040-4392-1-git-send-email-joshua.henderson@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Joshua Henderson <joshua.henderson@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452301040-4392-1-git-send-email-joshua.henderson@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 08, 2016 at 05:57:20PM -0700, Joshua Henderson wrote:
> LAN8740 has a different phy_id than LAN8710/LAN8720.
> 
> Signed-off-by: Joshua Henderson <joshua.henderson@microchip.com>
> ---
>  drivers/net/phy/smsc.c |   24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> index dc2da87..34021a5 100644
> --- a/drivers/net/phy/smsc.c
> +++ b/drivers/net/phy/smsc.c
> @@ -264,6 +264,29 @@ static struct phy_driver smsc_phy_driver[] = {
>  	.resume		= genphy_resume,
>  
>  	.driver		= { .owner = THIS_MODULE, }
> +}, {
> +	.phy_id		= 0x0007c110,
> +	.phy_id_mask	= 0xfffffff0,
> +	.name		= "SMSC LAN8740",
> +
> +	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
> +				| SUPPORTED_Asym_Pause),
> +	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
> +
> +	/* basic functions */
> +	.config_aneg	= genphy_config_aneg,
> +	.read_status	= lan87xx_read_status,
> +	.config_init	= smsc_phy_config_init,
> +	.soft_reset	= smsc_phy_reset,
> +
> +	/* IRQ related */
> +	.ack_interrupt	= smsc_phy_ack_interrupt,
> +	.config_intr	= smsc_phy_config_intr,
> +
> +	.suspend	= genphy_suspend,
> +	.resume		= genphy_resume,
> +
> +	.driver		= { .owner = THIS_MODULE, }
>  } };

Hi Joshua

You should remove this .driver line. The core sets it now.

    Andrew
