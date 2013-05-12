From: Laurent Navet <laurent.navet@gmail.com>
Subject: Re: [PATCH] drivers: net: ethernet: broadcom: bcm63xx: use devm_ioremap_resource()
Date: Sun, 12 May 2013 17:53:09 +0200
Message-ID: <CAH7P7Nj7uD05ZeWaOSZ2tBGF=FJ0YMOKYmnTeoKhfmniKAEQzA@mail.gmail.com>
References: <1368374165-3228-1-git-send-email-laurent.navet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cernekee@gmail.com, jogo@openwrt.org, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, Laurent Navet <laurent.navet@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368374165-3228-1-git-send-email-laurent.navet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please, don't take this one

I'll send a more complete one later,
Sorry,

2013/5/12, Laurent Navet <laurent.navet@gmail.com>:
> Replace a call to deprecated devm_request_and_ioremap by
> devm_ioremap_resource.
>
> Found with coccicheck and this semantic patch:
>  scripts/coccinelle/api/devm_ioremap_resource.cocci
>
> Signed-off-by: Laurent Navet <laurent.navet@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bcm63xx_enet.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> index 0b3e23e..9de4217 100644
> --- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> +++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> @@ -1641,9 +1641,9 @@ static int bcm_enet_probe(struct platform_devic=
e
> *pdev)
>  	if (ret)
>  		goto out;
>
> -	priv->base =3D devm_request_and_ioremap(&pdev->dev, res_mem);
> -	if (priv->base =3D=3D NULL) {
> -		ret =3D -ENOMEM;
> +	priv->base =3D devm_ioremap_resource(&pdev->dev, res_mem);
> +	if (IS_ERR(priv->base)) {
> +		ret =3D PTR_ERR(priv->base);
>  		goto out;
>  	}
>
> --
> 1.7.10.4
>
>


--=20
=C2=AB On ne r=C3=A9sout pas un probl=C3=A8me avec les modes de pens=C3=
=A9e qui l=E2=80=99ont engendr=C3=A9. =C2=BB
=C2=AB You cannot solve current problems with current thinking. Current
problems are the result of current thinking =C2=BB
