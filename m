From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 01/22] fjes: Introduce FUJITSU Extended Socket
 Network Device driver
Date: Tue, 23 Jun 2015 23:50:37 -0700
Message-ID: <1435128637.2504.51.camel@perches.com>
References: <1435114351-6961-1-git-send-email-izumi.taku@jp.fujitsu.com>
	 <1435114554-7151-2-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	stephen@networkplumber.org, yasu.isimatu@gmail.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1435114554-7151-2-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-06-24 at 11:55 +0900, Taku Izumi wrote:
> This patch adds the basic code of FUJITSU Extended Socket
> Network Device driver.

trivial notes:

> diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
[]
> +static int fjes_acpi_add(struct acpi_device *device)
> +{
[]
> +	result =
> +	utf16s_to_utf8s((wchar_t *)str->string.pointer,
> +			str->string.length, UTF16_LITTLE_ENDIAN,
> +			str_buf, sizeof(str_buf) - 1);

I dislike this style as it's not normally used in the kernel.
Most would use another tab indent on the utf16s_to_utf8s line
if the line didn't fit, but this would is more common:

	result = utf16s_to_utf8s((wchar_t *)str->string.pointer,
				 str->string.length, UTF16_LITTLE_ENDIAN,
				 str_buf, sizeof(str_buf) - 1);
> 
> +	/* create platform_device */
> +	plat_dev =
> +	platform_device_register_simple(DRV_NAME, 0, fjes_resource,
> +					ARRAY_SIZE(fjes_resource));

	plat_dev = platform_device_register_simple(DRV_NAME, 0, fjes_resource,
						   ARRAY_SIZE(fjes_resource));

etc...

> +static acpi_status
> +fjes_get_acpi_resource(struct acpi_resource *acpi_res, void *data)
> +{
> +	struct resource *res = data;
> +	struct acpi_resource_address32 *addr;
> +	struct acpi_resource_irq *irq;
> +
> +	switch (acpi_res->type) {
> +	case ACPI_RESOURCE_TYPE_ADDRESS32:
> +		addr = &acpi_res->data.address32;
> +		res[0].start = addr->address.minimum;
> +		res[0].end = addr->address.minimum +
> +			addr->address.address_length - 1;
> +		break;
> +
> +	case ACPI_RESOURCE_TYPE_IRQ:
> +		irq = &acpi_res->data.irq;
> +		if (irq->interrupt_count != 1)
> +			return AE_ERROR;
> +		res[1].start = irq->interrupts[0];
> +		res[1].end = irq->interrupts[0];
> +		break;
> +
> +	default:
> +		break;
> +	}
> +
> +	return AE_OK;
> +}

Is this function used in this compilation?
If not, it's odd to add code that isn't used.

Is it better to make the 2nd argument a
struct resource * rather than a void * ?
