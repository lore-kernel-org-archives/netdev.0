From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: bcmgenet: Use devm_ioremap_resource()
Date: Mon, 24 Feb 2014 09:29:06 -0800
Message-ID: <CAGVrzcZDCJq5vWurOyN-2um9LZp5Hg8UA_XFisqHMh5PjGxDkg@mail.gmail.com>
References: <1393213644-11081-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36724 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbaBXR3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 12:29:46 -0500
Received: by mail-pd0-f180.google.com with SMTP id y10so942841pdj.39
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 09:29:46 -0800 (PST)
In-Reply-To: <1393213644-11081-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-23 19:47 GMT-08:00 Fabio Estevam <festevam@gmail.com>:
> From: Fabio Estevam <fabio.estevam@freescale.com>
>
> According to Documentation/driver-model/devres.txt, devm_request_and_ioremap()
> is deprecated, so use devm_ioremap_resource() instead.

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
> Changes since v1:
> - Fix subject
>
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 0ebc297..844e081 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -2481,10 +2481,9 @@ static int bcmgenet_probe(struct platform_device *pdev)
>         }
>
>         r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> -       priv->base = devm_request_and_ioremap(&pdev->dev, r);
> -       if (!priv->base) {
> -               dev_err(&pdev->dev, "can't ioremap\n");
> -               err = -EINVAL;
> +       priv->base = devm_ioremap_resource(&pdev->dev, r);
> +       if (IS_ERR(priv->base)) {
> +               err = PTR_ERR(priv->base);
>                 goto err;
>         }
>
> --
> 1.8.1.2
>



-- 
Florian
