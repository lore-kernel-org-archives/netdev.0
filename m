From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 05/11] tlan: Restart autonegotiation on link loss
Date: Sat, 21 Jun 2014 21:06:22 +0400
Message-ID: <53A5BB8E.10206@cogentembedded.com>
References: <1403362076-7777-1-git-send-email-linux@rainbow-software.org> <1403362076-7777-6-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>,
	Samuel Chessman <chessman@tux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:64930 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbaFURGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 13:06:12 -0400
Received: by mail-la0-f52.google.com with SMTP id ty20so3077191lab.25
        for <netdev@vger.kernel.org>; Sat, 21 Jun 2014 10:06:11 -0700 (PDT)
In-Reply-To: <1403362076-7777-6-git-send-email-linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/21/2014 06:47 PM, Ondrej Zary wrote:

> When link is lost on a card which uses internal PHY for 10 Mbit speeds,
> restart autonegotiation to allow switching between 10 and 100 Mbps speeds.
>
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> ---
>   drivers/net/ethernet/ti/tlan.c |   15 +++++++++++++++
>   1 file changed, 15 insertions(+)

> diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
> index 31d4a96..47eb30e 100644
> --- a/drivers/net/ethernet/ti/tlan.c
> +++ b/drivers/net/ethernet/ti/tlan.c
[...]
> @@ -2788,6 +2789,20 @@ static void tlan_phy_monitor(unsigned long data)
>   			       dev->name);
>   			tlan_dio_write8(dev->base_addr, TLAN_LED_REG, 0);
>   			netif_carrier_off(dev);
> +			if (priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10) {
> +				/* power down internal PHY */
> +				u16 data = MII_GC_PDOWN | MII_GC_LOOPBK |
> +					   MII_GC_ISOLATE;

    Please insert empty line here, after declaration.

> +				tlan_mii_sync(dev->base_addr);
> +				tlan_mii_write_reg(dev, priv->phy[0],
> +						   MII_GEN_CTL, data);
> +				/* set to external PHY */
> +				priv->phy_num = 1;
> +				/* restart autonegotiation */
> +				tlan_set_timer(dev, 4 * HZ / 10,
> +					       TLAN_TIMER_PHY_PDOWN);
> +				return;
> +			}
>   		}
>   	}

WBR, Sergei
