From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem with "tcp: bind() fix when many ports are bound" commit
Date: Wed, 28 Apr 2010 19:44:57 +0200
Message-ID: <1272476697.2267.95.camel@edumazet-laptop>
References: <4BD82B29.3000105@retis.net.pl>
	 <20100428.095032.32709294.davem@davemloft.net>
	 <1272476040.2267.87.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: grzegorz.chwesewicz@retis.net.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272476040.2267.87.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 28 avril 2010 =C3=A0 19:34 +0200, Eric Dumazet a =C3=A9crit=
 :
> L
> I am going to test following patch in a couple of hours (I have to
> run ...)
>=20
> Always allowing a reuse LISTEN if no other listener is already active=
 on
> same IP.
>=20
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connecti=
on_sock.c
> index 78cbc39..e2076dd 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -78,6 +78,7 @@ int inet_csk_bind_conflict(const struct sock *sk,
>  				    sk2_rcv_saddr =3D=3D sk_rcv_saddr)
>  					break;
>  			} else if (reuse && sk2->sk_reuse &&
> +				   sk->sk_state !=3D TCP_LISTEN &&
>  				   sk2_rcv_saddr &&
>  				   sk2_rcv_saddr =3D=3D sk_rcv_saddr)
>  				break;
>=20
>=20
> --

Hmm, this wont work because we dont know this sk socket will serve as a
listener.

bind(... port=3D80);

listen(...) or connect(...)

David, I think we should revert patches for linux-2.6, and work on this
problem more closely on net-next-2.6

Thanks
