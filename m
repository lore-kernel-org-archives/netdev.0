From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH] bfin_mac: fix memleak in mii_bus{probe|remove}
Date: Tue, 18 May 2010 18:05:11 +0800
Message-ID: <AANLkTikcB3f0KmkcnDsV46Xrpm3WcCLQklxbLSJfMTlW@mail.gmail.com>
References: <20100518092839.GA21791@coldcone>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: kirjanov@gmail.com, davem@davemloft.net,
	michael.hennerich@analog.com, sonic.zhang@analog.com,
	cooloney@kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:40604 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab0ERKFN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 06:05:13 -0400
Received: by pxi18 with SMTP id 18so165559pxi.19
        for <netdev@vger.kernel.org>; Tue, 18 May 2010 03:05:13 -0700 (PDT)
In-Reply-To: <20100518092839.GA21791@coldcone>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/5/18 Denis Kirjanov <kirjanov@gmail.com <kirjanov@gmail.com>:
> Fix memory leak with miibus->irq
>
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
> ---
>
> drivers/net/bfin_mac.c | =A0 =A02 ++
> =A01 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
> index 39a54ba..7a17b8a 100644
> --- a/drivers/net/bfin_mac.c
> +++ b/drivers/net/bfin_mac.c
> @@ -1627,6 +1627,7 @@ static int __devinit bfin_mii_bus_probe(struct =
platform_device *pdev)
>
> =A0out_err_mdiobus_register:
> =A0 =A0 =A0 =A0mdiobus_free(miibus);
> + =A0 =A0 =A0 kfree(miibus->irq);

Should you move this kfree before mdiobus_free?

> =A0out_err_alloc:
> =A0 =A0 =A0 =A0peripheral_free_list(pin_req);
>
> @@ -1638,6 +1639,7 @@ static int __devexit bfin_mii_bus_remove(struct=
 platform_device *pdev)
> =A0 =A0 =A0 =A0struct mii_bus *miibus =3D platform_get_drvdata(pdev);
> =A0 =A0 =A0 =A0platform_set_drvdata(pdev, NULL);
> =A0 =A0 =A0 =A0mdiobus_unregister(miibus);
> + =A0 =A0 =A0 kfree(miibus->irq);
> =A0 =A0 =A0 =A0mdiobus_free(miibus);
> =A0 =A0 =A0 =A0peripheral_free_list(pin_req);
> =A0 =A0 =A0 =A0return 0;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
