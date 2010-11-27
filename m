From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-next: Fix __inet_inherit_port() to correctly
 increment bsockets and num_owners
Date: Sat, 27 Nov 2010 10:02:03 +0100
Message-ID: <1290848523.2794.7.camel@edumazet-laptop>
References: <844781.48196.qm@web53701.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Nagendra Tomar <tomer_iisc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f194.google.com ([74.125.82.194]:47625 "EHLO
	mail-wy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290Ab0K0JCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 04:02:09 -0500
Received: by wyb32 with SMTP id 32so1190183wyb.1
        for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 01:02:08 -0800 (PST)
In-Reply-To: <844781.48196.qm@web53701.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 26 novembre 2010 =C3=A0 16:26 -0800, Nagendra Tomar a =C3=A9=
crit :
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
> 'bsockets' and 'num_owners' were introduced by commit a9d8f9110d7e953=
c=20
> (inet: Allowing more than 64k connections and heavily optimize bind(0=
))
>=20
> Signed-off-by: Nagendra Singh Tomar <tomer_iisc@yahoo.com>
>=20
> ---
> --- linux-2.6.37-rc3/net/ipv4/inet_hashtables.c.orig	2010-11-26 13:28=
:51.034811940 -0500
> +++ linux-2.6.37-rc3/net/ipv4/inet_hashtables.c	2010-11-26 14:41:41.0=
06268035 -0500
> @@ -133,8 +133,7 @@ int __inet_inherit_port(struct sock *sk,
>  			}
>  		}
>  	}
> -	sk_add_bind_node(child, &tb->owners);
> -	inet_csk(child)->icsk_bind_hash =3D tb;
> +	inet_bind_hash(child, tb, port);
>  	spin_unlock(&head->lock);
> =20
>  	return 0;

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !


