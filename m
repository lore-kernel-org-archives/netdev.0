From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/1] net: fec: add netif status check before set
 mac address
Date: Tue, 8 Sep 2015 20:37:51 -0700
Message-ID: <55EFA98F.7010700@gmail.com>
References: <1441766567-30689-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: Fugang Duan <b38611@freescale.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:35487 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752623AbbIIDhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 23:37:54 -0400
Received: by obuk4 with SMTP id k4so100973372obu.2
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 20:37:53 -0700 (PDT)
In-Reply-To: <1441766567-30689-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/08/15 19:42, Fugang Duan a =C3=A9crit :
> There exist one issue by below case that case system hang:
> ifconfig eth0 down
> ifconfig eth0 hw ether 00:10:19:19:81:19
>=20
> After eth0 down, all fec clocks are gated off. In the .fec_set_mac_ad=
dress()
> function, it will set new MAC address to registers, which causes syst=
em hang.
>=20
> So it needs to add netif status check to avoid registers access when =
clocks are
> gated off. Until eth0 up the new MAC address are wrote into related r=
egisters.

Since this is a bug fix, do not you intend to target the "net" tree
instead of "net-next"?

>=20
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/=
ethernet/freescale/fec_main.c
> index 91925e3..cd09dbb 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3029,6 +3029,9 @@ fec_set_mac_address(struct net_device *ndev, vo=
id *p)
>  		memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
>  	}
> =20
> +	if (!netif_running(ndev))
> +		return 0;
> +
>  	writel(ndev->dev_addr[3] | (ndev->dev_addr[2] << 8) |
>  		(ndev->dev_addr[1] << 16) | (ndev->dev_addr[0] << 24),
>  		fep->hwp + FEC_ADDR_LOW);
>=20


--=20
=46lorian
