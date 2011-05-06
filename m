From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] ipv4: Initialize on-stack cork more efficiently.
Date: Sat, 07 May 2011 00:35:17 +0200
Message-ID: <1304721317.2821.156.camel@edumazet-laptop>
References: <20110506.152623.232747437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40649 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030Ab1EFWfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 18:35:22 -0400
Received: by wya21 with SMTP id 21so2730060wya.19
        for <netdev@vger.kernel.org>; Fri, 06 May 2011 15:35:21 -0700 (PDT)
In-Reply-To: <20110506.152623.232747437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 06 mai 2011 =C3=A0 15:26 -0700, David Miller a =C3=A9crit :
> ip_setup_cork() explicitly initializes every member of
> inet_cork except flags, addr, and opt.  So we can simply
> set those three members to zero instead of using a
> memset() via an empty struct assignment.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/ip_output.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index eb0647a..5f5fe4f 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1408,7 +1408,7 @@ struct sk_buff *ip_make_skb(struct sock *sk,
>  			    struct ipcm_cookie *ipc, struct rtable **rtp,
>  			    unsigned int flags)
>  {
> -	struct inet_cork cork =3D {};
> +	struct inet_cork cork;
>  	struct sk_buff_head queue;
>  	int err;
> =20
> @@ -1417,6 +1417,9 @@ struct sk_buff *ip_make_skb(struct sock *sk,
> =20
>  	__skb_queue_head_init(&queue);
> =20
> +	cork.flags =3D 0;
> +	cork.addr =3D 0;
> +	cork.opt =3D 0;
>  	err =3D ip_setup_cork(sk, &cork, ipc, rtp);
>  	if (err)
>  		return ERR_PTR(err);

Very nice, thanks for finishing this stuff :)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


