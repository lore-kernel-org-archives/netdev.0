From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net/phy/vitesse: Configure RGMII skew on VSC8601, if
 needed
Date: Wed, 16 Nov 2016 14:50:53 +0100
Message-ID: <20161116135053.GF19962@lunn.ch>
References: <20161115.221217.2076182289174952941.davem@davemloft.net>
 <1479286953-11481-1-git-send-email-alex.g@adaptrum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
To: Alexandru Gagniuc <alex.g@adaptrum.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1479286953-11481-1-git-send-email-alex.g@adaptrum.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 16, 2016 at 01:02:33AM -0800, Alexandru Gagniuc wrote:
> With RGMII, we need a 1.5 to 2ns skew between clock and data lines. The
> VSC8601 can handle this internally. While the VSC8601 can set more
> fine-grained delays, the standard skew settings work out of the box.
> The same heuristic is used to determine when this skew should be enabled
> as in vsc824x_config_init().
> 
> Tested on custom board with AM3352 SOC and VSC801 PHY.
> 
> Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>
> ---
> Changes since v1:
>  * Added comment detailing applicability to different RGMII interfaces.
> 
>  drivers/net/phy/vitesse.c | 34 +++++++++++++++++++++++++++++++++-
>  1 file changed, 33 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
> index 2e37eb3..24b4a09 100644
> --- a/drivers/net/phy/vitesse.c
> +++ b/drivers/net/phy/vitesse.c
> @@ -62,6 +62,10 @@
>  /* Vitesse Extended Page Access Register */
>  #define MII_VSC82X4_EXT_PAGE_ACCESS	0x1f
>  
> +/* Vitesse VSC8601 Extended PHY Control Register 1 */
> +#define MII_VSC8601_EPHY_CTL		0x17
> +#define MII_VSC8601_EPHY_CTL_RGMII_SKEW	(1 << 8)
> +
>  #define PHY_ID_VSC8234			0x000fc620
>  #define PHY_ID_VSC8244			0x000fc6c0
>  #define PHY_ID_VSC8514			0x00070670
> @@ -111,6 +115,34 @@ static int vsc824x_config_init(struct phy_device *phydev)
>  	return err;
>  }
>  
> +/* This adds a skew for both TX and RX clocks, so the skew should only be
> + * applied to "rgmii-id" interfaces. It may not work as expected
> + * on "rgmii-txid", "rgmii-rxid" or "rgmii" interfaces. */

Hi Alexandru

You should be able to make "rgmii" work as expected. If that is the
phy mode, disable the skew.

    Andrew
