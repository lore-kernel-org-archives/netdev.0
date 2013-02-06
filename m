From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 1/4] bgmac: implement missing code for BCM53572
Date: Wed, 6 Feb 2013 15:54:13 +0100
Message-ID: <CACna6rxrQYYs7rM53Bt6mL7zeJWzrYJKh1CYgPDO3TGwJVCyhg@mail.gmail.com>
References: <1360161900-2330-1-git-send-email-hauke@hauke-m.de>
	<1360161900-2330-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:52200 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294Ab3BFOyO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 09:54:14 -0500
Received: by mail-ob0-f179.google.com with SMTP id un3so1506768obb.38
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 06:54:14 -0800 (PST)
In-Reply-To: <1360161900-2330-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/6 Hauke Mehrtens <hauke@hauke-m.de>:
>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
>  drivers/net/ethernet/broadcom/bgmac.c |    6 ++++--
>  drivers/net/ethernet/broadcom/bgmac.h |    2 +-
>  2 files changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
> index 9bd33db..58e0c70 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -889,8 +889,10 @@ static void bgmac_chip_reset(struct bgmac *bgmac=
)
>                         sw_type =3D et_swtype;
>                 } else if (ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->=
pkg =3D=3D 9) {
>                         sw_type =3D BGMAC_CHIPCTL_1_SW_TYPE_EPHYRMII;
> -               } else if (0) {
> -                       /* TODO */
> +               } else if ((ci->id !=3D BCMA_CHIP_ID_BCM53572 && ci->=
pkg =3D=3D 10) ||
> +                          (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci=
->pkg =3D=3D 9)) {
> +                       sw_type =3D BGMAC_CHIPCTL_1_IF_TYPE_RGMII |
> +                                 BGMAC_CHIPCTL_1_SW_TYPE_RGMII;

Check "chippkg is 10" looked too generous for me, that's why I didn't
implement this part. "ci->id !=3D BCMA_CHIP_ID_BCM53572" doesn't make i=
t
much better, but OK, if that's the way it is... ;)

Could you update specs?
http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipreset

--=20
Rafa=C5=82
