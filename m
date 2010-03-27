From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] Add MSG_WAITFORONE flag to recvmmsg
Date: Sat, 27 Mar 2010 07:00:04 +0100
Message-ID: <1269669604.2256.20.camel@edumazet-laptop>
References: <20100326223530.GA11817@xpc.home>
	 <1269643470.2256.17.camel@edumazet-laptop>
	 <84621a61003261555q2c78f6a8o5b438113bed6bd2@mail.gmail.com>
	 <a36005b51003261907x7ebe057bt2d541f63f20f632b@mail.gmail.com>
	 <20100327021803.GA10866@xpc.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Ulrich Drepper <drepper@gmail.com>,
	linux-kernel@vger.kernel.org
To: Brandon L Black <blblack@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100327021803.GA10866@xpc.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 26 mars 2010 =C3=A0 21:18 -0500, Brandon L Black a =C3=A9cr=
it :
> From: Brandon L Black <blblack@gmail.com>
>=20
> Add new flag MSG_WAITFORONE for the recvmmsg() syscall.
> When this flag is specified for a blocking socket, recvmmsg()
> will only block until at least 1 packet is available.  The
> default behavior is to block until all vlen packets are
> available.  This flag has no effect on non-blocking sockets
> or when used in combination with MSG_DONTWAIT.
>=20
> Signed-off-by: Brandon L Black <blblack@gmail.com>
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

> ---
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 7b3aae2..354cc56 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -255,6 +255,7 @@ struct ucred {
>  #define MSG_ERRQUEUE	0x2000	/* Fetch message from error queue */
>  #define MSG_NOSIGNAL	0x4000	/* Do not generate SIGPIPE */
>  #define MSG_MORE	0x8000	/* Sender will send more */
> +#define MSG_WAITFORONE	0x10000	/* recvmmsg(): block until 1+ packets=
 avail */
> =20
>  #define MSG_EOF         MSG_FIN
> =20
> diff --git a/net/socket.c b/net/socket.c
> index 769c386..f55ffe9 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -2135,6 +2135,10 @@ int __sys_recvmmsg(int fd, struct mmsghdr __us=
er *mmsg, unsigned int vlen,
>  			break;
>  		++datagrams;
> =20
> +		/* MSG_WAITFORONE turns on MSG_DONTWAIT after one packet */
> +		if (flags & MSG_WAITFORONE)
> +			flags |=3D MSG_DONTWAIT;
> +
>  		if (timeout) {
>  			ktime_get_ts(timeout);
>  			*timeout =3D timespec_sub(end_time, *timeout);
> --
