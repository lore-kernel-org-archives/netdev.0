From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] net: i40e: avoid unused function warnings
Date: Wed, 20 Jan 2016 14:44:45 -0800
Message-ID: <1453329885.2958.32.camel@intel.com>
References: <2806620.EpZqDlZTO3@wuerfel>
	 <1453328245.2958.28.camel@intel.com> <8814508.SjLecHrQqA@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ebp7mlNq7FPVjHF2mc1i"
Cc: netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>,
	intel-wired-lan@lists.osuosl.org,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62491 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251AbcATWoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 17:44:46 -0500
In-Reply-To: <8814508.SjLecHrQqA@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ebp7mlNq7FPVjHF2mc1i
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-01-20 at 23:28 +0100, Arnd Bergmann wrote:
> On Wednesday 20 January 2016 14:17:25 Jeff Kirsher wrote:
> > On Wed, 2016-01-20 at 11:42 +0100, Arnd Bergmann wrote:
> > > The addition of the geneve tunnel offload code left a couple
> > > of functions unconditionally defined but empty whenever
> CONFIG_VXLAN
> > > and CONFIG_GENEVE are disabled. gcc warns about this:
> > >=C2=A0
> > > i40e_main.c:7049:13: warning: 'i40e_sync_udp_filters_subtask'
> defined
> > > but not used [-Wunused-function]
> > > i40e_main.c:8516:13: warning: 'i40e_add_vxlan_port' defined but
> not
> > > used [-Wunused-function]
> > > i40e_main.c:8561:13: warning: 'i40e_del_vxlan_port' defined but
> not
> > > used [-Wunused-function]
> > > i40e_main.c:8596:13: warning: 'i40e_add_geneve_port' defined but
> not
> > > used [-Wunused-function]
> > > i40e_main.c:8643:13: warning: 'i40e_del_geneve_port' defined but
> not
> > > used [-Wunused-function]
> > >=C2=A0
> > > This moves the #ifdef statements to the outside of the affected
> > > functions, which avoids the warnings.
> > >=C2=A0
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > > Fixes: 6a899024058d ("i40e: geneve tunnel offload support")
> > > ---
> > > This is a harmless regression against v4.4, found on ARM
> randconfig
> > > builds
> >=C2=A0
> > Thanks Arnd, I already have a patch from Eric Dumazet and Alex
> Duyck to
> > resolve this issue.
> >=C2=A0
> > Dave- I plan on pushing the fix later today to net.
>=20
> Ok, thanks.
>=20
> FWIW, I have another patch for this driver that I did not yet submit
> because it's not a regression and I haven't written a proper
> changelog
> for it (it's in a set of 15 patches for netdev that fix harmless
> warnings).
>=20
> Do you have one for the warning below as well? I could not come up
> with a better way than adding a bogus initialization, but maybe
> there is one.
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Arnd
>=20
> From d89be3f0f932a71dfb5480ee396db514879097c4 Mon Sep 17 00:00:00
> 2001
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Fri, 15 Jan 2016 17:31:07 +0100
> Subject: [PATCH] net: i40e: shut up uninitialized variable warnings
>=20
> intel/i40e/i40e_txrx.c: In function 'i40e_xmit_frame_ring':
> intel/i40e/i40e_txrx.c:2367:20: error: 'oiph' may be used
> uninitialized in this function [-Werror=3Dmaybe-uninitialized]
> intel/i40e/i40e_txrx.c:2317:16: note: 'oiph' was declared here
> intel/i40e/i40e_txrx.c:2367:17: error: 'oudph' may be used
> uninitialized in this function [-Werror=3Dmaybe-uninitialized]
> intel/i40e/i40e_txrx.c:2316:17: note: 'oudph' was declared here
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Yeah, I have a fix for that as well.

You can confirm by pulling my next-queue tree (dev-queue branch).
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git=C2=A0=
d
ev-queue

--=-Ebp7mlNq7FPVjHF2mc1i
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWoA3dAAoJEOVv75VaS+3Os2cP/21bFLibnDpdIFj83q/lcOGA
QLHXVmJUH92C2V9LfiJeftPqZpFIGZcCLdgHR300hgllxZRUL9YtxbMcB4Pm29SA
/VRtvRgrGm8biCR4Tfmi47Y/gP2DY/J3OBZnrBBhp3Aq/XLOCfv0Sha80LM8sxzI
8+Cki+LUb88maAiePT2jNDR/tURgiwK/JLOiUN6MfbBbbu5Iwx1jvQ7HDRWAtxoA
W5UUd8e3kLreAMZJAX7IRrNgg1uvVdvic5vF8goLEmDV1SL47dn6U3dtMGniU5e1
OpueIfUJ4JW9aXQXhqvlNU4Wn83J+5Q0UWnS65VnI3Y7zZyf4cwszKCRv1gO6Nil
b45UMMOwG7gph3kU6mGSFPkzqd8fH+14SuQsft8BrYYRCrxG3IisypFrwltcMfP4
9pammWUDb1GxlwqRbe1hDNT4R13Srhnyw/4GOopLBoJNXC3dQmoEEjPz0eX+kzOp
Eu3LbtNkH0svu8yyFRiubgSK/mkg0+JHmasGtvAiIyULrRab39yYTtmL1Dg+y4ug
Bqby3pAPxWHirpwuikC0LK4AqOCt32pdtinvaBnaQziNyUhRyBglbHoIGT0vhRBn
0obwnjydgo63Zj2fCeH5wRmYAw5PnC1fGMuIl8r3Xo4MD96jcmnuTa9toDd/3qUa
lobnN/rgnqx53UnYGVB3
=xZm2
-----END PGP SIGNATURE-----

--=-Ebp7mlNq7FPVjHF2mc1i--
