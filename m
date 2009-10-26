From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Adjust softirq raising in __napi_schedule
Date: Mon, 26 Oct 2009 09:56:20 +0100
Message-ID: <1256547380.28230.17.camel@johannes.local>
References: <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc>
	 <20091021211906.GA11401@ami.dom.local>
	 <1256160330.12174.2.camel@johannes.local>
	 <20091021213947.GA12202@ami.dom.local>
	 <1256200021.12174.11.camel@johannes.local> <4AE1C00B.5010008@imap.cc>
	 <1256309191.12174.51.camel@johannes.local>
	 <20091026074126.GA6187@ff.dom.local>
	 <1256543054.28230.6.camel@johannes.local>
	 <20091026075438.GB6187@ff.dom.local>
	 <1256543932.28230.9.camel@johannes.local>  <4AE56217.3040708@imap.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-/VsN2AN47iITS0fIBs+L"
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	Michael Buesch <mb@bu3sch.de>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4AE56217.3040708@imap.cc>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/VsN2AN47iITS0fIBs+L
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-10-26 at 10:47 +0200, Tilman Schmidt wrote:

> > However, I lost track now of why we're discussing this.
>=20
> The starting point were several reports of the kernel message:
>=20
> NOHZ: local_softirq_pending 08
>=20
> Originally most if not all of them came from wireless networking,
> but I muddied the waters by adding to the mix a case involving ISDN.
> You stated that all the solutions proposed so far were wrong, so
> we're naturally turning to you for guidance on what the right
> solution might be.

Right. Sorry about getting lost here.

> > Basically it boils down to using netif_rx() when in (soft)irq, and
> > netif_rx_ni() when in process context. That could just be an
> > optimisation, but it's a very valid one.
>=20
> Hmmm. That seems to contradict your earlier statement to me that
> simply replacing a call to netif_rx() by one to netif_rx_ni()
> when not in interrupt context isn't a valid solution either.
> What am I missing?

Well, I think you misunderstood me. It would be correct to do this, if
and only if the code that calls it doesn't need the extra guarantee.

Any code (say ISDN code) that calls netif_rx() is clearly assuming to
always be running in (soft)irq context, otherwise it couldn't call
netif_rx() unconditionally. Agree so far?

So now if you change the ISDN code to call netif_rx_ni(), you've changed
the assumption that the ISDN code makes -- that it is running in
(soft)irq context. Therefore, you need to verify that this is actually a
correct change, which is what I tried to say.

johannes

--=-/VsN2AN47iITS0fIBs+L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK5WQuAAoJEODzc/N7+QmaPSoP/2W5G6OYt+XcIoue2db+SlYa
p/rw3j/+vXytXFGWslMtY6Dyg6K+YeN+BauUsFCXr/LxUprKJLH3bE1jaer2PrzP
R2E4bLdFMVgxngmMNQ0PMUCAX8YEUNZUd9cGua6X5MyZ08smfvhvNFnoOcbQVbB7
6f05PI1ULPACZJNZlav8cQpwHxp9cU89DQEkJiB9+hJsPBks3eRM48HIsuV5YHix
yQ3iqMzg5/8vgKK6wCOHR6os52dcYjnaVDrjQwOHI2/5KG1B0taj+tn+sJjYTP7L
ED2hB6yfyE3szig58estEMeNXsKp98wZRfsSA6rB61A2uf66e99RpmOVPegon6Dp
MR+uA7wz3aHgAAcXQ3E9M2mP4MXf9WmnRxr3Q+XTsaVvHUvLk/rFvrlOHpFht4o0
fOcRPTgg5RSpVs6aXZxLJMwAWfCFBb0+MiEhqTQYNO7T+OMtWUF3PQP65Ie1HssV
DYQkqaAUwjTilhmZX1x80eXPN4xZeJUdi0uFIgKyvefajb/13Gs93OlTCyYmwlfM
oXhoXgK3HwIbscbWEvOEtbaln6aGuMdaLHOoGX8kRliTIVw2MbHUtIlWIVKENb/0
9io7gIPOsmD0ItGVLIaa4PNF8fHAJo8oEKXT6YG7pj1cJRa7YYtjOUZmK/R+Zltx
KH35ftsf+CIV8Niafj5G
=SbI/
-----END PGP SIGNATURE-----

--=-/VsN2AN47iITS0fIBs+L--

