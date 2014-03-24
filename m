From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 15/16] igb: Fix Null-pointer dereference in
 igb_reset_q_vector
Date: Mon, 24 Mar 2014 13:49:30 -0700
Message-ID: <1395694170.2899.15.camel@jtkirshe-mobl.jf.intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <0082c389c1d6488cb5cf473ff1bc26e2@UCL-MBX03.OASIS.UCLOUVAIN.BE>
	 <20140323143125.GC5028@cpaasch-mac>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zfmYoBDH+wWf1rWN4Hio"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38430 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754065AbaCXUte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2014 16:49:34 -0400
In-Reply-To: <20140323143125.GC5028@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zfmYoBDH+wWf1rWN4Hio
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-03-23 at 15:31 +0100, Christoph Paasch wrote:
> On 21/03/14 - 12:10:05, Jeff Kirsher wrote:
> > From: Christoph Paasch <christoph.paasch@uclouvain.be>
> >=20
> > When igb_set_interrupt_capability() calls
> > igb_reset_interrupt_capability() (e.g., because CONFIG_PCI_MSI is
> unset),
> > num_q_vectors has been set but no vector has yet been allocated.
> >=20
> > igb_reset_interrupt_capability() will then call igb_reset_q_vector,
> > which assumes that the vector is allocated. As this is not the case,
> we
> > are accessing a NULL-pointer.
> >=20
> > This patch fixes it by checking that q_vector is indeed different
> from
> > NULL.
> >=20
> > Fixes: 02ef6e1d0b0023 (igb: Fix queue allocation method to
> accommodate changing during runtime)
> > Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> > Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> > Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> Hello Jeff,
>=20
> shouldn't this one rather be for 'net' instead of 'net-next'? Because
> 02ef6e1d0b0023 is part of 3.14-rc1.

Yes, but being that it is late in the -rcX cycle and 3.14 is expected to
be released anytime now, it was not prudent to try and push this in
right before the window closes.  It is better to have -stable pick this
up once Linus releases 3.14.  Same goes for your other patch.

So once Linus releases 3.14 and Linus merges in Dave's net-next tree for
3.15, I will notify the stable maintainers that your 2 patches need to
be picked up for 3.14.x stable trees.

--=-zfmYoBDH+wWf1rWN4Hio
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTMJpaAAoJEOVv75VaS+3OzWgP/it37weIqbk9yxB1C6fuBeis
+lUNdjR/qQN3rB+HEd7nVupZlbc5pZWnY2X2mUn1z0MEPUTJaNnaE4UReXj0gCIM
EsJfrLZCt+qqprLd3ImE5O/hSlKRZhBwzklOZ5eU+fG5xY+xw/idHYb1qvmaRPHj
g+wdDLNkbE3+hiEGM/ulhp2kFJ9ImG5M+74kB/N8GjQUXFXMgOhmQji1bIgkSGFm
mp+Qzkj+/s7QLPsWielV30ZvtvT9QKbQsQPAJiFtW9Ywnz9NKG6BEwn0SBHShz9M
41eM4rJLZ5tklyLNM26VEqL3v09zlpmYpFWz7SqecxrS2Gaa4uWu2q61pkMrb+Ql
TAGwht5TAtjVIe6lo/LyE/ACdIbpKsbbaqvLA39ASuoBE6gIYjLWA7iY/pkolony
vMCig2ScdZIuza3oiWXQeCBZs5U7fUCco9JNaqDw7MUpr/uStyyfCxQaqbVMiCr8
qAaq8prsyQZwA6/f7ZUZYBMkeKQ8PdX2Y21IWRrYARiGRoYKBhu39qH+iSY6H19o
HmSLly6FhbRBXXgsTe6Y6i93fTuveWWuqT2cD5gcBpU3L01h0tGGpGIx0cbBa0wW
E/egNFM/msAOyTsv3bkrYTm0poC7JVqp3r2FT2F6e+FdDcLQbBYTfJa+KjTbo4cV
Zi0HGNgHNa7It+AbpXSE
=6aJS
-----END PGP SIGNATURE-----

--=-zfmYoBDH+wWf1rWN4Hio--
