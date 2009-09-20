From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ax25: Fix SIOCAX25GETINFO ioctl
Date: Sun, 20 Sep 2009 18:32:55 +0200
Message-ID: <4AB65937.8010508@gmail.com>
References: <alpine.LNX.2.00.0909201226001.29572@cedric.unob.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Jan Rafaj <jr+netfilter-devel@cedric.unob.cz>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48151 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbZITQdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2009 12:33:00 -0400
In-Reply-To: <alpine.LNX.2.00.0909201226001.29572@cedric.unob.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Rafaj a =E9crit :
>=20
> Hello Eric,
>=20
> Your commit 31e6d363abcd0d05766c82f1a9c905a4c974a199 introduces (amon=
g
> other things):
>=20
> diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
> index 61b35b9..da0f64f 100644
> --- a/net/ax25/af_ax25.c
> +++ b/net/ax25/af_ax25.c
> @@ -1780,8 +1781,8 @@ static int ax25_ioctl(struct socket *sock,
> unsigned int cmd, unsigned long arg)
>                 ax25_info.idletimer =3D
> ax25_display_timer(&ax25->idletimer) / (60 * HZ);
>                 ax25_info.n2count   =3D ax25->n2count;
>                 ax25_info.state     =3D ax25->state;
> -               ax25_info.rcv_q     =3D atomic_read(&sk->sk_rmem_allo=
c);
> -               ax25_info.snd_q     =3D atomic_read(&sk->sk_wmem_allo=
c);
> +               ax25_info.rcv_q     =3D sk_wmem_alloc_get(sk);
> +               ax25_info.snd_q     =3D sk_rmem_alloc_get(sk);
>                 ax25_info.vs        =3D ax25->vs;
>                 ax25_info.vr        =3D ax25->vr;
>                 ax25_info.va        =3D ax25->va;
>=20
> I believe there is a typo, correctly this should be:
>=20
>                 ax25_info.idletimer =3D ax25_display_timer(&ax25->idl=
etimer)
> / (60 * HZ);
>                 ax25_info.n2count   =3D ax25->n2count;
>                 ax25_info.state     =3D ax25->state;
> -               ax25_info.rcv_q     =3D atomic_read(&sk->sk_rmem_allo=
c);
> -               ax25_info.snd_q     =3D atomic_read(&sk->sk_wmem_allo=
c);
> +               ax25_info.rcv_q     =3D sk_rmem_alloc_get(sk);
> +               ax25_info.snd_q     =3D sk_wmem_alloc_get(sk);
>                 ax25_info.vs        =3D ax25->vs;
>                 ax25_info.vr        =3D ax25->vr;
>                 ax25_info.va        =3D ax25->va;
>=20
> If this is not fixed in the master, then fix, please.
>=20
> Being a total kernel newbie, I've checked it against Greg K-H's 2.6.3=
1.y
> git tree (but I'm quite unsure whether this is the real HEAD of
> latest [most up to date] development master branch), so if you know w=
here
> I should be looking instead, I'll be grateful for any kicking into th=
e
> right direction... (I somehow feel this should probably be the main
> Linus's syndication tree linux/kernel/git/torvalds/linux-2.6.git - fe=
el
> free to correct me on this one please).
>=20
> Thanks,
>=20
> Jan
>=20
> ---
> Jan Rafaj
> University of Defence in Brno
>=20

Oops, Jan you are absolutely right, this part of the patch was wrong.

Dont worry, David will push your patch to netdev tree, then to Linus.

Thanks

[PATCH] ax25: Fix SIOCAX25GETINFO ioctl

rcv_q & snd_q initializations were reversed in commit
31e6d363abcd0d05766c82f1a9c905a4c974a199
(net: correct off-by-one write allocations reports)

Signed-off-by: Jan Rafaj <jr+netfilter-devel@cedric.unob.cz>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index da0f64f..d6b1b05 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1781,8 +1781,8 @@ static int ax25_ioctl(struct socket *sock, unsign=
ed int cmd, unsigned long arg)
 		ax25_info.idletimer =3D ax25_display_timer(&ax25->idletimer) / (60 *=
 HZ);
 		ax25_info.n2count   =3D ax25->n2count;
 		ax25_info.state     =3D ax25->state;
-		ax25_info.rcv_q     =3D sk_wmem_alloc_get(sk);
-		ax25_info.snd_q     =3D sk_rmem_alloc_get(sk);
+		ax25_info.rcv_q     =3D sk_rmem_alloc_get(sk);
+		ax25_info.snd_q     =3D sk_wmem_alloc_get(sk);
 		ax25_info.vs        =3D ax25->vs;
 		ax25_info.vr        =3D ax25->vr;
 		ax25_info.va        =3D ax25->va;
