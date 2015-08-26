From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [v2] net: phy: fixed: propagate fixed link values to struct
Date: Wed, 26 Aug 2015 11:48:05 -0700
Message-ID: <55DE09E5.1080008@gmail.com>
References: <1440601127-7663-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Igal.Liberman@freescale.com, andrew@lunn.ch
To: madalin.bucur@freescale.com, stsp@list.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34825 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbbHZSue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 14:50:34 -0400
In-Reply-To: <1440601127-7663-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/08/15 07:58, Madalin Bucur wrote:
> The fixed link values parsed from the device tree are stored in
> the struct fixed_phy member status. The struct phy_device members
> speed, duplex were not updated.

Arguably you need to start the PHY state machine for this to work
properly, but this looks fine to me.

> 
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
> v2: always setting phy->link, thanks Stas
> 
>  drivers/net/phy/fixed_phy.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
> index 479b93f..99d9bc1 100644
> --- a/drivers/net/phy/fixed_phy.c
> +++ b/drivers/net/phy/fixed_phy.c
> @@ -292,6 +292,15 @@ struct phy_device *fixed_phy_register(unsigned int irq,
>  		return ERR_PTR(-EINVAL);
>  	}
>  
> +	/* propagate the fixed link values to struct phy_device */
> +	phy->link = status->link;
> +	if (status->link) {
> +		phy->speed = status->speed;
> +		phy->duplex = status->duplex;
> +		phy->pause = status->pause;
> +		phy->asym_pause = status->asym_pause;
> +	}
> +
>  	of_node_get(np);
>  	phy->dev.of_node = np;
>  
> 


-- 
Florian
