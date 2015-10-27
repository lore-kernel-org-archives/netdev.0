From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/6] net: dsa: allow switch drivers to cleanup their resources
Date: Tue, 27 Oct 2015 08:39:23 -0700
Message-ID: <562F9AAB.8090202@gmail.com>
References: <562F8ED7.2000804@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562F8ED7.2000804@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/10/15 07:48, Neil Armstrong wrote:
> Some switch drivers might request interrupts, remap register ranges,
> allow such drivers to implement a "remove" callback doing just that.
> 
> Suggested-by: Florian Fainelli <f.fainelli@gmail.com>

This should probably be a Signed-off-by tag, but there is nothing using
this, so you would want to introduce an user of this function in the
same patch series so we see how you intend to use it?

> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  include/net/dsa.h | 1 +
>  net/dsa/dsa.c     | 4 ++++
>  2 files changed, 5 insertions(+)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index d4d13f7..725b11f 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -211,6 +211,7 @@ struct dsa_switch_driver {
>  	 */
>  	char	*(*probe)(struct device *host_dev, int sw_addr);
>  	int	(*setup)(struct dsa_switch *ds);
> +	void	(*remove)(struct dsa_switch *ds);
>  	int	(*set_addr)(struct dsa_switch *ds, u8 *addr);
>  	u32	(*get_phy_flags)(struct dsa_switch *ds, int port);
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index aeb6a7c..7c9914b 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -459,6 +459,10 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
>  	}
> 
>  	mdiobus_unregister(ds->slave_mii_bus);
> +
> +	/* Leave a chance to the driver to cleanup */
> +	if (ds->drv->remove)
> +		ds->drv->remove(ds);
>  }
> 
>  #ifdef CONFIG_PM_SLEEP
> 


-- 
Florian
