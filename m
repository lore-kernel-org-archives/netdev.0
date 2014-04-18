From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 1/4] mdio_bus: implement devm_mdiobus_alloc/devm_mdiobus_free
Date: Fri, 18 Apr 2014 21:52:16 +0400
Message-ID: <53516650.3000405@cogentembedded.com>
References: <1397841897-9170-1-git-send-email-grygorii.strashko@ti.com> <1397841897-9170-2-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@infradead.org>,
	Jonathan Cameron <jic23@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	prabhakar.csengg@gmail.com, santosh.shilimkar@ti.com,
	Sekhar Nori <nsekhar@ti.com>, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1397841897-9170-2-git-send-email-grygorii.strashko@ti.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/18/2014 09:24 PM, Grygorii Strashko wrote:

> Add a resource managed devm_mdiobus_alloc()/devm_mdiobus_free()
> to automatically clean up MDIO bus alocations made by MDIO drivers,
> thus leading to simplified MDIO drivers code.

> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
[...]

> index 76f54b3..6412beb 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -69,6 +69,74 @@ struct mii_bus *mdiobus_alloc_size(size_t size)
[...]
> +/**
> + * devm_mdiobus_alloc - Resource-managed mdiobus_alloc_size()
> + * @dev:		Device to allocate mii_bus for
> + * @sizeof_priv:	Space to allocate for private structure.
> + *
> + * Managed mdiobus_alloc_size. mii_bus allocated with this function is
> + * automatically freed on driver detach.
> + *
> + * If an mii_bus allocated with this function needs to be freed separately,
> + * devm_mdiobus_free() must be used.
> + *
> + * RETURNS:
> + * Pointer to allocated mii_bus on success, NULL on failure.
> + */
> +struct mii_bus *devm_mdiobus_alloc(struct device *dev, int sizeof_priv)
> +{
> +	struct mii_bus **ptr, *bus;
> +
> +	ptr = devres_alloc(_devm_mdiobus_free, sizeof(*ptr),
> +			   GFP_KERNEL);
> +	if (!ptr)
> +		return NULL;
> +
> +	/* use raw alloc_dr for kmalloc caller tracing */
> +	bus = mdiobus_alloc_size(sizeof_priv);

    Since the wrapped function is called mdiobus_alloc_size(), not 
mdiobus_alloc(), perhaps it's better to call the wrapper 
devm_mdiobus_alloc_size()?

WBR, Sergei

