From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: RFC [PATCH 2/3] TCP_DEFER_ACCEPT updates: don't retransmit syn-ack
 while waiting for first data byte
Date: Sat, 01 Mar 2008 11:42:51 +0100
Message-ID: <47C9332B.4050207@cosmosbay.com>
References: <1204076945.15970.35.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604003av.neufgp.fr ([84.96.92.124]:59070
	"EHLO neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752147AbYCAKm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 05:42:57 -0500
In-Reply-To: <1204076945.15970.35.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McManus a =E9crit :
> Signed-off-by: Patrick McManus <mcmanus@ducksong.com>
>=20
>     a socket in LISTEN that had completed its 3 way handshake, but no=
t notified
>     userspace because of SO_DEFER_ACCEPT, would retransmit the alread=
y
>     acked syn-ack during the time it was waiting for the first data b=
yte
>     from the peer.
>=20
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connecti=
on_sock.c
> index 03cc323..7216f5e 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -461,8 +461,9 @@ void inet_csk_reqsk_queue_prune(struct sock *pare=
nt,
>                 reqp=3D&lopt->syn_table[i];
>                 while ((req =3D *reqp) !=3D NULL) {
>                         if (time_after_eq(now, req->expires)) {
> -                               if ((req->retrans < (inet_rsk(req)->a=
cked ? max_retries : thresh))
> -                                   && !req->rsk_ops->rtx_syn_ack(par=
ent, req, NULL)) {
> +                               if ((req->retrans < (inet_rsk(req)->a=
cked ? max_retries : thresh))
> +                                   &&  (inet_rsk(req)->acked ||
> +                                        !req->rsk_ops->rtx_syn_ack(p=
arent, req, NULL))) {
>                                         unsigned long timeo;
>=20
>                                         if (req->retrans++ =3D=3D 0)
>=20
>=20

Acked-by: Eric Dumazet <dada1@cosmosbay.com>


