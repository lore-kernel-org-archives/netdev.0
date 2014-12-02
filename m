From: Andrey Skvortsov <andrej.skvortzov@gmail.com>
Subject: Re: [PATCH] SSB / B44: fix WOL for BCM4401
Date: Tue, 2 Dec 2014 23:01:29 +0300
Message-ID: <20141202200129.GA4580@crion89>
References: <20141201111125.GA11974@localhost.localdomain>
 <1417466798-15735-1-git-send-email-Andrej.Skvortzov@gmail.com>
 <20141201221023.79ffb40d@wiggum>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="DocE+STaALJfprDB"
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Gary.Zambrano@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	b43-dev <b43-dev@lists.infradead.org>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Michael =?utf-8?B?QsO8c2No?= <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141201221023.79ffb40d@wiggum>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 01, 2014 at 10:10:23PM +0100, Michael B=C3=BCsch wrote:
> On Mon,  1 Dec 2014 23:46:38 +0300
> Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:
>=20
> > Wake On Lan was not working on laptop DELL Vostro 1500.
> > If WOL was turned on, BCM4401 was powered up in suspend mode. LEDs blin=
ked.
> > But the laptop could not be woken up with the Magic Packet. The reason =
for
> > that was that PCIE was not enabled as a system wakeup source and
> > therefore the host PCI bridge was not powered up in suspend mode.
> > PCIE was not enabled in suspend by PM because no child devices were
> > registered as wakeup source during suspend process.
> > On laptop BCM4401 is connected through the SSB bus, that is connected t=
o the
> > PCI-Express bus. SSB and B44 did not use standard PM wakeup functions
> > and did not forward wakeup settings to their parents.
> > To fix that B44 driver enables PM wakeup and registers new wakeup source
> > using device_set_wakeup_enable(). Wakeup is automatically reported to t=
he parent SSB
> > bus via power.wakeup_path. SSB bus enables wakeup for the parent PCI br=
idge, if there is any
> > child devices with enabled wakeup functionality. All other steps are
> > done by PM core code.
>=20
> Thanks, this looks good.
> I assume you tested this (I currently don't have a device to test this).

Sure, I've tested it. WOL from suspend is working and after resume from hib=
ernate Ethernet is working too.

> Larry, Rafa=C5=82, any other b43 user:
> Can you please test whether this doesn't cause regressions for suspend/re=
sume on b43?
> (Patch is attached as reference)
>=20
>=20
> > Signed-off-by: Andrey Skvortsov <Andrej.Skvortzov@gmail.com>
> > ---
> >  drivers/net/ethernet/broadcom/b44.c |    2 ++
> >  drivers/ssb/pcihost_wrapper.c       |   33 ++++++++++++++++++++++-----=
------
> >  2 files changed, 24 insertions(+), 11 deletions(-)


--=20
Best regards,
Andrey Skvortsov

PGP Key ID: 0x57A3AEAD

--DocE+STaALJfprDB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBCgAGBQJUfhqZAAoJEAF8y6L1SLCtkkAP/icnHi9LdVrEGNQHoL31hF0a
mh8SKYT7bAE+B2FrklNLEIVnQi2nZqhDr8bbMp6ZRO22C4C5RdwcLRTxGKELID4v
JVOKpTlDaQN3BJqSmD5yWwW+Fn4bTOqhkcyFzYVe4EoGRq6Se2J7yqFdtcHoKFJ7
g3TPpAaXflyiViCWF9zlnoHXDjZpqVOqoyQVoEdv/57wa3emGKu6iBfSPyiePhRr
46ozDOHwAJ4GYa70vEv06I7ftLTgeRS342QZEgih965/Cde6v4nMtk+ySVVFuOuP
GrWm/C5FXViTIlRCABn/7SIM8Hclydklzu0R7RQpGjlkvx2syhtCPXRqJc6MmkR3
cCcnZcJ13XP6qvTQ/ZuWb3i+ZjN75TL/CIqckdF49Wjy6wcUVFSVBajEBHx/xWoA
+BR1iuSTEsv9lbrqO8IQ6/rU+rrgxDzRDhJfyZU62I66sAwJNW+K8lzgET3OBd/u
/p2GL3vNdLg2srw+zhIwuPM0yQdscHieN2FaEpt3PMXcO91rKuL/w3Hzaf8hWBF1
fYCNM0RhI/olYeASJvFUkzYAJkbbtwHH9+kmljOjJRFYqj24nkWiS3xJDDQHt4qi
rZDYvLXHnD19ExmwjY8oFipLRB2Sk0xhmKp+RsvJDas/D/j+wwrKNzpzklFAPdUe
dIemJlPfad33CZH3Mkb3
=ganE
-----END PGP SIGNATURE-----

--DocE+STaALJfprDB--
