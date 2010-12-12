From: Pierre Ossman <pierre-list@ossman.eu>
Subject: Re: [RFC][PATCH] Export DNSSL RA option to userspace
Date: Sun, 12 Dec 2010 15:07:01 +0100
Message-ID: <20101212150701.20d4fd6d@mjolnir.ossman.eu>
References: <20101212144300.68e0fb16@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-23874-1292162823-0001-2"
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-117-125-11.tcdsl.calypso.net ([82.117.125.11]:34607 "EHLO
	smtp.ossman.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076Ab0LLOHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 09:07:06 -0500
In-Reply-To: <20101212144300.68e0fb16@mjolnir.ossman.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-23874-1292162823-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

I've also noticed a problem in the nduseropt code that I'm not sure how
to solve (given that this is now a stable userspace interface). Both
RFC5006 and RFC6106 state the following:

   Note:  An RDNSS address or a DNSSL domain name MUST be used only as
      long as both the RA router Lifetime (advertised by a Router
      Advertisement message [RFC4861]) and the corresponding option
      Lifetime have not expired.

But the RA router lifetime is not included in the information sent.
Normally this is probably not an issue as the RDNSS and DNSSL lifetime
will be shorter than the router lifetime. One exception is when the
router is disabled at which point it will send a RA with router
lifetime to 0 (RFC4861 section 6.2.5). That means userspace will not be
informed that the DNS information should be removed immediately*.

Is there any way we can safely extend the interface with this
information? I'm not familiar enough with it myself yet to determine if
it's possible...

* Unless the router has a workaround for this client bug and also sets
  RDNSS and DNSSL lifetimes to 0 as part of the final message.

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by FRA, a
  Swedish intelligence agency. Make sure your server uses
  encryption for SMTP traffic and consider using PGP for
  end-to-end encryption.

--=_freyr.ossman.eu-23874-1292162823-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iF4EAREIAAYFAk0E1wcACgkQopDLsoqlmEKoSgEAy3+iaP2VsVTAHCHIqdHvljBH
paj0bDIzqsS2egXNRXUBAKtIIfLQFeX4JQnkNWsqXTuG4j1lLiOvOeP09Qyx2dJF
=mILL
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-23874-1292162823-0001-2--
