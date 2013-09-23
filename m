From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 36/51] DMA-API: usb: use dma_set_coherent_mask()
Date: Mon, 23 Sep 2013 14:30:48 +0200
Message-ID: <52403478.6010305@atmel.com>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk> <E1VMmHX-0007jq-Cj@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kukjin Kim <kgene.kim@samsung.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felipe Balbi <balbi@ti.com>,
	Alan Stern <stern@rowland.harvard.edu>
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	<alsa-devel@alsa-project.org>, <b43-dev@lists.infradead.org>,
	<devel@driverdev.osuosl.org>, <devicetree@vger.kernel.org>,
	<dri-devel@lists.freedesktop.org>,
	<e1000-devel@lists.sourceforge.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-crypto@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-fbdev@vger.kernel.org>, <linux-ide@vger.kernel.org>,
	<linux-media@vger.kernel.org>, <linux-mmc@vger.kernel.org>,
	<linux-nvme@lists.infradead.org>, <linux-omap@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>,
	<linux-samsung-soc@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<linux-tegra@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	<uclinux-dist-devel@blackfin.uclinux.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1VMmHX-0007jq-Cj@rmk-PC.arm.linux.org.uk>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/09/2013 00:01, Russell King :
> The correct way for a driver to specify the coherent DMA mask is
> not to directly access the field in the struct device, but to use
> dma_set_coherent_mask().  Only arch and bus code should access this
> member directly.
>
> Convert all direct write accesses to using the correct API.
>
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>   drivers/usb/chipidea/ci_hdrc_imx.c |    5 +++--
>   drivers/usb/dwc3/dwc3-exynos.c     |    5 +++--
>   drivers/usb/gadget/lpc32xx_udc.c   |    4 +++-
>   drivers/usb/host/ehci-atmel.c      |    5 +++--

For Atmel driver:

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

[..]

> diff --git a/drivers/usb/host/ehci-atmel.c b/drivers/usb/host/ehci-atmel.c
> index 3b645ff..5831a88 100644
> --- a/drivers/usb/host/ehci-atmel.c
> +++ b/drivers/usb/host/ehci-atmel.c
> @@ -92,8 +92,9 @@ static int ehci_atmel_drv_probe(struct platform_device *pdev)
>   	 */
>   	if (!pdev->dev.dma_mask)
>   		pdev->dev.dma_mask = &pdev->dev.coherent_dma_mask;
> -	if (!pdev->dev.coherent_dma_mask)
> -		pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
> +	retval = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
> +	if (retval)
> +		goto fail_create_hcd;
>
>   	hcd = usb_create_hcd(driver, &pdev->dev, dev_name(&pdev->dev));
>   	if (!hcd) {

[..]

Thanks,
-- 
Nicolas Ferre
