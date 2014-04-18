From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 1/4] mdio_bus: implement devm_mdiobus_alloc/devm_mdiobus_free
Date: Fri, 18 Apr 2014 21:48:28 +0400
Message-ID: <5351656C.6070108@cogentembedded.com>
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

Hello.

On 04/18/2014 09:24 PM, Grygorii Strashko wrote:

> Add a resource managed devm_mdiobus_alloc()/devm_mdiobus_free()
> to automatically clean up MDIO bus alocations made by MDIO drivers,
> thus leading to simplified MDIO drivers code.

> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
[...]

> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 76f54b3..6412beb 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -69,6 +69,74 @@ struct mii_bus *mdiobus_alloc_size(size_t size)
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

    Please re-align this line, so that it starts right under 'dev' on the 
previous line.

WBR, Sergei

