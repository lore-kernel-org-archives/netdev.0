From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] VSOCK: do not disconnect socket when peer has shutdown
 SEND only
Date: Thu, 5 May 2016 19:23:45 +0100
Message-ID: <20160505182345.GA13284@stefanha-x1.localdomain>
References: <1462368113-5493-1-git-send-email-ian.campbell@docker.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EeQfGwPcQSOJBaQU"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Andy King <acking@vmware.com>,
	Dmitry Torokhov <dtor@vmware.com>,
	Jorgen Hansen <jhansen@vmware.com>,
	Adit Ranadive <aditr@vmware.com>
To: Ian Campbell <ian.campbell@docker.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284AbcEESXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 14:23:48 -0400
Content-Disposition: inline
In-Reply-To: <1462368113-5493-1-git-send-email-ian.campbell@docker.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 04, 2016 at 02:21:53PM +0100, Ian Campbell wrote:
> The peer may be expecting a reply having sent a request and then done a
> shutdown(SHUT_WR), so tearing down the whole socket at this point seems
> wrong and breaks for me with a client which does a SHUT_WR.
>=20
> Looking at other socket family's stream_recvmsg callbacks doing a shutdown
> here does not seem to be the norm and removing it does not seem to have
> had any adverse effects that I can see.

Seems fine to me.

> I'm using Stefan's RFC virtio transport patches, I'm unsure of the impact
> on the vmci transport.
>=20
> Signed-off-by: Ian Campbell <ian.campbell@docker.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Stefan Hajnoczi <stefanha@redhat.com>
> Cc: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
> Cc: Andy King <acking@vmware.com>
> Cc: Dmitry Torokhov <dtor@vmware.com>
> Cc: Jorgen Hansen <jhansen@vmware.com>
> Cc: Adit Ranadive <aditr@vmware.com>
> Cc: netdev@vger.kernel.org
> ---
>  net/vmw_vsock/af_vsock.c | 21 +--------------------
>  1 file changed, 1 insertion(+), 20 deletions(-)
>=20
> diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
> index 1e5f5ed..7a25150 100644
> --- a/net/vmw_vsock/af_vsock.c
> +++ b/net/vmw_vsock/af_vsock.c
> @@ -1789,27 +1789,8 @@ vsock_stream_recvmsg(struct socket *sock, struct m=
sghdr *msg, size_t len,
>  	else if (sk->sk_shutdown & RCV_SHUTDOWN)
>  		err =3D 0;
> =20
> -	if (copied > 0) {
> -		/* We only do these additional bookkeeping/notification steps
> -		 * if we actually copied something out of the queue pair
> -		 * instead of just peeking ahead.
> -		 */
> -
> -		if (!(flags & MSG_PEEK)) {
> -			/* If the other side has shutdown for sending and there
> -			 * is nothing more to read, then modify the socket
> -			 * state.
> -			 */
> -			if (vsk->peer_shutdown & SEND_SHUTDOWN) {
> -				if (vsock_stream_has_data(vsk) <=3D 0) {
> -					sk->sk_state =3D SS_UNCONNECTED;
> -					sock_set_flag(sk, SOCK_DONE);
> -					sk->sk_state_change(sk);
> -				}
> -			}
> -		}
> +	if (copied > 0)
>  		err =3D copied;
> -	}
> =20
>  out:
>  	release_sock(sk);
> --=20
> 2.8.1
>=20

--EeQfGwPcQSOJBaQU
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXK4+xAAoJEJykq7OBq3PIx+gH/iZXHzvTdqwTreLCLQYhXzeY
E+TdMiEHcqobNCzzKTsGEQO6yzVaVbNq3blYSslutUcr5ZtvZwKQ2TWswtnS85yx
SIdHZO7+mqaHKKkSrKMFZBNbmdJrMPVKhH+gTbIkrAUJ8dCHOobku6R983j6oUYa
hE7ZsRY+m3H/7qclt+5WLDZLUQWlKufwl5hiQzMwc9dg6VbiN9F9yIqnGrmBKIWm
vIm2NF6ZOb/Iqn0+0pmvIoOacc/58sJJlaNXYjSB/ef18jn9OmD6+/Nuw3F4WlzY
lYM1bTmULcgJXABFbpQjRM0gohTGRlk7Zv4mE5q4lJUUMWS+IUu+Bwd59H6cqFg=
=UbNd
-----END PGP SIGNATURE-----

--EeQfGwPcQSOJBaQU--
