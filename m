From: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Subject: Re: [V2 PATCH 3/5] device property: Introduces device_dma_is_coherent()
Date: Wed, 6 May 2015 18:52:45 -0500
Message-ID: <554AA94D.6020503@amd.com>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <1430838729-21572-4-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <msalter@redhat.com>, <hanjun.guo@linaro.org>,
	<al.stone@linaro.org>, <grant.likely@linaro.org>, <arnd@arndb.de>,
	<leo.duran@amd.com>, <linux-arm-kernel@lists.infradead.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linaro-acpi@lists.linaro.org>, <netdev@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <thomas.lendacky@amd.com>,
	<herbert@gondor.apana.org.au>, <davem@davemloft.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1430838729-21572-4-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafael,

Any comments on this patch?

Thanks,

Suravee

On 5/5/2015 10:12 AM, Suravee Suthikulpanit wrote:
> Currently, device drivers, which support both OF and ACPI,
> need to call two separate APIs, of_dma_is_coherent() and
> acpi_dma_is_coherent()) to determine device coherency attribute.
>
> This patch simplifies this process by introducing a new device
> property API, device_dma_is_coherent(), which calls the appropriate
> interface based on the booting architecture.
>
> Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
> ---
>   drivers/base/property.c  | 12 ++++++++++++
>   include/linux/property.h |  2 ++
>   2 files changed, 14 insertions(+)
>
> diff --git a/drivers/base/property.c b/drivers/base/property.c
> index 1d0b116..8123c6e 100644
> --- a/drivers/base/property.c
> +++ b/drivers/base/property.c
> @@ -14,6 +14,7 @@
>   #include <linux/export.h>
>   #include <linux/kernel.h>
>   #include <linux/of.h>
> +#include <linux/of_address.h>
>   #include <linux/property.h>
>
>   /**
> @@ -519,3 +520,14 @@ unsigned int device_get_child_node_count(struct device *dev)
>   	return count;
>   }
>   EXPORT_SYMBOL_GPL(device_get_child_node_count);
> +
> +bool device_dma_is_coherent(struct device *dev)
> +{
> +	if (IS_ENABLED(CONFIG_OF) && dev->of_node)
> +		return of_dma_is_coherent(dev->of_node);
> +	else if (has_acpi_companion(dev))
> +		return acpi_dma_is_coherent(acpi_node(dev->fwnode));
> +
> +	return false;
> +}
> +EXPORT_SYMBOL_GPL(device_dma_is_coherent);
> diff --git a/include/linux/property.h b/include/linux/property.h
> index de8bdf4..76ebde9 100644
> --- a/include/linux/property.h
> +++ b/include/linux/property.h
> @@ -164,4 +164,6 @@ struct property_set {
>
>   void device_add_property_set(struct device *dev, struct property_set *pset);
>
> +bool device_dma_is_coherent(struct device *dev);
> +
>   #endif /* _LINUX_PROPERTY_H_ */
>


