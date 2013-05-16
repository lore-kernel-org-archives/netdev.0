From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 13/33] drivers/net/ethernet/renesas: don't check
 resource with devm_ioremap_resource
Date: Thu, 16 May 2013 08:37:15 -0700
Message-ID: <1368718635.2194.55.camel@joe-AO722>
References: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
	 <1368702961-4325-14-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368702961-4325-14-git-send-email-wsa@the-dreams.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-05-16 at 13:15 +0200, Wolfram Sang wrote:
> devm_ioremap_resource does sanity checks on the given resource. No need to
> duplicate this in the driver.
[]
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
[]
> @@ -2745,11 +2745,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>  	if (mdp->cd->tsu) {
>  		struct resource *rtsu;
>  		rtsu = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> -		if (!rtsu) {
> -			dev_err(&pdev->dev, "Not found TSU resource\n");
> -			ret = -ENODEV;
> -			goto out_release;
> -		}
>  		mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
>  		if (IS_ERR(mdp->tsu_addr)) {
>  			ret = PTR_ERR(mdp->tsu_addr);

I'm not sure it matters, but at least one of these
conversions will now return -EINVAL instead of -ENODEV
