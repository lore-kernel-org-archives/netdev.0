From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH v3 2/5] net: dsa: bcm_sf2: cleanup resources in
 remove callback
Date: Thu, 29 Oct 2015 16:17:18 +0100
Message-ID: <20151029151718.GW2307@lunn.ch>
References: <5632310A.8040406@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5632310A.8040406@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 29, 2015 at 03:45:30PM +0100, Neil Armstrong wrote:
> Implement a remove callback allowing the switch driver to cleanup
> resources it used: interrupts and remapped register ranges.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  drivers/net/dsa/bcm_sf2.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
> index 6f946fe..e0be318 100644
> --- a/drivers/net/dsa/bcm_sf2.c
> +++ b/drivers/net/dsa/bcm_sf2.c
> @@ -1054,6 +1054,25 @@ out_unmap:
>  	return ret;
>  }
> 
> +static void bcm_sf2_sw_remove(struct dsa_switch *ds)
> +{
> +	struct bcm_sf2_priv *priv = ds_to_priv(ds);
> +	void __iomem **base;
> +	unsigned int i;
> +
> +	/* Disable all interrupts and free them */
> +	bcm_sf2_intr_disable(priv);
> +
> +	free_irq(priv->irq0, priv);
> +	free_irq(priv->irq1, priv);
> +
> +	base = &priv->core;
> +	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
> +		iounmap(*base);
> +		base++;

Something for Florian to consider. Would it be possible to move to
using devm_ for interrupts and iomem? The question would be, what is
dev?

	Andrew
