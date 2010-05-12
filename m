From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: avoid TX timeout when stopping device
Date: Wed, 12 May 2010 11:27:38 +0200
Message-ID: <1273656458.2621.22.camel@edumazet-laptop>
References: <20100512110921.0e3f45fc@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eilon Greenstein <eilong@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38076 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab0ELJ1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 05:27:42 -0400
Received: by fxm15 with SMTP id 15so96509fxm.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 02:27:40 -0700 (PDT)
In-Reply-To: <20100512110921.0e3f45fc@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 mai 2010 =C3=A0 11:09 +0200, Stanislaw Gruszka a =C3=A9c=
rit :
> When stop device call netif_carrier_off() just after disabling TX que=
ue to
> avoid possibility of netdev watchdog warning and ->ndo_tx_timeout() i=
nvocation.
>=20
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---

This reminds me I saw some strange things in bnx2.c for a similar
symptom.

Commit e6bf95ffa8d6f8f4b7ee33ea01490d95b0bbeb6e

Would you take a look at this too ?

Or if this kind of trans_start refresh on all queues is really needed,
it should be a core network provided function, not implemented on every
driver...

Thanks :)

>  drivers/net/bnx2x_main.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 2bc35c7..57ff5b3 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -8499,6 +8499,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, i=
nt unload_mode)
> =20
>  	/* Disable HW interrupts, NAPI and Tx */
>  	bnx2x_netif_stop(bp, 1);
> +	netif_carrier_off(bp->dev);
> =20
>  	del_timer_sync(&bp->timer);
>  	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
> @@ -8524,8 +8525,6 @@ static int bnx2x_nic_unload(struct bnx2x *bp, i=
nt unload_mode)
> =20
>  	bp->state =3D BNX2X_STATE_CLOSED;
> =20
> -	netif_carrier_off(bp->dev);
> -
>  	/* The last driver must disable a "close the gate" if there is no
>  	 * parity attention or "process kill" pending.
>  	 */
> @@ -13431,6 +13430,7 @@ static int bnx2x_eeh_nic_unload(struct bnx2x =
*bp)
>  	bp->rx_mode =3D BNX2X_RX_MODE_NONE;
> =20
>  	bnx2x_netif_stop(bp, 0);
> +	netif_carrier_off(bp->dev);
> =20
>  	del_timer_sync(&bp->timer);
>  	bp->stats_state =3D STATS_STATE_DISABLED;
> @@ -13457,8 +13457,6 @@ static int bnx2x_eeh_nic_unload(struct bnx2x =
*bp)
> =20
>  	bp->state =3D BNX2X_STATE_CLOSED;
> =20
> -	netif_carrier_off(bp->dev);
> -
>  	return 0;
>  }
> =20


