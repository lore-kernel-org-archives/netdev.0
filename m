From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/7] r8169: missing barriers.
Date: Sat, 28 Jan 2012 10:06:46 +0100
Message-ID: <1327741606.7199.0.camel@edumazet-laptop>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
	 <20120127205843.GF24507@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:50600 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199Ab2A1JGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 04:06:51 -0500
Received: by wics10 with SMTP id s10so1971083wic.19
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2012 01:06:50 -0800 (PST)
In-Reply-To: <20120127205843.GF24507@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 27 janvier 2012 =C3=A0 21:58 +0100, Francois Romieu a =C3=A9=
crit :
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index 610f4b3..8dd13f5 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -5552,7 +5552,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk=
_buff *skb,
> =20
>  	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
>  		netif_stop_queue(dev);
> -		smp_rmb();
> +		smp_mb();
>  		if (TX_BUFFS_AVAIL(tp) >=3D MAX_SKB_FRAGS)
>  			netif_wake_queue(dev);
>  	}
> @@ -5653,7 +5653,7 @@ static void rtl8169_tx_interrupt(struct net_dev=
ice *dev,
> =20
>  	if (tp->dirty_tx !=3D dirty_tx) {
>  		tp->dirty_tx =3D dirty_tx;
> -		smp_wmb();
> +		smp_mb();
>  		if (netif_queue_stopped(dev) &&
>  		    (TX_BUFFS_AVAIL(tp) >=3D MAX_SKB_FRAGS)) {
>  			netif_wake_queue(dev);
> @@ -5664,7 +5664,6 @@ static void rtl8169_tx_interrupt(struct net_dev=
ice *dev,
>  		 * of start_xmit activity is detected (if it is not detected,
>  		 * it is slow enough). -- FR
>  		 */
> -		smp_rmb();
>  		if (tp->cur_tx !=3D dirty_tx)
>  			RTL_W8(TxPoll, NPQ);
>  	}

It would be good changelog explains the rationale, or you add comments
in the code.
