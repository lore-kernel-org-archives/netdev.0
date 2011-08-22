From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [net-next PATCH] tcp: remove useless assignment statement in tcp_keepalive_timer
Date: Mon, 22 Aug 2011 13:46:13 +0300
Message-ID: <201108221346.13210.christoph.paasch@uclouvain.be>
References: <4E52295D.8040901@gmail.com>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=gb18030
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33862 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539Ab1HVKyQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 06:54:16 -0400
In-Reply-To: <4E52295D.8040901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No, if the condition afterwards evaluates to TRUE, and we go to the lab=
el=20
resched, inet_csk_reset_keepalive_timer(...) is called without elapsed =
being=20
set.

Cheers,
Christoph

On Monday 22 August 2011 wrote Li Yu:
> Remove useless assignment statement, it may be trash after refactorin=
g?
>=20
> Signed-off-by: Li Yu <raise.sail@gmail.com>
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index ecd44b0..321ff2f 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -552,8 +552,6 @@ static void tcp_keepalive_timer (unsigned long da=
ta)
>  	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state =3D=3D TCP_CLOSE)
>  		goto out;
>=20
> -	elapsed =3D keepalive_time_when(tp);
> -
>  	/* It is alive without keepalive 8) */
>  	if (tp->packets_out || tcp_send_head(sk))
>  		goto resched;
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=A8=A6 Catholique de Louvain

www.rollerbulls.be
--
