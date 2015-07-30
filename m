From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] net/phy: micrel: Reenable interrupts during resume
Date: Thu, 30 Jul 2015 21:00:58 +0300
Message-ID: <55BA665A.4080103@cogentembedded.com>
References: <1438269348-8725-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nathan Sullivan <nathan.sullivan@ni.com>, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438269348-8725-1-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07/30/2015 06:15 PM, Nathan Sullivan wrote:

> The ksz9031 has a behavior where it will clear the interrupt enable bits
> when leaving power down.  To work around this, make sure the interrupt
> bits are in the state they are expected to be when resuming.

> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> ---

> Changes for V2: Actually make sure it compiles this time.

> ---
>   drivers/net/phy/micrel.c |   18 +++++++++++++++++-
>   1 file changed, 17 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 499185e..9774582 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -447,6 +447,22 @@ static int ksz9031_center_flp_timing(struct phy_device *phydev)
>   	return genphy_restart_aneg(phydev);
>   }
>
> +static int ksz9031_resume(struct phy_device *phydev)
> +{
> +	int result;
> +
> +	result = genphy_resume(phydev);
> +

    I don't think empty line is needed here. Sorry for missing it in the first 
posting...

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
[...]

WBR, Sergei
