From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next] net: phy: marvell: Show complete link partner
 advertising
Date: Mon, 12 Jun 2017 09:05:04 -0700
Message-ID: <a172b1f9-5141-6d53-1d96-bd028a0b0a23@gmail.com>
References: <20170612133237.E20945085BC@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>, andrew@lunn.ch,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        rmk+kernel@armlinux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170612133237.E20945085BC@solo.franken.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/12/2017 05:54 AM, Thomas Bogendoerfer wrote:
> From: Thomas Bogendoerfer <tbogendoerfer@suse.de>
> 
> Give back all modes advertised by the link partner. This change brings
> the marvell phy driver in line with all other phy drivers.
> 
> Signed-off-by: Thomas Bogendoerfer <tbogendoerfer@suse.de>

I thought Russell had a similar patch but I can't find it applied in
net-next, so:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

drivers/net/phy/lxt.c has a similar pattern that would be worth fixing too.

> ---
>  drivers/net/phy/marvell.c | 7 -------
>  1 file changed, 7 deletions(-)
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index 4c5246fed69b..8400403b3f62 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -1139,7 +1139,6 @@ static int marvell_read_status_page_an(struct phy_device *phydev,
>  	int status;
>  	int lpa;
>  	int lpagb;
> -	int adv;
>  
>  	status = phy_read(phydev, MII_M1011_PHY_STATUS);
>  	if (status < 0)
> @@ -1153,12 +1152,6 @@ static int marvell_read_status_page_an(struct phy_device *phydev,
>  	if (lpagb < 0)
>  		return lpagb;
>  
> -	adv = phy_read(phydev, MII_ADVERTISE);
> -	if (adv < 0)
> -		return adv;
> -
> -	lpa &= adv;
> -
>  	if (status & MII_M1011_PHY_STATUS_FULLDUPLEX)
>  		phydev->duplex = DUPLEX_FULL;
>  	else
> 


-- 
Florian
