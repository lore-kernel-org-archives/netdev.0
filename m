From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] b44: add calls to phy_{start,stop}
Date: Sun, 02 Mar 2014 10:53:10 -0800
Message-ID: <6403851.S1rVbK2KGG@lenovo>
References: <1393777774-7400-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, zambrano@broadcom.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:37574 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbaCBSxN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 13:53:13 -0500
Received: by mail-ob0-f179.google.com with SMTP id va2so1229349obc.10
        for <netdev@vger.kernel.org>; Sun, 02 Mar 2014 10:53:13 -0800 (PST)
In-Reply-To: <1393777774-7400-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 2 mars 2014, 17:29:33 Hauke Mehrtens a =E9crit :
> When support for external phys was added to b44, the calls to start a=
nd
> stop the phy were missing in the mac driver. This adds the calls to
> phy_start() and phy_stop().
>=20
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/b44.c |    7 +++++++
>  1 file changed, 7 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/broadcom/b44.c
> b/drivers/net/ethernet/broadcom/b44.c index 1f7b5aa..e8046e1 100644
> --- a/drivers/net/ethernet/broadcom/b44.c
> +++ b/drivers/net/ethernet/broadcom/b44.c
> @@ -1484,6 +1484,10 @@ static int b44_open(struct net_device *dev)
>  	add_timer(&bp->timer);
>=20
>  	b44_enable_ints(bp);
> +
> +	if (bp->flags & B44_FLAG_EXTERNAL_PHY)
> +		phy_start(bp->phydev);
> +
>  	netif_start_queue(dev);
>  out:
>  	return err;
> @@ -1646,6 +1650,9 @@ static int b44_close(struct net_device *dev)
>=20
>  	netif_stop_queue(dev);
>=20
> +	if (bp->flags & B44_FLAG_EXTERNAL_PHY)
> +		phy_stop(bp->phydev);
> +
>  	napi_disable(&bp->napi);
>=20
>  	del_timer_sync(&bp->timer);

--=20
=46lorian
