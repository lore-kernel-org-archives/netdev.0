From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] skge: add byte queue limit support
Date: Fri, 20 Jan 2012 07:23:44 +0100
Message-ID: <1327040624.4826.10.camel@edumazet-laptop>
References: <20120119164354.78ea63d6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:42355 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687Ab2ATGXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 01:23:49 -0500
Received: by wics10 with SMTP id s10so141000wic.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 22:23:48 -0800 (PST)
In-Reply-To: <20120119164354.78ea63d6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 janvier 2012 =C3=A0 16:43 -0800, Stephen Hemminger a =C3=A9=
crit :
> This also changes the cleanup logic slightly to aggregate
> completed notifications for multiple packets.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> --- a/drivers/net/ethernet/marvell/skge.c	2012-01-19 16:12:19.0000000=
00 -0800
> +++ b/drivers/net/ethernet/marvell/skge.c	2012-01-19 16:42:17.6759087=
98 -0800
> @@ -2831,6 +2831,7 @@ static netdev_tx_t skge_xmit_frame(struc
>  		netif_stop_queue(dev);
>  	}
> =20
> +	netdev_sent_queue(dev, skb->len);


I doubt this is safe, as skb might already be freed by tx completion
handler from another cpu.

>  	return NETDEV_TX_OK;
> =20
>  mapping_unwind:
> @@ -2858,11 +2859,9 @@ mapping_error:
> =20
>=20
