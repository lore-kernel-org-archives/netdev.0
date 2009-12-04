From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [RFC][PATCH 07/10] fec: Add LAN8700 phy support
Date: Fri, 4 Dec 2009 12:15:59 +0100
Message-ID: <20091204111559.GM15126@pengutronix.de>
References: <cover.1259893118.git.amit.kucheria@canonical.com> <a34d2aac8d5282bfbdf09dddc2da57c4ad7da355.1259893118.git.amit.kucheria@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: List Linux Kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, valentin.longchamp@epfl.ch,
	daniel@caiaq.de, grant.likely@secretlab.ca,
	Dinh.Nguyen@freescale.com, r.herring@freescale.com
To: Amit Kucheria <amit.kucheria@canonical.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756049AbZLDLPz@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a34d2aac8d5282bfbdf09dddc2da57c4ad7da355.1259893118.git.amit.kucheria@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 04, 2009 at 04:47:07AM +0200, Amit Kucheria wrote:
> The i.MX51 babbage board has a FEC ethernet controller with this phy.

I already saw patches for proper phylib support for the fec driver.
Maybe we should reactivate them rather than adding another phy to this
driver.

Sascha

> 
> Signed-off-by: Amit Kucheria <amit.kucheria@canonical.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/fec.c |   21 +++++++++++++++++++++
>  1 files changed, 21 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 9a8743d..5d0d332 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -1128,6 +1128,26 @@ static phy_info_t phy_info_dp83848= {
>  	},
>  };
>  
> +static phy_info_t phy_info_lan8700 = {
> +	0x0007C0C,
> +	"LAN8700",
> +	(const phy_cmd_t []) { /* config */
> +		{ mk_mii_read(MII_REG_CR), mii_parse_cr },
> +		{ mk_mii_read(MII_REG_ANAR), mii_parse_anar },
> +		{ mk_mii_end, }
> +	},
> +	(const phy_cmd_t []) { /* startup */
> +		{ mk_mii_write(MII_REG_CR, 0x1200), NULL }, /* autonegotiate */
> +		{ mk_mii_read(MII_REG_SR), mii_parse_sr },
> +		{ mk_mii_end, }
> +	},
> +	(const phy_cmd_t []) { /* act_int */
> +		{ mk_mii_end, }
> +	},
> +	(const phy_cmd_t []) { /* shutdown */
> +		{ mk_mii_end, }
> +	},
> +};
>  /* ------------------------------------------------------------------------- */
>  
>  static phy_info_t const * const phy_info[] = {
> @@ -1137,6 +1157,7 @@ static phy_info_t const * const phy_info[] = {
>  	&phy_info_am79c874,
>  	&phy_info_ks8721bl,
>  	&phy_info_dp83848,
> +	&phy_info_lan8700,
>  	NULL
>  };
>  
> -- 
> 1.6.3.3
> 
> 

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
