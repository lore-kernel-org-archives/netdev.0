From: David Miller <davem@davemloft.net>
Subject: Re: TSO trimming question
Date: Thu, 20 Dec 2007 03:56:21 -0800 (PST)
Message-ID: <20071220.035621.147230372.davem@davemloft.net>
References: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
	<20071219.235450.170670042.davem@davemloft.net>
	<Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	jheffner@psc.edu
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760558AbXLTL4W convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 06:56:22 -0500
In-Reply-To: <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 20 Dec 2007 13:40:51 +0200 (EET)

> [PATCH] [TCP]: Fix TSO deferring
>=20
> I'd say that most of what tcp_tso_should_defer had in between
> there was dead code because of this.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Yikes!!!!!

John, we've been living a lie for more than a year. :-/

On the bright side this explains a lot of small TSO frames I've been
seeing in traces over the past year but never got a chance to
investigate.

> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 8dafda9..693b9f6 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1217,7 +1217,8 @@ static int tcp_tso_should_defer(struct sock *sk=
, struct sk_buff *skb)
>  		goto send_now;
> =20
>  	/* Defer for less than two clock ticks. */
> -	if (!tp->tso_deferred && ((jiffies<<1)>>1) - (tp->tso_deferred>>1) =
> 1)
> +	if (tp->tso_deferred &&
> +	    ((jiffies << 1) >> 1) - (tp->tso_deferred >> 1) > 1)
>  		goto send_now;
> =20
>  	in_flight =3D tcp_packets_in_flight(tp);
