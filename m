From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] mvneta: use inband status only when link type is
 "auto"
Date: Thu, 09 Jul 2015 11:18:38 -0700
Message-ID: <559EBAFE.6040705@gmail.com>
References: <559EB0A4.5080101@list.ru> <559EB22E.7070607@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev <netdev@vger.kernel.org>, stable@vger.kernel.org
To: Stas Sergeev <stsp@list.ru>, linux-net@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <559EB22E.7070607@list.ru>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/15 10:41, Stas Sergeev wrote:
> 
> The commit 898b2970e2c9 ("mvneta: implement SGMII-based in-band link state
> signaling") implemented the link parameters auto-negotiation unconditionally.
> Unfortunately it appears that some HW that implements SGMII protocol,
> doesn't generate the inband status, so it is not possible to auto-negotiate
> anything with such HW.

What is the purpose of using the in-band status in the first place if
you end-up having to specify a 'fixed-link' property which contains most
of the link parameters: speed, duplex etc...?

> 
> This patch enables the auto-negotiation only if the 'link' DT property
> is set to "auto".
> For old configurations where the 'link' property is not specified, the
> default is to not use auto-negotiation.
> 
> This patch fixes the following regression:
> https://lkml.org/lkml/2015/7/8/865
> and is therefore CCed to stable.
> 
> Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
> 
> CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> CC: netdev@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> CC: stable@vger.kernel.org
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 74176ec..b7f4d7f 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -3009,7 +3009,7 @@ static int mvneta_probe(struct platform_device *pdev)
>  	char hw_mac_addr[ETH_ALEN];
>  	const char *mac_from;
>  	int phy_mode;
> -	int fixed_phy = 0;
> +	int autoneg_link = 0;
>  	int err;
> 
>  	/* Our multiqueue support is not complete, so for now, only
> @@ -3043,7 +3043,7 @@ static int mvneta_probe(struct platform_device *pdev)
>  			dev_err(&pdev->dev, "cannot register fixed PHY\n");
>  			goto err_free_irq;
>  		}
> -		fixed_phy = 1;
> +		autoneg_link = of_phy_is_autoneg_link(dn);
> 
>  		/* In the case of a fixed PHY, the DT node associated
>  		 * to the PHY is the Ethernet MAC DT node.
> @@ -3068,7 +3068,7 @@ static int mvneta_probe(struct platform_device *pdev)
>  	pp->phy_node = phy_node;
>  	pp->phy_interface = phy_mode;
>  	pp->use_inband_status = (phy_mode == PHY_INTERFACE_MODE_SGMII) &&
> -				fixed_phy;
> +				autoneg_link;
> 
>  	pp->clk = devm_clk_get(&pdev->dev, NULL);
>  	if (IS_ERR(pp->clk)) {
> 


-- 
Florian
