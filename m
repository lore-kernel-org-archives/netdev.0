From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: RFC [PATCH 1/3] TCP_DEFER_ACCEPT updates: defer timeouts conflict
 with max_thresh
Date: Sat, 01 Mar 2008 11:41:50 +0100
Message-ID: <47C932EE.4090903@cosmosbay.com>
References: <1204076941.15970.34.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev@vger.kernel.org
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:48894
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751547AbYCAKl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 05:41:56 -0500
In-Reply-To: <1204076941.15970.34.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McManus a =E9crit :
> Signed-off-by: Patrick McManus <mcmanus@ducksong.com>
>=20
>     timeout associated with SO_DEFER_ACCEPT wasn't being honored if i=
t was
>     less than the timeout allowed by the maximum syn-recv queue size
>     algorithm. Fix by using the SO_DEFER_ACCEPT value if the ack has
>     arrived.
>=20
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connecti=
on_sock.c
> index b189278..03cc323 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -461,8 +461,7 @@ void inet_csk_reqsk_queue_prune(struct sock *pare=
nt,
>                 reqp=3D&lopt->syn_table[i];
>                 while ((req =3D *reqp) !=3D NULL) {
>                         if (time_after_eq(now, req->expires)) {
> -                               if ((req->retrans < thresh ||
> -                                    (inet_rsk(req)->acked && req->re=
trans < max_retries))
> +                               if ((req->retrans < (inet_rsk(req)->a=
cked ? max_retries : thresh))
>                                     && !req->rsk_ops->rtx_syn_ack(par=
ent, req, NULL)) {
>                                         unsigned long timeo;
>=20
>=20
>=20

Acked-by: Eric Dumazet <dada1@cosmosbay.com>

