From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] mdio_bus: implement devm_mdiobus_alloc/devm_mdiobus_free
Date: Fri, 04 Apr 2014 17:15:35 +0400
Message-ID: <533EB077.6000005@cogentembedded.com>
References: <1396618825-4241-1-git-send-email-grygorii.strashko@ti.com> <1396618825-4241-2-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davinci-linux-open-source@linux.davincidsp.com,
	linux-doc@vger.kernel.org, Randy Dunlap <rdunlap@infradead.org>,
	linux-kernel@vger.kernel.org, santosh.shilimkar@ti.com,
	"David S. Miller" <davem@davemloft.net>,
	Jonathan Cameron <jic23@kernel.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396618825-4241-2-git-send-email-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04-04-2014 17:40, Grygorii Strashko wrote:

> Add a resource managed devm_mdiobus_alloc()/devm_mdiobus_free()
> to automatically clean up MDIO bus alocations made by MDIO drivers,
> thus leading to simplified MDIO drivers code.

> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
[...]

> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 76f54b3..fdcd6d1 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -69,6 +69,74 @@ struct mii_bus *mdiobus_alloc_size(size_t size)
>   }
>   EXPORT_SYMBOL(mdiobus_alloc_size);
>
> +static void _devm_mdiobus_free(struct device *dev, void *res)
> +{
> +	mdiobus_free(*(struct mii_bus **)res);
> +}
> +
> +static int devm_mdiobus_match(struct device *dev, void *res, void *data)
> +{
> +	struct mii_bus **r = res;

    Please insert an empty line after declaration.

> +	if (!r || !*r) {
> +		WARN_ON(!r || !*r);

    Hm, why we need the duplicate check This condition is always true.

[...]
> +/**
> + * devm_mdiobus_free - Resource-managed mdiobus_free()
> + * @dev:		Device this mii_bus belongs to
> + * @bus:		the mii_bus associated with the device
> + *
> + * Free mii_bus allocated with devm_mdiobus_alloc().
> + */
> +void devm_mdiobus_free(struct device *dev, struct mii_bus *bus)
> +{
> +	int rc;
> +
> +	rc = devres_release(dev, _devm_mdiobus_free,
> +		devm_mdiobus_match, bus);

    Please make this line start under 'dev', according to the networking 
coding style.

[...]

WBR, Sergei
