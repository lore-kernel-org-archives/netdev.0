From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/4] net: ethernet: nb8800: Set RGMII_MODE for all
 RGMII modes
Date: Fri, 21 Jul 2017 11:06:41 -0700
Message-ID: <6db56e41-f617-125f-45b2-b3d35b8d4e9a@gmail.com>
References: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
 <237905ff-385e-fa2f-bbbf-6c550a48e15c@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:38006 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbdGUSGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 14:06:54 -0400
Received: by mail-wm0-f66.google.com with SMTP id 143so7765882wmu.5
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 11:06:54 -0700 (PDT)
In-Reply-To: <237905ff-385e-fa2f-bbbf-6c550a48e15c@sigmadesigns.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2017 04:25 AM, Marc Gonzalez wrote:
> There are 4 RGMII phy-modes to handle.

... so make sure that the MAC is configured to set the RGMII_MODE
accordingly for all 4 RGMII mode.

> 
> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>

Fixes: 52dfc8301248 ("net: ethernet: add driver for Aurora VLSI NB8800
Ethernet controller")

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/aurora/nb8800.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
> index 041cfb7952f8..ded041dbafe7 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -609,7 +609,7 @@ static void nb8800_mac_config(struct net_device *dev)
>  		mac_mode |= HALF_DUPLEX;
>  
>  	if (gigabit) {
> -		if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII)
> +		if (phy_interface_is_rgmii(dev->phydev))
>  			mac_mode |= RGMII_MODE;
>  
>  		mac_mode |= GMAC_MODE;
> 


-- 
Florian
