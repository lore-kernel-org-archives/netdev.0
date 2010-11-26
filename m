From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix __inet_inherit_port() to correctly increment
 bsockets and num_owners
Date: Fri, 26 Nov 2010 08:20:31 +0100
Message-ID: <1290756031.2678.15.camel@edumazet-laptop>
References: <801098.19711.qm@web53707.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nagendra Tomar <tomer_iisc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44064 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab0KZHUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 02:20:36 -0500
Received: by wyb28 with SMTP id 28so1629970wyb.19
        for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 23:20:35 -0800 (PST)
In-Reply-To: <801098.19711.qm@web53707.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 novembre 2010 =C3=A0 21:09 -0800, Nagendra Tomar a =C3=A9cr=
it :
> inet sockets corresponding to passive connections are added to the bi=
nd hash
> using ___inet_inherit_port(). These sockets are later removed from th=
e bind=20
> hash using __inet_put_port(). These two functions are not exactly sym=
metrical.=20
> __inet_put_port() decrements hashinfo->bsockets and tb->num_owners, w=
hereas=20
> ___inet_inherit_port() does not increment them. This results in both =
of these=20
> going to -ve values.
>=20
> This patch fixes this by calling inet_bind_hash() from ___inet_inheri=
t_port(),
> which does the right thing.
>=20
> Signed-off-by: Nagendra Singh Tomar <tomer_iisc@yahoo.com>
>=20
> ---
> --- linux-2.6.36.1/net/ipv4/inet_hashtables.c.orig	2010-11-25 14:56:3=
7.902456597 -0500
> +++ linux-2.6.36.1/net/ipv4/inet_hashtables.c	2010-11-25 15:44:15.038=
403317 -0500
> @@ -107,12 +107,10 @@ void __inet_inherit_port(struct sock *sk
>  	const int bhash =3D inet_bhashfn(sock_net(sk), inet_sk(child)->inet=
_num,
>  			table->bhash_size);
>  	struct inet_bind_hashbucket *head =3D &table->bhash[bhash];
> -	struct inet_bind_bucket *tb;
> =20
>  	spin_lock(&head->lock);
> -	tb =3D inet_csk(sk)->icsk_bind_hash;
> -	sk_add_bind_node(child, &tb->owners);
> -	inet_csk(child)->icsk_bind_hash =3D tb;
> +	inet_bind_hash(child, inet_csk(sk)->icsk_bind_hash,=20
> +			inet_sk(child)->inet_num);
>  	spin_unlock(&head->lock);
>  }
>  EXPORT_SYMBOL_GPL(__inet_inherit_port);
> ---
>=20

Interesting, how did you notice it is wrong ?



