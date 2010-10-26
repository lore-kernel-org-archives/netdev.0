From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] qlcnic: dma address align check
Date: Tue, 26 Oct 2010 11:54:54 +0200
Message-ID: <1288086894.3169.53.camel@edumazet-laptop>
References: <1288085882-11988-1-git-send-email-amit.salecha@qlogic.com>
	 <1288085882-11988-5-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47818 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755093Ab0JZJy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 05:54:58 -0400
Received: by wwe15 with SMTP id 15so4545030wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 02:54:57 -0700 (PDT)
In-Reply-To: <1288085882-11988-5-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 02:38 -0700, Amit Kumar Salecha a =C3=A9=
crit :
> Device requires tx_hw_cosnumer to be 64 byte aligned.
> Tx desc size is 64 byte, alloc tx_hw_consumer with tx desc.
>=20
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> ---
>  drivers/net/qlcnic/qlcnic_ctx.c |   35 +++++++++++++++--------------=
------
>  1 files changed, 15 insertions(+), 20 deletions(-)
>=20
> diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlc=
nic_ctx.c
> index 1cdc05d..21c9c28 100644
> --- a/drivers/net/qlcnic/qlcnic_ctx.c
> +++ b/drivers/net/qlcnic/qlcnic_ctx.c
> @@ -418,18 +418,9 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adap=
ter *adapter)
>  	recv_ctx =3D &adapter->recv_ctx;
>  	tx_ring =3D adapter->tx_ring;
> =20
> -	tx_ring->hw_consumer =3D (__le32 *)pci_alloc_consistent(pdev, sizeo=
f(u32),
> -						&tx_ring->hw_cons_phys_addr);
> -	if (tx_ring->hw_consumer =3D=3D NULL) {
> -		dev_err(&pdev->dev, "failed to allocate tx consumer\n");
> -		return -ENOMEM;
> -	}
> -	*(tx_ring->hw_consumer) =3D 0;
> -
>  	/* cmd desc ring */
> -	addr =3D pci_alloc_consistent(pdev, TX_DESC_RINGSIZE(tx_ring),
> -			&tx_ring->phys_addr);
> -
> +	addr =3D pci_alloc_consistent(pdev, TX_DESC_RINGSIZE(tx_ring) +
> +			sizeof(u32), &tx_ring->phys_addr);

Wont this use twice memory than before, due to power-of-two
allocations ?

Allocating 65536 + 4 bytes gives you 131072 bytes.


