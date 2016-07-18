From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: ethernet: marvell: pxa168_eth: use
 phy_ethtool_{get|set}_link_ksettings
Date: Mon, 18 Jul 2016 15:02:55 -0700
Message-ID: <578D520F.9000209@gmail.com>
References: <1468791046-19567-1-git-send-email-tremyfr@gmail.com>
 <1468791046-19567-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, davem@davemloft.net,
	jszhang@marvell.com, sergei.shtylyov@cogentembedded.com,
	mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468791046-19567-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/17/2016 02:30 PM, Philippe Reynes wrote:
> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
> -	cmd.phy_address = pep->phy_addr;
> -	cmd.speed = pep->phy_speed;
> -	cmd.duplex = pep->phy_duplex;
> -	cmd.advertising = PHY_BASIC_FEATURES;
> -	cmd.autoneg = AUTONEG_ENABLE;
> +	cmd.base.phy_address = pep->phy_addr;
> +	cmd.base.speed = pep->phy_speed;
> +	cmd.base.duplex = pep->phy_duplex;
> +	ethtool_convert_legacy_u32_to_link_mode(cmd.link_modes.advertising,
> +						PHY_BASIC_FEATURES);
> +	cmd.base.autoneg = AUTONEG_ENABLE;
>  
> -	if (cmd.speed != 0)
> -		cmd.autoneg = AUTONEG_DISABLE;
> +	if (cmd.base.speed != 0)
> +		cmd.base.autoneg = AUTONEG_DISABLE;
>  
> -	return pxa168_set_settings(dev, &cmd);
> +	return phy_ethtool_set_link_ksettings(dev, &cmd);

This duplicates quite a bit of code that the core PHYLIB already deals
with, you should plan for a subsequent cleanup patch which removes all
of this.
-- 
Florian
