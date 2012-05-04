From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 04/15] drivers/net: Do not free an IRQ if its request
 failed
Date: Fri, 04 May 2012 15:10:35 +0100
Message-ID: <4FA3E35B.3000604@linaro.org>
References: <1334867804-31942-1-git-send-email-lee.jones@linaro.org> <1334867804-31942-5-git-send-email-lee.jones@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, arnd@arndb.de,
	linus.walleij@stericsson.com, grant.likely@secretlab.ca,
	cjb@laptop.org, linux@arm.linux.org.uk, netdev@vger.kernel.org
To: Lee Jones <lee.jones@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57516 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585Ab2EDOKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 10:10:41 -0400
Received: by bkcji2 with SMTP id ji2so2244997bkc.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 07:10:40 -0700 (PDT)
In-Reply-To: <1334867804-31942-5-git-send-email-lee.jones@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/04/12 21:36, Lee Jones wrote:
> Refrain from attempting to free an interrupt line if the request
> fails and hence, there is no IRQ to free.
>
> CC: netdev@vger.kernel.org
> Signed-off-by: Lee Jones<lee.jones@linaro.org>
> ---
>   drivers/net/ethernet/smsc/smsc911x.c |    3 +--
>   1 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ether=
net/smsc/smsc911x.c
> index 4a69710..f17a76e 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -2382,7 +2382,6 @@ static int __devinit smsc911x_drv_probe(struct =
platform_device *pdev)
>   	SET_NETDEV_DEV(dev,&pdev->dev);
>
>   	pdata =3D netdev_priv(dev);
> -
>   	dev->irq =3D irq_res->start;
>   	irq_flags =3D irq_res->flags&  IRQF_TRIGGER_MASK;
>   	pdata->ioaddr =3D ioremap_nocache(res->start, res_size);
> @@ -2446,7 +2445,7 @@ static int __devinit smsc911x_drv_probe(struct =
platform_device *pdev)
>   	if (retval) {
>   		SMSC_WARN(pdata, probe,
>   			  "Unable to claim requested irq: %d", dev->irq);
> -		goto out_free_irq;
> +		goto out_disable_resources;
>   	}
>
>   	retval =3D register_netdev(dev);

Anything on this from the Net guys?

Kind regards,
Lee

--=20
Lee Jones
Linaro ST-Ericsson Landing Team Lead
M: +44 77 88 633 515
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
