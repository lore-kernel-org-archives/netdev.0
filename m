From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: recvmsg: Unconditionally zero struct
 sockaddr_storage
Date: Tue, 31 Oct 2017 17:35:36 +0000
Message-ID: <1509471336.2748.58.camel@decadent.org.uk>
References: <20171031161445.GA140874@beast>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-HZUP0jsIH+tMOnLtfBY8"
Cc: Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, security@kernel.org
To: Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031161445.GA140874@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-HZUP0jsIH+tMOnLtfBY8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-10-31 at 09:14 -0700, Kees Cook wrote:
> Some protocols do not correctly wipe the contents of the on-stack
> struct sockaddr_storage sent down into recvmsg() (e.g. SCTP), and leak
> kernel stack contents to userspace. This wipes it unconditionally before
> per-protocol handlers run.
>=20
> Note that leaks like this are mitigated by building with
> CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL=3Dy
>=20
> Reported-by: Alexander Potapenko <glider@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  net/socket.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/net/socket.c b/net/socket.c
> index c729625eb5d3..34183f4fbdf8 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -2188,6 +2188,7 @@ static int ___sys_recvmsg(struct socket *sock, stru=
ct user_msghdr __user *msg,
>  	struct sockaddr __user *uaddr;
>  	int __user *uaddr_len =3D COMPAT_NAMELEN(msg);
> =20
> +	memset(&addr, 0, sizeof(addr));

That's a fairly large structure (128 bytes), most of which won't
normally be used.  We already initialise msg_namelen to 0 before
calling the per-protocol handler, which means by default nothing leaks.
 Only cases where msg_namelen is set but msg_name[] is not initialised
up to that length are a problem.  I would have thought they were not
too hard to find and fix.

Ben.

>  	msg_sys->msg_name =3D &addr;
> =20
>  	if (MSG_CMSG_COMPAT & flags)
> --=20
> 2.7.4
>=20
>=20
--=20
Ben Hutchings
It is a miracle that curiosity survives formal education. - Albert
Einstein


--=-HZUP0jsIH+tMOnLtfBY8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAln4tGgACgkQ57/I7JWG
EQkbuRAAxLx3nIZS93+4DvrdoPVE0s4P7Jdj2yZutC4OnUlLvke1vTKBxvxp9joF
v7E4mhyv+rXp3eNluFNuN2xzLBuWZbw9PAmCxJ0TKqcQkuuhOXGiMS2L7q3Kbna/
yONBUSec3BRmMT1lgdz//k9BoQq5kRC0ak6msVPTbxzMM0LOdOQmCdLM1KzT0M33
qW9Jtw/POTryN4KYoc/vxqE3Gnz3avNYPRNrSXIUVbsB3q+MVqxPv3Oh+s020NAA
21Qo320IQT3pc4CA0WRxJOdmzh/od+ah/Q+WyHrtnmUrtcS0Y5IvwVImDcUzq2IJ
m5Xh2+/XOoPO+7mK3lzyEcZSN6J3tuJMBnDJs93JtekNPHxxRMm7lTDrQ5s1Ctv/
XagPV4YEebL72H9L3wM+w+XumIxJdZBOCUZGzMqUIffu2LDKgKJ0qq8d2fPi+/f1
y72S9OeCA5xG4VSnxU0LT3uHzOaiI/Feq/nsUA+nosFZFy5qMvGZ1zk1isDXAoCE
JIiKLD+5ScbEKebnJ8uxuwJwS7QLi1kVfAsiA592aAqYTT+ju/Hho6f2LpW1GReT
ioLKaUW5+bUJLXNIUqOv0zJMkoLyGfJEydDvrIJDn1oXuu4kn2FTSJVcdsxz0axA
zIgH7PJFg1+pW4MZoNskw6rvOp5QDlxC8r/ysAXEK54vb64LZrQ=
=SWYN
-----END PGP SIGNATURE-----

--=-HZUP0jsIH+tMOnLtfBY8--
