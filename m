From: Martijn van Oosterhout <kleptog@svana.org>
Subject: Re: PPP-over-L2TP kernel support, patch for review
Date: Wed, 8 Sep 2004 17:32:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908073238.GB18285@svana.org>
References: <1094471956.413c5114de2d7@www.katalix.com> <20040907155657.2ab6a4bb.davem@davemloft.net>
Reply-To: Martijn van Oosterhout <kleptog@svana.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JYK4vJDZwFMowpUq"
Cc: James Chapman <jchapman@katalix.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040907155657.2ab6a4bb.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--JYK4vJDZwFMowpUq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 07, 2004 at 03:56:57PM -0700, David S. Miller wrote:
> On Mon,  6 Sep 2004 12:59:16 +0100
> James Chapman <jchapman@katalix.com> wrote:
> 2) Does this:
>=20
>  struct sockaddr_pppox {=20
>         sa_family_t     sa_family;            /* address family, AF_PPPOX=
 */=20
>         unsigned int    sa_protocol;          /* protocol identifier */=
=20
>         union{=20
>                 struct pppoe_addr       pppoe;=20
> +               struct pppol2tp_addr    pppol2tp;
>         }sa_addr;=20
>  }__attribute__ ((packed));=20
>=20
>    Change the size of sockaddr_pppox on any platform?  If so, you'll
>    break pppox userspace with this change so we'd need find another
>    way to do it.

By my calculations,=20

sizeof(struct pppoe_addr) =3D 2 + ETH_ALEN + IFNAMSIZ =3D 2 + 6 + 16 =3D 24=
 bytes
sizeof(struct pppol2tp_addr) =3D sizeof(int) + sizeof(sockaddr_in) + 4 * 2
                             =3D 4 + 16 + 8 =3D 28 + possibly padding

So the answer is: I think so. However, I'm not sure why this is an
issue. struct sockaddr is passed back and forth between userspace and
kernelspace has many varying sizes (sockaddr_un is quite large). What
could be affected? getsockname, connect and bind all take a length
argument. Or are you referring to the possibility of it affecting other
structures it's embedded in?

TIA,
--=20
Martijn van Oosterhout   <kleptog@svana.org>   http://svana.org/kleptog/
> Patent. n. Genius is 5% inspiration and 95% perspiration. A patent is a
> tool for doing 5% of the work and then sitting around waiting for someone
> else to do the other 95% so you can sue them.

--JYK4vJDZwFMowpUq
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQFBPrWWY5Twig3Ge+YRAuZBAJ4x7d2TR8mDp0eJpNbluh1PMQlisgCggnKr
SSp/IcrHI3VuhRLscjnIdhM=
=4yOl
-----END PGP SIGNATURE-----

--JYK4vJDZwFMowpUq--
