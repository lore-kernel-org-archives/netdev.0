From: Sylwester Nawrocki <sylvester.nawrocki@gmail.com>
Subject: Re: [PATCH v2] net: dm9000: Allow instantiation using device tree
Date: Sun, 19 May 2013 15:27:53 +0200
Message-ID: <5198D359.5060608@gmail.com>
References: <1368962191-32594-1-git-send-email-tomasz.figa@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Tomasz Figa <tomasz.figa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:64282 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467Ab3ESN17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 09:27:59 -0400
Received: by mail-bk0-f53.google.com with SMTP id mx1so738209bkb.12
        for <netdev@vger.kernel.org>; Sun, 19 May 2013 06:27:58 -0700 (PDT)
In-Reply-To: <1368962191-32594-1-git-send-email-tomasz.figa@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 05/19/2013 01:16 PM, Tomasz Figa wrote:
> +++ b/Documentation/devicetree/bindings/net/davicom-dm9000.txt
> @@ -0,0 +1,26 @@
> +Davicom DM9000 Fast Ethernet controller
> +
> +Required properties:
> +- compatible = "davicom,dm9000";
> +- reg : physical addresses and sizes of registers, must contain 2 entries:
> +    first entry : address register,
> +    second entry : address register.

Two address registers ? Shouldn't one of these be "data register" ?

> +Example:
> +
> +	ethernet@18000000 {
> +		compatible = "davicom,dm9000";
> +		reg =<0x18000000 0x2 0x18000004 0x2>;
> +		interrupt-parent =<&gpn>;
> +		interrupts =<7 4>;
> +		local-mac-address = [00 00 de ad be ef];
> +		davicom,no-eeprom;
> +	};

> +static struct dm9000_plat_data *dm9000_parse_dt(struct device *dev)
> +{
> +	struct dm9000_plat_data *pdata;
> +	struct device_node *np = dev->of_node;
> +	const void *mac_addr;
> +
> +	if (!IS_ENABLED(CONFIG_OF) || !np)
> +		return NULL;

Shouldn't ERR_PTR() value be returned here ?

> +	pdata = devm_kzalloc(dev, sizeof(*pdata), GFP_KERNEL);
> +	if (!pdata) {
> +		dev_err(dev, "failed to allocate platform data struct\n");

There is no need for this error log, k*alloc already logs any failures.

> @@ -1373,6 +1402,12 @@ dm9000_probe(struct platform_device *pdev)
>   	int i;
>   	u32 id_val;
>
> +	if (!pdata) {
> +		pdata = dm9000_parse_dt(&pdev->dev);
> +		if (IS_ERR(pdata))
> +			return PTR_ERR(pdata);
> +	}

Thanks,

Sylwester
