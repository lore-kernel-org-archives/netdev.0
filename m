From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: boot test failure (net tree)
Date: Thu, 18 Aug 2011 15:22:14 +1000
Message-ID: <20110818152214.661858a61496993aaef2c704@canb.auug.org.au>
References: <20110817100146.3b557cf815a5a2ae09bc09a7@canb.auug.org.au>
	<20110816.171525.639251389938336183.davem@davemloft.net>
	<20110817105002.efebf85d08460ad99b14be8e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__18_Aug_2011_15_22_14_+1000_.k30Cg4Upky1mi.q"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	Michael Neuling <mikey@neuling.org>,
	Linus <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110817105002.efebf85d08460ad99b14be8e@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__18_Aug_2011_15_22_14_+1000_.k30Cg4Upky1mi.q
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Wed, 17 Aug 2011 10:50:02 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> On Tue, 16 Aug 2011 17:15:25 -0700 (PDT) David Miller <davem@davemloft.ne=
t> wrote:
> >
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Wed, 17 Aug 2011 10:01:46 +1000
> >=20
> > > In particular, CONFIG_TIGON3 newly depends on
> > > CONFIG_NET_VENDOR_BROADCOM which will no be selected when doing a
> > > "make oldconfig" from a working config.
> >=20
> > When you type "make oldconfig" with an existing .config it prompts you
> > for those vendor guards, giving you ample opportunity to say yes to
> > them.
>=20
> Which is a bit of a pain for automated systems.  Ours does (essentially):
>=20
> yes '' | make oldconfig
>=20
> We really don't want to select every new config item that comes along.

So, Mikey did a test for me (he was bitten by this today).  Just one of
the powerpc configs (pseries_defconfig which should, in theory, build a
kernel that will boot on almost all our POWER server machines) loses all
these drivers if you do a "make pseries_defconfig":

 -CONFIG_IBMVETH=3Dy
 -CONFIG_PCNET32=3Dy
 -CONFIG_E100=3Dy
 -CONFIG_ACENIC=3Dm
 -CONFIG_ACENIC_OMIT_TIGON_I=3Dy
 -CONFIG_E1000=3Dy
 -CONFIG_E1000E=3Dy
 -CONFIG_BNX2=3Dm
 -CONFIG_CHELSIO_T3=3Dm
 -CONFIG_CHELSIO_T4=3Dm
 -CONFIG_IXGBE=3Dm
 -CONFIG_IXGB=3Dm
 -CONFIG_S2IO=3Dm
 -CONFIG_MYRI10GE=3Dm
 -CONFIG_NETXEN_NIC=3Dm
 -CONFIG_QLGE=3Dm
 -CONFIG_BE2NET=3Dm

That is just one of our deconfigs ... there are over 400 defconfigs in
the kernel and a lot of them will need to be updated.

Mikey asks:  Will Dave take these updates if we get Acks from the
maintainers?  :-)

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__18_Aug_2011_15_22_14_+1000_.k30Cg4Upky1mi.q
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOTKGGAAoJEDMEi1NhKgbsQsQH/0D4ADXAIvC0vJ2Eeemshibr
Tf+REPKNGzrR0cyGFufZVt31L0uckQlXIkgHv5Eg9A5hbwmCKPd4GfYCMWJ9h5dV
+zqi/NUfU4JeAaMyIswvFAS7w8xgaKXrwxVetxd3D+a5tzJ1VdU8bKlU1B/MwGjn
S7HSYQB81WNnbTOdz36ysjev5cfs98kDk6Odq+HJRS43u36GonHa//46A/OQ791d
tIhR3Er9cu/sX2m+sXStZR/jVMel7ltYjYPvjY8/qU4tU/d8cRkETXoXidayTHBS
AYkuPaPaCPqHXB764e9vg9lTTS1T9UAv2ZzQkgPSaN3FlfpOIMM5vWy4IvsWBCw=
=oW8j
-----END PGP SIGNATURE-----

--Signature=_Thu__18_Aug_2011_15_22_14_+1000_.k30Cg4Upky1mi.q--
