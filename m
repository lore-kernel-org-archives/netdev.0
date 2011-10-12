From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 2/5] stmmac: allow mtu bigger than 1500 in case of
 normal desc (V2).
Date: Wed, 12 Oct 2011 21:58:01 +0200
Message-ID: <1318449481.2644.11.camel@edumazet-laptop>
References: <1318426688-9419-1-git-send-email-peppe.cavallaro@st.com>
	 <1318426688-9419-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Deepak SIKRI <deepak.sikri@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39942 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076Ab1JLT6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 15:58:06 -0400
Received: by wwf22 with SMTP id 22so583820wwf.1
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2011 12:58:05 -0700 (PDT)
In-Reply-To: <1318426688-9419-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 octobre 2011 =C3=A0 15:38 +0200, Giuseppe CAVALLARO a =C3=
=A9crit :
> This patch allows to set the mtu bigger than 1500
> in case of normal descriptors.
> This is helping some SPEAr customers.
>=20
> Signed-off-by: Deepak SIKRI <deepak.sikri@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driv=
ers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index ba7af2c..de3e536 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1357,17 +1357,17 @@ static void stmmac_set_rx_mode(struct net_dev=
ice *dev)
>  static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
>  {
>  	struct stmmac_priv *priv =3D netdev_priv(dev);
> -	int max_mtu;
> +	int max_mtu =3D ETH_DATA_LEN;

Why are you setting max_mtu to ETH_DATA_LEN here ?

> =20
>  	if (netif_running(dev)) {
>  		pr_err("%s: must be stopped to change its MTU\n", dev->name);
>  		return -EBUSY;
>  	}
> =20
> -	if (priv->plat->has_gmac)
> +	if (priv->plat->enh_desc)
>  		max_mtu =3D JUMBO_LEN;
>  	else
> -		max_mtu =3D ETH_DATA_LEN;
> +		max_mtu =3D BUF_SIZE_4KiB;

Since later you init to completely different values...
