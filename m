From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [patch] ser_gigaset: return -ENOMEM on error instead of success
Date: Wed, 7 Dec 2016 23:04:30 +0100
Message-ID: <59908d9c-1716-14cb-41aa-8a9538f53412@imap.cc>
References: <20161207112203.GC5507@elgon.mountain>
 <1481137583.12596.19.camel@tiscali.nl>
 <d8eb1f69-e68e-7792-00de-b14e6bac1606@imap.cc>
 <1481144894.11167.7.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="XGDJSa2LJXSNspGKSW2uLR5jr8kTmUgRn"
Cc: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>,
        Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1481144894.11167.7.camel@tiscali.nl>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XGDJSa2LJXSNspGKSW2uLR5jr8kTmUgRn
Content-Type: multipart/mixed; boundary="PX55QOEmaqoiDBX9EIwKeW5TxFRqXtTl1";
 protected-headers="v1"
From: Tilman Schmidt <tilman@imap.cc>
To: Paul Bolle <pebolle@tiscali.nl>, Dan Carpenter <dan.carpenter@oracle.com>
Cc: Karsten Keil <isdn@linux-pingi.de>, "David S. Miller"
 <davem@davemloft.net>, gigaset307x-common@lists.sourceforge.net,
 netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Message-ID: <59908d9c-1716-14cb-41aa-8a9538f53412@imap.cc>
Subject: Re: [patch] ser_gigaset: return -ENOMEM on error instead of success
References: <20161207112203.GC5507@elgon.mountain>
 <1481137583.12596.19.camel@tiscali.nl>
 <d8eb1f69-e68e-7792-00de-b14e6bac1606@imap.cc>
 <1481144894.11167.7.camel@tiscali.nl>
In-Reply-To: <1481144894.11167.7.camel@tiscali.nl>

--PX55QOEmaqoiDBX9EIwKeW5TxFRqXtTl1
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Paul,

Am 07.12.2016 um 22:08 schrieb Paul Bolle:
> On Wed, 2016-12-07 at 21:57 +0100, Tilman Schmidt wrote:
>> Not much of a mess, I reckon. Everything that has been allocated and
>> registered up to that point is properly deallocated and unregistered.
>> The code just fails to tell the kernel that module initialization has
>> failed, so the module remains loaded even though it can never be
>> called because it isn't hooked anywhere. That's a nuisance and a
>> waste of RAM, but not much more.
>=20
> Yes.
>=20
> But then the removal of the module, which is the only reasonable thing =
to do
> after all this has happened, seems to trigger a WARN in driver_unregist=
er().
> And it's that WARN that I think requires the entire stable song and dan=
ce.

Ah, yes, of course, because driver_unregister() has already been run
in the failure path of module_init and is now called a second time.
Not sure how much evil that does beyond the WARN, but I agree it's
worth investigating.

Best regards,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--PX55QOEmaqoiDBX9EIwKeW5TxFRqXtTl1--

--XGDJSa2LJXSNspGKSW2uLR5jr8kTmUgRn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJYSId5AAoJEFPuqx0v+F+q0CwH/2tvh8jO2TuvAZqrZXaJad6+
UEJskOnl03NaiOIAytsNxqUQciUpbQYrnBzSqlweXb91Ef33Pe4jYud47DpeMF78
UO6hmHFQAF80gZSKQ/jpI653fcSIgk3sNbCh3oCrGmYyutGtz1BgyxFFtjEwJdfa
6IQE3eBuGTVBsmoqnWD3wR3iz1mybZ+rPf5vFRO3sa5s+5l5RpIgjHfPd2gx2B0R
IFbu0Xx1TcgI3xUNGBbtHaRzRrgrmgBFkn8QOArzfUod33aADyRaRFDLxR7wHWLI
9pN2xDHNtiMcw3vUvR1YbpmpmaeDQHCBOHAhh/lIxAz7lYtU1u4k/U5J1PUVduc=
=kFcR
-----END PGP SIGNATURE-----

--XGDJSa2LJXSNspGKSW2uLR5jr8kTmUgRn--
