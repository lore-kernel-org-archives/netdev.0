From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/4] ll_temac: fix memory leak
Date: Thu, 8 Jul 2010 09:24:41 -0600
Message-ID: <AANLkTin8F8xb5QSOB-3JwEOJLbKFTUOcyg93-SHn4mar@mail.gmail.com>
References: <1278591006-3156-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kernel Janitors <kernel-janitors@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	John Linn <john.linn@xilinx.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Brian Hill <brian.hill@xilinx.com>, netdev@vger.kernel.org
To: Kulikov Vasiliy <segooon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:58172 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116Ab0GHPZD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 11:25:03 -0400
In-Reply-To: <1278591006-3156-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 8, 2010 at 6:10 AM, Kulikov Vasiliy <segooon@gmail.com> wro=
te:
> If of_iomap() or irq_of_parse_and_map() fail then np must be freed.
>
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Looks correct to me.

g.

> ---
> =A0drivers/net/ll_temac_main.c | =A0 =A05 ++++-
> =A01 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.=
c
> index 5bca20b..a2da3d7 100644
> --- a/drivers/net/ll_temac_main.c
> +++ b/drivers/net/ll_temac_main.c
> @@ -999,19 +999,22 @@ temac_of_probe(struct of_device *op, const stru=
ct of_device_id *match)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_dbg(&op->dev, "MEM=
 base: %p\n", lp->sdma_regs);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&op->dev, "una=
ble to map DMA registers\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_node_put(np);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_iounmap;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0lp->rx_irq =3D irq_of_parse_and_map(np, 0);
> =A0 =A0 =A0 =A0lp->tx_irq =3D irq_of_parse_and_map(np, 1);
> +
> + =A0 =A0 =A0 of_node_put(np); /* Finished with the DMA node; drop th=
e reference */
> +
> =A0 =A0 =A0 =A0if ((lp->rx_irq =3D=3D NO_IRQ) || (lp->tx_irq =3D=3D N=
O_IRQ)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&op->dev, "could not determine=
 irqs\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_iounmap_2;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 of_node_put(np); /* Finished with the DMA node; drop th=
e reference */
>
> =A0 =A0 =A0 =A0/* Retrieve the MAC address */
> =A0 =A0 =A0 =A0addr =3D of_get_property(op->dev.of_node, "local-mac-a=
ddress", &size);
> --
> 1.7.0.4
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
