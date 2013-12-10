From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] bgmac: use phy_mii_ioctl in ioctl handler
Date: Tue, 10 Dec 2013 09:11:46 -0800
Message-ID: <CAGVrzcbXb7OkCWe_MiMbcX9vF+=6cWhvRRucoNe9EZKp8xbEFA@mail.gmail.com>
References: <1386668966-24562-1-git-send-email-zajec5@gmail.com> <1386668966-24562-2-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:40759 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754565Ab3LJRM1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 12:12:27 -0500
Received: by mail-pd0-f180.google.com with SMTP id q10so7732749pdj.39
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 09:12:27 -0800 (PST)
In-Reply-To: <1386668966-24562-2-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/10 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
> From: Hauke Mehrtens <hauke@hauke-m.de>
>
> This works pretty much the same way, so avoid duplicating the code.
>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/bgmac.c |   26 +++++------------------=
---
>  1 file changed, 5 insertions(+), 21 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
> index ad4b2f1..db71d75 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -1187,27 +1187,11 @@ static int bgmac_set_mac_address(struct net_d=
evice *net_dev, void *addr)
>  static int bgmac_ioctl(struct net_device *net_dev, struct ifreq *ifr=
, int cmd)
>  {
>         struct bgmac *bgmac =3D netdev_priv(net_dev);
> -       struct mii_ioctl_data *data =3D if_mii(ifr);
> -
> -       switch (cmd) {
> -       case SIOCGMIIPHY:
> -               data->phy_id =3D bgmac->phyaddr;
> -               /* fallthru */
> -       case SIOCGMIIREG:
> -               if (!netif_running(net_dev))
> -                       return -EAGAIN;
> -               data->val_out =3D bgmac_phy_read(bgmac, data->phy_id,
> -                                              data->reg_num & 0x1f);
> -               return 0;
> -       case SIOCSMIIREG:
> -               if (!netif_running(net_dev))
> -                       return -EAGAIN;
> -               bgmac_phy_write(bgmac, data->phy_id, data->reg_num & =
0x1f,
> -                               data->val_in);
> -               return 0;
> -       default:
> -               return -EOPNOTSUPP;
> -       }
> +
> +       if (!netif_running(net_dev))
> +               return -EINVAL;
> +
> +       return phy_mii_ioctl(bgmac->phy_dev, ifr, cmd);
>  }
>
>  static const struct net_device_ops bgmac_netdev_ops =3D {
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
=46lorian
