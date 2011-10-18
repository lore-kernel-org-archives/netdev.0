From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] pktgen: bug when calling ndelay in x86 architectures
Date: Tue, 18 Oct 2011 13:56:47 +0200
Message-ID: <1318939007.2657.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E9D5E1B.3080704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Voravit Tanyingyong <voravit@kth.se>,
	Jens Laas <jens.laas@uadm.uu.se>
To: Daniel Turull <daniel.turull@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42145 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754854Ab1JRL42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 07:56:28 -0400
Received: by eye27 with SMTP id 27so461975eye.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 04:56:27 -0700 (PDT)
In-Reply-To: <4E9D5E1B.3080704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 13:08 +0200, Daniel Turull a =C3=A9crit=
 :
> The value selected to delay the transmission in pktgen with the ndela=
y function should be lower.
> In Linux/arch/x86/include/asm/delay.h and Linux/arch/sh/include/asm/d=
elay.h
> the maximal expected value for a constant is 20000 ns.
>=20
> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
> ---
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 796044a..e17bd41 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2145,7 +2145,7 @@ static void spin(struct pktgen_dev *pkt_dev, kt=
ime_t spin_until)
>  	}
> =20
>  	start_time =3D ktime_now();
> -	if (remaining < 100000)
> +	if (remaining < 20000)
>  		ndelay(remaining);	/* really small just spin */
>  	else {
>  		/* see do_nanosleep */

But 'remaining' is not a constant.

If we want exactly 40.000 packets per second rate (25 us between
packets), your patch makes this not quite possible without
CONFIG_HIGH_RES_TIMERS and probable high jitter because of scheduler
effects.

pktgen is kind of special, we _want_ a cpu for our exclusive use.
