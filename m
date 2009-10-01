From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Use sk_mark for routing lookup in more places
Date: Thu, 01 Oct 2009 18:30:06 +0200
Message-ID: <4AC4D90E.3040008@gmail.com>
References: <200910011814.47689.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Laszlo Attila Toth <panther@balabit.hu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Atis Elsts <atis@mikrotik.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43777 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382AbZJAQaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 12:30:19 -0400
In-Reply-To: <200910011814.47689.atis@mikrotik.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Atis Elsts a =E9crit :
> This patch against v2.6.31 adds support for route lookup using sk_mar=
k in some=20
> more places. The benefits from this patch are the following.
> First, SO_MARK option now has effect on UDP sockets too.
> Second, ip_queue_xmit() and inet_sk_rebuild_header() could fail to do=
 routing=20
> lookup correctly if TCP sockets with SO_MARK were used.
>=20
> Signed-off-by: Atis Elsts <atis@mikrotik.com>

Good catch, thanks !

I used SO_MARK on connected UDP sockets so did not notice the lack
of functionality. (ip_route_connect() does use sk->sk_mark)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

> ---
>  net/ipv4/af_inet.c   |    1 +
>  net/ipv4/ip_output.c |    1 +
>  net/ipv4/udp.c       |    1 +
>  3 files changed, 3 insertions(+)
>=20
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 566ea6c..7917963 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1103,6 +1103,7 @@ int inet_sk_rebuild_header(struct sock *sk)
>  {
>         struct flowi fl =3D {
>                 .oif =3D sk->sk_bound_dev_if,
> +               .mark =3D sk->sk_mark,
>                 .nl_u =3D {
>                         .ip4_u =3D {
>                                 .daddr  =3D daddr,
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 7ffcd96..e088a97 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -335,6 +335,7 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfrag=
ok)
>=20
>                 {
>                         struct flowi fl =3D { .oif =3D sk->sk_bound_d=
ev_if,
> +                                           .mark =3D sk->sk_mark,
>                                             .nl_u =3D { .ip4_u =3D
>                                                       { .daddr =3D da=
ddr,
>                                                         .saddr =3D in=
et->saddr,
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 80e3812..f90cdcc 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -688,6 +688,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *=
sk,=20
> struct msghdr *msg,
>=20
>         if (rt =3D=3D NULL) {
>                 struct flowi fl =3D { .oif =3D ipc.oif,
> +                                   .mark =3D sk->sk_mark,
>                                     .nl_u =3D { .ip4_u =3D
>                                               { .daddr =3D faddr,
>                                                 .saddr =3D saddr,
> --

