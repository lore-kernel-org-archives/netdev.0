From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] genet:Fix error handling in the function bcmgenet_fini_gma
Date: Wed, 12 Aug 2015 21:13:45 -0700
Message-ID: <55CC1979.2080608@gmail.com>
References: <1439432875-2992-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439432875-2992-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 08/12/15 19:27, Nicholas Krause a =C3=A9crit :
> This fixes error handing in the function bcmgenet_fini_gma to
> properly check if its internal call to the function
> bcm_genet_teardown has failed by returning a error code and if
> so return immediately to this function's caller with a return
> statement as this function call can no longer continue without
> issues arising from the call to the function bcm_genet_teardown.

NACK, this is not a good idea, there are specific reasons why the DMA
teardown can fail, e.g: when no bandwidth has been allocated at the
memory controller level, and we still want to keep tearing down and
freeing up resources while we reconfigure the controller one way or the
other, this can happen while debugging a system, and this is specific t=
o
how GENET is integrated on Broadcom BCM7xxx SoCs.

Also, if you ever need to submit more patches, please look at the git
log history and use consistent prefixes, for this driver this would be
"net: bcmgenet: blah blah"

>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers=
/net/ethernet/broadcom/genet/bcmgenet.c
> index 64c1e9d..50e6183 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -2180,7 +2180,8 @@ static void bcmgenet_fini_dma(struct bcmgenet_p=
riv *priv)
>  	bcmgenet_fini_tx_napi(priv);
> =20
>  	/* disable DMA */
> -	bcmgenet_dma_teardown(priv);
> +	if (bcmgenet_dma_teardown(priv))
> +		return;
> =20
>  	for (i =3D 0; i < priv->num_tx_bds; i++) {
>  		if (priv->tx_cbs[i].skb !=3D NULL) {
>=20


--=20
=46lorian
