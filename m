From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: bcm43xx regression 2.6.19rc3 -> rc5, rtnl_lock trouble?
Date: Sat, 18 Nov 2006 17:55:55 +0100
Message-ID: <1163868955.27188.2.camel@johannes.berg>
References: <455B63EC.8070704@madrabbit.org>
	<20061118112438.GB15349@nineveh.rivenstone.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1756988532=="
Cc: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>, Ray Lee <ray-lk-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Joseph Fannin <jhf-rN3PHIWzTs1Jm/Hvfsr4+Q@public.gmane.org>
In-Reply-To: <20061118112438.GB15349-JY2TvBve8Und/56dcus+/6462+2Rg2F6@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============1756988532==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-GYTok38B2melWxge36NU"


--=-GYTok38B2melWxge36NU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2006-11-18 at 06:24 -0500, Joseph Fannin wrote:

>     This sounds like what my laptop was doing in -rc5, though mine
> didn't take hours to start acting up.
>=20
>     I *think* it was the MSI troubles, causing interrupts to get
> lost forever.  Anyway, it went away in -rc6.

Hah, that's a lot more plausible than bcm43xx's drain patch actually
causing this. So maybe somehow interrupts for bcm43xx aren't routed
properly or something...

Ray, please check /proc/interrupts when this happens.

I am convinced that the patch in question (drain tx status) is not
causing this -- the patch should be a no-op in most cases anyway, and in
those cases where it isn't a no-op it'll run only once at card init and
remove some things from a hardware-internal FIFO.

johannes

--=-GYTok38B2melWxge36NU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFXzsb/ETPhpq3jKURAm80AJ44eSZHzQHOfpvhKLL3DVH+N2lF3QCgopKQ
ZbcPCp+FSe3daOEimqJv4n8=
=BC0X
-----END PGP SIGNATURE-----

--=-GYTok38B2melWxge36NU--


--===============1756988532==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bcm43xx-dev mailing list
Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/bcm43xx-dev

--===============1756988532==--
