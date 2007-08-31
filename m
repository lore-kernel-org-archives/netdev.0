From: Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>
Subject: Re: [0/7] [PPP]: Fix shared/cloned/non-linear skb bugs (was: malformed captured packets)
Date: Fri, 31 Aug 2007 16:02:31 +0200
Message-ID: <200708311602.34127.toralf.foerster@gmx.de>
References: <200708281811.34074.toralf.foerster@gmx.de> <46D69323.3070503@katalix.com> <20070831090625.GA28175@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2877896.UjbylRod7q";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:56932 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S965636AbXHaOCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 10:02:37 -0400
In-Reply-To: <20070831090625.GA28175@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2877896.UjbylRod7q
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Am Freitag, 31. August 2007 schrieb Herbert Xu:
> On Thu, Aug 30, 2007 at 09:51:31AM +0000, James Chapman wrote:
> >
> > The captured PPPoE stream seems to show incorrect data lengths in the
> > PPPoE header for some captured PPPoE packets. The kernel's PPPoE
> > datapath uses this length to extract the PPP frame and send it through
> > to the ppp interface. Since your ppp stream is fine, the actual PPPoE
> > header contents must be correct when it is parsed by the kernel PPPoE
> > code. It seems more likely that this is a wireshark bug to me.
>=20
> If he were using the kernel pppoe driver, then this is because
> PPP filtering is writing over a cloned skb without copying it.
>=20
> In fact, there seems to be quite a few bugs of this kind in
> the various ppp*.c files.
>=20
> Please try the following patches to see if they make a
> difference.
>=20
> I've audited ppp_generic.c and pppoe.c.  I'll do pppol2tp
> tomorrow.
>=20
> Cheers,


Herbert,

your patches - applied against 2.6.23-rc4-g2d8348b4 - works like a charm :-)

Among many other places at least
http://bugzilla.kernel.org/show_bug.cgi?id=3D8409
but probably also
http://bugzilla.kernel.org/show_bug.cgi?id=3D7938 are solved by your 7 patc=
hes.

Many thanks

=2D-=20
MfG/Sincerely

Toralf F=F6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--nextPart2877896.UjbylRod7q
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQBG2B94hyrlCH22naMRAk1UAJ4l0OUMQOt4BG/h7wfvwMUPsp1XHwCghWNr
9SL+B/D4XWbdj2WO8yuJGvk=
=F4h4
-----END PGP SIGNATURE-----

--nextPart2877896.UjbylRod7q--
