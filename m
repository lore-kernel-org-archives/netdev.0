From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] Include selection of congestion control
 algorithm in that which is inherited across an accept() call
Date: Wed, 30 Nov 2011 06:40:13 +0100
Message-ID: <1322631613.2596.70.camel@edumazet-laptop>
References: <20111130003112.C04FE29005FE@tardy>
	 <1322630461.2596.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: Rick Jones <raj@tardy.cup.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38965 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab1K3FkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 00:40:18 -0500
Received: by eeuu47 with SMTP id u47so74647eeu.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 21:40:17 -0800 (PST)
In-Reply-To: <1322630461.2596.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 06:21 +0100, Eric Dumazet a =C3=A9c=
rit :

> So my suggestion would be to use this two lines patch instead :
>=20
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 945efff..6b066e2 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -495,8 +495,6 @@ struct sock *tcp_create_openreq_child(struct sock=
 *sk, struct request_sock *req,
>  		newtp->frto_counter =3D 0;
>  		newtp->frto_highmark =3D 0;
> =20
> -		newicsk->icsk_ca_ops =3D &tcp_init_congestion_ops;
> -
>  		tcp_set_ca_state(newsk, TCP_CA_Open);
>  		tcp_init_xmit_timers(newsk);
>  		skb_queue_head_init(&newtp->out_of_order_queue);
>=20

Please test this change and if its OK, resubmit your patch, with
appropriate Documentation change, as pointed out by Yuchung Cheng=20

(file to change : Documentation/networking/ip-sysctl.txt )

You could clearly state that the congestion control eventually
chosen by the listener socket takes precedence over the system default
tcp congestion value.

Thanks !
