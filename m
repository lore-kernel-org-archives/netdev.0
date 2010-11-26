From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH] net: Fix __inet_inherit_port() to correctly increment bsockets and num_owners
Date: Fri, 26 Nov 2010 03:01:11 -0800 (PST)
Message-ID: <132707.16762.qm@web53707.mail.re2.yahoo.com>
References: <1290768477.2855.97.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53707.mail.re2.yahoo.com ([206.190.37.28]:28665 "HELO
	web53707.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754454Ab0KZLBM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 06:01:12 -0500
In-Reply-To: <1290768477.2855.97.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--- On Fri, 26/11/10, Eric Dumazet <eric.dumazet@gmail.com> wrote:

>=20
> Problem is your patch is not applicable to current tree.
>=20
> In order to submit it to stable team, you should first post
> a patch for
> next/current kernel (net-next-2.6 tree).
>=20

Thanks, Erik.
I'd made the patch against 2.6.36.1 which is the latest stable kernel p=
er kernel.org. I thought that was the right kernel version to make a pa=
tch against.
I do not use git. Shall I make a patch against linux-next as it appears=
 in kernel.org.


> David will decide if its net-2.6 material or not.
>=20
> You could add in your changelog the problem comes from
> commit=20
> a9d8f9110d7e953c (inet: Allowing more than 64k connections
> and heavily
> optimize bind(0)), included in 2.6.30, to ease stable team
> work.
>=20
> On current tree your patch would be :
>=20
> diff --git a/net/ipv4/inet_hashtables.c
> b/net/ipv4/inet_hashtables.c
> index 1b344f3..3c0369a 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -133,8 +133,7 @@ int __inet_inherit_port(struct sock
> *sk, struct sock *child)
>  =A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> }
>  =A0=A0=A0 =A0=A0=A0 }
>  =A0=A0=A0 }
> -=A0=A0=A0 sk_add_bind_node(child,
> &tb->owners);
> -=A0=A0=A0 inet_csk(child)->icsk_bind_hash =3D
> tb;
> +=A0=A0=A0 inet_bind_hash(child, tb, port);
>  =A0=A0=A0 spin_unlock(&head->lock);
> =20
>  =A0=A0=A0 return 0;
>=20
>=20
>=20

Thanks,
Tomar


     =20
