From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 5/9] tlan: Restart autonegotiation on link loss
Date: Wed, 28 May 2014 18:08:13 +0400
Message-ID: <5385EDCD.5030001@cogentembedded.com>
References: <1401226727-5508-1-git-send-email-linux@rainbow-software.org> <1401226727-5508-6-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>,
	Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401226727-5508-6-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/28/2014 01:38 AM, Ondrej Zary wrote:

> When link is lost on a card which uses internal PHY for 10 Mbit speeds,
> restart autonegotiation to allow switching between 10 and 100 Mbps speeds.

> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> ---
>   drivers/net/ethernet/ti/tlan.c |   14 ++++++++++++++
>   1 file changed, 14 insertions(+)

> diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
> index 31d4a96..1047b3f 100644
> --- a/drivers/net/ethernet/ti/tlan.c
> +++ b/drivers/net/ethernet/ti/tlan.c
[...]
> @@ -2788,6 +2789,19 @@ static void tlan_phy_monitor(unsigned long data)
>   			       dev->name);
>   			tlan_dio_write8(dev->base_addr, TLAN_LED_REG, 0);
>   			netif_carrier_off(dev);
> +			if (priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10) {
> +				/* power down internal PHY */
> +				u16 data = MII_GC_PDOWN | MII_GC_LOOPBK
> +					| MII_GC_ISOLATE;

    Please, leave | on the previosu line.

> +				tlan_mii_sync(dev->base_addr);
> +				tlan_mii_write_reg(dev, priv->phy[0],
> +					MII_GEN_CTL, data);

    Please start this line right under 'dev' on the previous one.

> +				/* set to external PHY */
> +				priv->phy_num = 1;
> +				/* restart autonegotiation */
> +				tlan_set_timer(dev, (4*HZ/10), TLAN_TIMER_PHY_PDOWN);

    Spaces around * and / wouldn't hurt for consistency.

> +				return;
> +			}
>   		}
>   	}

WBR, Sergei
