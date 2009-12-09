From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive
 window.
Date: Wed, 09 Dec 2009 21:33:16 +0100
Message-ID: <4B20098C.8040102@gmail.com>
References: <pvmk4wvc3eb.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com,
	joe@perches.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33549 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754965AbZLIUdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 15:33:20 -0500
In-Reply-To: <pvmk4wvc3eb.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/12/2009 21:13, chavey@google.com a =E9crit :
> Add a sysctl, tcp_init_rcv_wnd, to set the TCP initial receive window
> size advertised by passive and active TCP connections.
> The current Linux TCP implementation limits the advertised TCP initia=
l
> receive window to the one prescribed by slow start. For short lived
> TCP connections used for transaction type of traffic (i.e. http
> requests), bounding the advertised TCP initial receive window results
> in increased latency to complete the transaction. There exists
> environments where strict adherence to using the TCP initial receive
> window used by slow start is un-necessary.
> The tcp_init_rcv_wnd sysctl allows increasing the TCP initial receive
> window for all TCP connections or on a per TCP connection, allowing
> for some of the TCP connection to advertise larger TCP receive window
> than the ones bounded by slow start. Support for setting initial
> congestion window is already supported in the stack but the feature=20
> is useless without the ability to set a larger initial receive window=
=2E
>=20
> Signed-off-by: Laurent Chavey <chavey@google.com>

> index f1813bc..7567edd 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2248,6 +2248,11 @@ static int do_tcp_setsockopt(struct sock *sk, =
int level,
>  		break;
>  #endif
> =20
> +	case TCP_INIT_RCV_WND:
> +		val =3D min_t(int, val, TCP_INIT_RCV_WND_MAX);
> +		tp->rx_opt.init_rcv_wnd =3D val;
> +		break;
> +

If user pass val =3D -1, you end with init_rcv_wnd =3D 255

Is it what you want ?

Probably not :)

Minor nit , your subject should be : [PATCH] tcp: Add sysctl to blablab=
la
