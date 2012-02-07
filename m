From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sh_eth: fix skb_over_panic happen
Date: Tue, 07 Feb 2012 08:55:10 +0100
Message-ID: <1328601310.2476.3.camel@edumazet-laptop>
References: <4F30CAA8.5050207@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:60790 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624Ab2BGHzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 02:55:15 -0500
Received: by wics10 with SMTP id s10so4705747wic.19
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 23:55:13 -0800 (PST)
In-Reply-To: <4F30CAA8.5050207@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 f=C3=A9vrier 2012 =C3=A0 15:54 +0900, Shimoda, Yoshihiro a =
=C3=A9crit :
> When this GETHER controller received a large frame (about 1800 bytes
> or more), skb_over_panic() happened. This is because the previous
> driver set the RFLR to 0x1000 (4096 bytes) and the skb allocate size
> is smaller than 4096 bytes. So, the controller accepted such a frame.
>=20
> The controller can discard a large frame by the RFLR setting.
> So, the patch modifies the value of RFLR to mtu + ETH_HLEN +
> ETH_FCS_LEN.
>=20
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> ---
>  drivers/net/ethernet/renesas/sh_eth.c |    2 +-
>  drivers/net/ethernet/renesas/sh_eth.h |    3 ---
>  2 files changed, 1 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethe=
rnet/renesas/sh_eth.c
> index 813d41c..9e899b0 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -817,7 +817,7 @@ static int sh_eth_dev_init(struct net_device *nde=
v)
>  		sh_eth_write(ndev, 0, TRIMD);
>=20
>  	/* Recv frame limit set register */
> -	sh_eth_write(ndev, RFLR_VALUE, RFLR);
> +	sh_eth_write(ndev, ndev->mtu + ETH_HLEN + ETH_FCS_LEN, RFLR);
>=20

No VLAN_HDR ?
