From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Fri, 16 Dec 2011 22:30:03 +0100
Message-ID: <1324071003.2621.33.camel@edumazet-laptop>
References: <igorm@etf.rs> <1323694834-2844-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49494 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760770Ab1LPVaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 16:30:09 -0500
Received: by wgbdr13 with SMTP id dr13so6883464wgb.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 13:30:07 -0800 (PST)
In-Reply-To: <1323694834-2844-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 d=C3=A9cembre 2011 =C3=A0 05:00 -0800, igorm@etf.rs a =C3=A9=
crit :
> From: Igor Maravic <igorm@etf.rs>
>=20
> Changes to r8169 to use byte queue limits.
>=20
> Signed-off-by: Igor Maravic <igorm@etf.rs>
> Signed-off-by: Igor Maravi=C4=87 <igorm@etf.rs>

Dont forget to CC maintainer of this driver.

> ---
>  drivers/net/ethernet/realtek/r8169.c |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index 36b2a4b..bfdb5fd 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -5326,6 +5326,7 @@ static void rtl8169_tx_clear(struct rtl8169_pri=
vate *tp)
>  {
>  	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
>  	tp->cur_tx =3D tp->dirty_tx =3D 0;
> +	netdev_reset_queue(tp->dev);
>  }
> =20
>  static void rtl8169_schedule_work(struct net_device *dev, work_func_=
t task)
> @@ -5460,6 +5461,8 @@ static int rtl8169_xmit_frags(struct rtl8169_pr=
ivate *tp, struct sk_buff *skb,
>  		txd->opts1 |=3D cpu_to_le32(LastFrag);
>  	}
> =20
> +	netdev_sent_queue(tp->dev, skb->len);
> +

Why here in rtl8169_xmit_frags() ?

If done from rtl8169_start_xmit(), you already have "dev" pointer.

	netdev_sent_queue(dev, skb->len);
