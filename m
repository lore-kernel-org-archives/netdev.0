From: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Subject: Re: [PATCH] sh_eth: Fix memleak in sh_mdio_release
Date: Fri, 21 May 2010 07:12:21 +0900
Message-ID: <AANLkTikXzLHCwIFashAm1Z22Mw6n0TxC0AcBc4ER7zI6@mail.gmail.com>
References: <20100520140059.GA8968@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shimoda.yoshihiro@renesas.com,
	morimoto.kuninori@renesas.com, netdev@vger.kernel.org
To: Denis Kirjanov <dkirjanov@hera.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:43323 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866Ab0ETWMo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 18:12:44 -0400
Received: by iwn6 with SMTP id 6so380589iwn.19
        for <netdev@vger.kernel.org>; Thu, 20 May 2010 15:12:43 -0700 (PDT)
In-Reply-To: <20100520140059.GA8968@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Denis.

2010/5/20 Denis Kirjanov <dkirjanov@hera.kernel.org>:
> Allocated memory for IRQs should be freed when releasing the mii_bus
>
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
> ---
>
> drivers/net/sh_eth.c | =A0 =A03 +++
> =A01 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
> index 586ed09..501a55f 100644
> --- a/drivers/net/sh_eth.c
> +++ b/drivers/net/sh_eth.c
> @@ -1294,6 +1294,9 @@ static int sh_mdio_release(struct net_device *n=
dev)
> =A0 =A0 =A0 =A0/* remove mdio bus info from net_device */
> =A0 =A0 =A0 =A0dev_set_drvdata(&ndev->dev, NULL);
>
> + =A0 =A0 =A0 /* free interrupts memory */
> + =A0 =A0 =A0 kfree(bus->irq);
> +
> =A0 =A0 =A0 =A0/* free bitbang info */
> =A0 =A0 =A0 =A0free_mdio_bitbang(bus);
>
>
Acked-by: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>

Thanks!

Best regards,
  Nobuhiro
