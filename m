From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 01/22] fjes: Introduce FUJITSU Extended Socket Network
 Device driver
Date: Wed, 17 Jun 2015 18:47:40 -0700
Message-ID: <1434592060.2689.85.camel@perches.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
	 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0004.hostedemail.com ([216.40.44.4]:40926 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750861AbbFRBrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 21:47:43 -0400
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-06-18 at 09:49 +0900, Taku Izumi wrote:
> This patch adds the basic code of FUJITSU Extended Socket
> Network Device driver.
[]
> diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
[]
> +static acpi_status fjes_get_acpi_resource(struct acpi_resource *acpi_res,
> +		void *data)
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
> +			addr->address.address_length;

Isn't this missing - 1?
end = start + length - 1; ?


> +static int __init fjes_init_module(void)
> +{
> +	int result;
> +
> +	pr_info("%s - version %s\n",
> +			fjes_driver_string, fjes_driver_version);
> +	pr_info("%s\n", fjes_copyright);

Maybe emit copyright on the same line as version?
