From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net/phy: micrel: Reenable interrupts during resume
Date: Thu, 30 Jul 2015 09:40:56 -0700
Message-ID: <55BA5398.7020601@gmail.com>
References: <1438269348-8725-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nathan Sullivan <nathan.sullivan@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438269348-8725-1-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/07/15 08:15, Nathan Sullivan wrote:
> The ksz9031 has a behavior where it will clear the interrupt enable bits
> when leaving power down.  To work around this, make sure the interrupt
> bits are in the state they are expected to be when resuming.
> 
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
> 
> Changes for V2: Actually make sure it compiles this time.
> 
> ---
>  drivers/net/phy/micrel.c |   18 +++++++++++++++++-
>  1 file changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 499185e..9774582 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -447,6 +447,22 @@ static int ksz9031_center_flp_timing(struct phy_device *phydev)
>  	return genphy_restart_aneg(phydev);
>  }
>  
> +static int ksz9031_resume(struct phy_device *phydev)
> +{
> +	int result;
> +
> +	result = genphy_resume(phydev);
> +
> +	if (result)
> +		return result;
> +
> +	/* This phy will reset interrupt enables when leaving power down */
> +	if (PHY_INTERRUPT_ENABLED & phydev->interrupts)
> +		result = kszphy_config_intr(phydev);
> +
> +	return result;
> +}
> +
>  static int ksz9031_config_init(struct phy_device *phydev)
>  {
>  	const struct device *dev = &phydev->dev;
> @@ -776,7 +792,7 @@ static struct phy_driver ksphy_driver[] = {
>  	.ack_interrupt	= kszphy_ack_interrupt,
>  	.config_intr	= kszphy_config_intr,
>  	.suspend	= genphy_suspend,
> -	.resume		= genphy_resume,
> +	.resume		= ksz9031_resume,
>  	.driver		= { .owner = THIS_MODULE, },
>  }, {
>  	.phy_id		= PHY_ID_KSZ8873MLL,
> 


-- 
Florian
