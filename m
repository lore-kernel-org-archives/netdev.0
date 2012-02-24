From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH V2 4/6] NET: MIPS: lantiq: convert etop to managed gpio
Date: Fri, 24 Feb 2012 14:36:47 +0400
Message-ID: <4F47683F.1010303@mvista.com>
References: <1330012913-13293-1-git-send-email-blogic@openwrt.org> <1330012913-13293-4-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: John Crispin <blogic@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47067 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352Ab2BXKiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 05:38:05 -0500
Received: by bkcjm19 with SMTP id jm19so1847105bkc.19
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2012 02:38:03 -0800 (PST)
In-Reply-To: <1330012913-13293-4-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 23-02-2012 20:01, John Crispin wrote:

> ltq_gpio_request() now uses devres to manage the gpios. We need to pass a
> struct device pointer to make it work.

> Signed-off-by: John Crispin<blogic@openwrt.org>
> Cc: netdev@vger.kernel.org
> ---
>   drivers/net/ethernet/lantiq_etop.c |    9 ++++++---
>   1 files changed, 6 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
> index 66ec54a..e5ec8b1 100644
> --- a/drivers/net/ethernet/lantiq_etop.c
> +++ b/drivers/net/ethernet/lantiq_etop.c
> @@ -292,9 +292,6 @@ ltq_etop_gbit_init(void)
>   {
>   	ltq_pmu_enable(PMU_SWITCH);
>
> -	ltq_gpio_request(42, 2, 1, "MDIO");
> -	ltq_gpio_request(43, 2, 1, "MDC");
> -
>   	ltq_gbit_w32_mask(0, GCTL0_SE, LTQ_GBIT_GCTL0);
>   	/** Disable MDIO auto polling mode */
>   	ltq_gbit_w32_mask(0, PX_CTL_DMDIO, LTQ_GBIT_P0_CTL);
> @@ -873,6 +870,12 @@ ltq_etop_probe(struct platform_device *pdev)
>   			err = -ENOMEM;
>   			goto err_out;
>   		}
> +		if (ltq_gpio_request(&pdev->dev, 42, 2, 1, "MDIO") ||
> +				ltq_gpio_request(&pdev->dev, 43, 2, 1, "MDC")) {

    This needs to be merged with patch 1 to keep the git tree bisectable

WBR, Sergei
