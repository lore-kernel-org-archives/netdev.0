From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 5/5] net: Block MSG_CMSG_COMPAT in send(m)msg and
 recv(m)msg
Date: Thu, 6 Jun 2013 13:29:26 +1000
Message-ID: <20130606132926.f4161ddff87dc9a55e33a8ca@canb.auug.org.au>
References: <cover.1369177867.git.luto@amacapital.net>
	<aa015609319786835bcab445d507faa75c11f111.1369177867.git.luto@amacapital.net>
	<CAEjGV6xcF776C6N6VxeMY0Vyk+X51oNixdbN42-xkWjQOaMEQA@mail.gmail.com>
	<20130606130105.6e51066f@kryten>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__6_Jun_2013_13_29_26_+1000_E=/fZZs.iIOzRqj+"
Cc: Michael Neuling <mikey@neuling.org>, netdev@vger.kernel.org,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	Andy Lutomirski <luto@amacapital.net>,
	Linux PPC dev <linuxppc-dev@ozlabs.org>,
	trinity@vger.kernel.org, torvalds@linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: Anton Blanchard <anton@samba.org>
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <20130606130105.6e51066f@kryten>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__6_Jun_2013_13_29_26_+1000_E=/fZZs.iIOzRqj+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Anton,

On Thu, 6 Jun 2013 13:01:05 +1000 Anton Blanchard <anton@samba.org> wrote:
>
> > This is causing a regression on 64bit powerpc with 32bit usermode.
> > When I hit userspace, udev is broken and I suspect all networking is
> > broken as well.
> >=20
> > Can we please revert 1be374a0518a288147c6a7398792583200a67261
> > upstream?
> >=20
> > Found via bisect.
>=20
> Doesn't this patch break compat_sys_sendmsg and compat_sys_recvmsg?
> We'd need to move the guts of sys_* into compat_sys_* to fix it.

What you really need is a set of common functions that the sys_ and
compat_sys_ functions can call - with the sys_ funtions forbidding
MSG_CMSG_COMPAT and the compat_sys_ functions setting it.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__6_Jun_2013_13_29_26_+1000_E=/fZZs.iIOzRqj+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRsAIbAAoJEECxmPOUX5FEulUP/1n2sOt9T9cvEKjKvQvIUOaA
flR2ZHEs+cLCuyYMxV2XHHYewc/3S7Fzfhl0ZncsiNrodGi21miZq/MEjHg6OoRX
7/FSD1eFNoZ1YyNq6MtJ0lMGurIWML38bdjtxPZ3Z7f/eBffWk3YKKOC3GBRFKis
ZdhBe89SqAqPSJsQEOAzBhuTmKGeQ44cxtIcxjIQiZeY/Wm0B3cV1Phvm3Zg4Zcb
hoBDBbuQtV4QFymSH/r/HxusDknnf1Xoo4Rzdt3oEkgNCrI1cjc+NsXRXRJsHgkp
kPnMC7bEpdFFvPTdr5dE779nTNQCJLX0YU4GWCRYsxdv/avUCAyaCG8/szKpxipi
gnojDDyAdvVBoo0eqYNxLAoWk7TB+30eIljMwR8H2AEB6CME+t57M1BgfzwPFTQh
YcRTXL/5Aj7mSETVuYyxcBOattf4Ct4kgVfZ2WAfUaBEDs6VYdJGUNgeKh9NzjBk
+vitBg2l2hay8qIz1NpPivFclNhETBWxrMsJCXkpXDnAZu8f4LeDF8D6isB/qi48
/WuBeDFvhBRtsZCr9LsLAOqWVBorirHOAdzUfATTpcECItsZFXBgcjLZL4Llyunt
j9h/21GStCn+L1Pw5OxwCnl0Rj0PtBJBWOSFe+B90rTogwQnRddSoNmb+2cEpbTl
8bn27c4NVilsk8z0vFsr
=4vMC
-----END PGP SIGNATURE-----

--Signature=_Thu__6_Jun_2013_13_29_26_+1000_E=/fZZs.iIOzRqj+--
