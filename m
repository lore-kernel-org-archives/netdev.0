From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v2 2/2 ] net: ethernet: nb8800: handle all RGMII definitions
Date: Fri, 04 Nov 2016 17:12:52 +0000
Message-ID: <yw1xshr7i2y3.fsf@unicorn.mansr.com>
References: <581CA3D0.6080808@laposte.net>
        <8c491fff-4849-fa9b-0a0a-5a7a6870120d@gmail.com>
        <581CBF17.2010108@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <581CBF17.2010108@laposte.net> (Sebastian Frias's message of
        "Fri, 4 Nov 2016 18:02:15 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Frias <sf84@laposte.net> writes:

> Commit a999589ccaae ("phylib: add RGMII-ID interface mode definition")
> and commit 7d400a4c5897 ("phylib: add PHY interface modes for internal
> delay for tx and rx only") added several RGMII definitions:
> PHY_INTERFACE_MODE_RGMII_ID, PHY_INTERFACE_MODE_RGMII_RXID and
> PHY_INTERFACE_MODE_RGMII_TXID to deal with internal delays.
>
> Those are all RGMII modes (1Gbit) and must be considered that way when
> setting the MAC mode or the pad mode for the HW to work properly.
>
> Signed-off-by: Sebastian Frias <sf84@laposte.net>
> ---
>  drivers/net/ethernet/aurora/nb8800.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
> index d2855c9..fba2699 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -598,6 +598,7 @@ static irqreturn_t nb8800_irq(int irq, void *dev_id)
>  static void nb8800_mac_config(struct net_device *dev)
>  {
>  	struct nb8800_priv *priv = netdev_priv(dev);
> +	struct phy_device *phydev = dev->phydev;
>  	bool gigabit = priv->speed == SPEED_1000;
>  	u32 mac_mode_mask = RGMII_MODE | HALF_DUPLEX | GMAC_MODE;
>  	u32 mac_mode = 0;
> @@ -609,7 +610,7 @@ static void nb8800_mac_config(struct net_device *dev)
>  		mac_mode |= HALF_DUPLEX;
>
>  	if (gigabit) {
> -		if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII)
> +		if (phy_interface_is_rgmii(phydev))
>  			mac_mode |= RGMII_MODE;
>
>  		mac_mode |= GMAC_MODE;

This part is correct regardless of the outcome of the delay setup
discussion.

> @@ -1278,9 +1279,8 @@ static int nb8800_tangox_init(struct net_device *dev)
>  		break;
>
>  	case PHY_INTERFACE_MODE_RGMII:
> -		pad_mode = PAD_MODE_RGMII;
> -		break;
> -
> +	case PHY_INTERFACE_MODE_RGMII_ID:
> +	case PHY_INTERFACE_MODE_RGMII_RXID:
>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>  		pad_mode = PAD_MODE_RGMII;
>  		break;
> -- 
> 1.7.11.2
>

-- 
Måns Rullgård
