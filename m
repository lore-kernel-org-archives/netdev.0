From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/2] net: ethernet: stmmac: remove private tx queue lock
Date: Thu, 8 Dec 2016 00:21:41 +0100
Message-ID: <20161207232141.GD2250@amd>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-3-git-send-email-LinoSanfilippo@gmx.de>
 <20161207213757.GC2250@amd>
 <cc10a750-b8ef-a600-4cd5-5b51904c5253@gmx.de>
 <afcae723-5804-305f-2756-c4dbf9045943@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="F8dlzb82+Fcn6AgP"
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <afcae723-5804-305f-2756-c4dbf9045943@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--F8dlzb82+Fcn6AgP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed 2016-12-07 23:34:19, Lino Sanfilippo wrote:
> On 07.12.2016 22:43, Lino Sanfilippo wrote:
> > Hi Pavel,
> >=20
> > On 07.12.2016 22:37, Pavel Machek wrote:
> >> On Wed 2016-12-07 21:05:38, Lino Sanfilippo wrote:
> >>> The driver uses a private lock for synchronization between the xmit
> >>> function and the xmit completion handler, but since the NETIF_F_LLTX =
flag
> >>> is not set, the xmit function is also called with the xmit_lock held.
> >>>=20
> >>> On the other hand the xmit completion handler first takes the private=
 lock
> >>> and (in case that the tx queue has been stopped) the xmit_lock, leadi=
ng to
> >>> a reverse locking order and the potential danger of a deadlock.
> >>>=20
> >>> Fix this by removing the private lock completely and synchronizing th=
e xmit
> >>> function and completion handler solely by means of the xmit_lock. By =
doing
> >>> this remove also the now unnecessary double check for a stopped tx qu=
eue.
> >>>=20
> >>=20
> >> FYI, here's modified version. I believe _bh versions are needed, and
> >> I'm testing that version now. (Oh and I also ported it to net-next).
> >>=20
> >> It survived 30 minutes of testing so far...
> >>=20
> >=20
> > First off, thanks for testing.
> > Hmm. I dont understand why _bh would be needed. We call that function f=
rom
> > BH context only (napi poll and timer).
> > Any idea?
> >=20
>=20
> Could this once again be caused by irq coalescing? When the tx queue has =
been stopped
> the cleanup handler has to wakeup the queue within a certain time span, o=
therwise the
> watchdog will complain (as it happened in your test). Could you retest th=
is with
> irq coalescing disabled?

I actually had TX coalescing disabled, with

-#define STMMAC_TX_FRAMES       64
+#define STMMAC_TX_FRAMES       0


										Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--F8dlzb82+Fcn6AgP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhImYUACgkQMOfwapXb+vJIUQCdFGIHvl7yaUOneIX7htLjqvxZ
wccAoMJ4uT7qL42dzLfuNEXAj8AgaVVq
=z8aF
-----END PGP SIGNATURE-----

--F8dlzb82+Fcn6AgP--
