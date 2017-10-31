From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: [PATCH net] net: phy: marvell: Only configure RGMII delays when
 using RGMII
Date: Tue, 31 Oct 2017 23:29:54 +0200
Message-ID: <20171031212953.4ctl5jptgi6wgdlu@darkstar.musicnaut.iki.fi>
References: <1509478288-27130-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh06.mail.saunalahti.fi ([62.142.5.116]:41678 "EHLO
        emh06.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752066AbdJaV34 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 17:29:56 -0400
Content-Disposition: inline
In-Reply-To: <1509478288-27130-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Oct 31, 2017 at 08:31:28PM +0100, Andrew Lunn wrote:
> The fix 5987feb38aa5 ("net: phy: marvell: logical vs bitwise OR typo")
> uncovered another bug in the Marvell PHY driver, which broke the
> Marvell OpenRD platform. It relies on the bootloader configuring the
> RGMII delays and does not specify a phy-mode in its device tree.  The
> PHY driver should only configure RGMII delays if the phy mode
> indicates it is using RGMII. Without anything in device tree, the
> mv643xx Ethernet driver defaults to GMII.
> 
> Fixes: 5987feb38aa5 ("net: phy: marvell: logical vs bitwise OR typo")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Tested-by: Aaro Koskinen <aaro.koskinen@iki.fi>

> Aaro
> 
> Please can you test this and see if it fixes your OpenRD. This should
> cause it to leave the bootloader configuration alone. That will fix
> the regression for older DT blobs. Adding correct phy-mode properties
> can also be done. That would increase the robustness to bootloader
> changes.

Thanks, and yes, I guess also the DT should be updated...

A.

> drivers/net/phy/marvell.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index 15cbcdba618a..4d02b27df044 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -681,9 +681,11 @@ static int m88e1116r_config_init(struct phy_device *phydev)
>  	if (err < 0)
>  		return err;
>  
> -	err = m88e1121_config_aneg_rgmii_delays(phydev);
> -	if (err < 0)
> -		return err;
> +	if (phy_interface_is_rgmii(phydev)) {
> +		err = m88e1121_config_aneg_rgmii_delays(phydev);
> +		if (err < 0)
> +			return err;
> +	}
>  
>  	err = genphy_soft_reset(phydev);
>  	if (err < 0)
> -- 
> 2.14.1
> 
