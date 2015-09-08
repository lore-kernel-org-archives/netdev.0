From: Petr Cvek <petr.cvek@tul.cz>
Subject: Re: [PATCH 2/3] net: irda: pxaficp_ir: convert to readl and writel
Date: Tue, 8 Sep 2015 22:24:09 +0200
Message-ID: <55EF43E9.2040000@tul.cz>
References: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
 <1441261251-19548-3-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Robert Jarzmik <robert.jarzmik@free.fr>,
	Samuel Ortiz <samuel@sortiz.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441261251-19548-3-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dne 3.9.2015 v 08:20 Robert Jarzmik napsal(a):
> Convert the pxa IRDA driver to readl and writel primitives, and remove
> another set of direct registers access. This leaves only the DMA
> registers access, which will be dealt with dmaengine conversion.

Test on magician (nonvanilla, but there should not be any collision).

>  
> -	err = request_mem_region(__PREG(STUART), 0x24, "IrDA") ? 0 : -EBUSY;
> -	if (err)
> -		goto err_mem_1;
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	ficp = devm_ioremap_resource(&pdev->dev, res);
> +	if (IS_ERR(ficp)) {
> +		dev_err(&pdev->dev, "resource ficp not defined\n");

Fails around here with:

[ 4245.368764] pxa2xx-ir pxa2xx-ir: invalid resource
[ 4245.369191] pxa2xx-ir pxa2xx-ir: resource ficp not defined
[ 4245.369364] pxa2xx-ir: probe of pxa2xx-ir failed with error -22

Did you defined resources somewhere? Actual resources are in "pxa_ir_resources" variable at:

	http://lxr.free-electrons.com/source/arch/arm/mach-pxa/devices.c#L386

or this pdata should be moved into specific machine files?

Cheers,
Petr
