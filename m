From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [PATCH][RESEND] Fix checksum related BUG in l2tp_ppp receive path
Date: Wed, 29 May 2013 17:49:24 +0100
Message-ID: <20130529164924.GA3179@raven>
References: <1369724604.7764.1.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9amGYk9869ThD9tj"
Cc: jchapman@katalix.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jana Saout <jana@saout.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:40951 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757827Ab3E2Qt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 12:49:27 -0400
Content-Disposition: inline
In-Reply-To: <1369724604.7764.1.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jana,

Thanks for the patch, and sorry for missing it the first time around!

On Tue, May 28, 2013 at 09:03:24AM +0200, Jana Saout wrote:
> Interestingly, the PPP over L2TP (with xl2tpd) is working fine when
> using my Linux client, but a simple ping from my Android phone causes
> the BUG on the first packet.  It happens on the L2TP -> PPP path, as the
> ping request never leaves the ppp devices to the local network.
>=20
> What *might* be different from other setups, is that the machine on
> which the L2TP packets are decapsulated is a Xen VM, so the packets
> arrive with CHECKSUM_PARTIAL set.

Could you advise what Android client you're using?  I'd like to
attempt to reproduce this here.  We do a lot of L2TP testing in VM
environments (albeit not Xen), so I'm interested as to why we've not
hit this.

> I believe that since the L2TP checksum has already been checked and
> everything, the decapsulated packet is supposedly "fine" and I also saw
> the following line in l2tp_eth.c:
>=20
>         /* checksums verified by L2TP */
>         skb->ip_summed =3D CHECKSUM_NONE;
>=20
> which sounds to mike like the right thing to do, so I modified
> l2tp_ppp.c accordingly and voila - no more crashes.  In case it helps, I
> would like to share that patch for inclusion or, in case I'm wrong, to
> ask you to find the correct fix. :)

I think your analysis is correct, but I'm not sure whether setting
skb->ip_summed to CHECKSUM_NONE is the right thing to do.  It seems
like this would disable checksumming for the ICMP echo response.
Although that may avoid the BUG, it may not be entirely ideal
behaviour.

I'll have a dig into the other tunnelling protocol implementation and
see what they do.
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--9amGYk9869ThD9tj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRpjGUAAoJEJSMBmUKuovQ8xIIAJPRA1fWUDmsp0yzMQB2/4Kt
jB8PXilvU+J3Wv+Q5NKyW+fExd008wD9aUlI8DhpNNCb5ML1kJIoqQYgfHSIJfYp
Iw3Zl8JFvBUmrH3I+w4/8JynJIrdejGLI5mbgFIRHdLVXOKfStcpLyoDac1tI78t
g08fcaN/jJkA6kiwvIn2410ZBplIkKNyAO5sZlmKXL570rYBpZl7MXsqJRYM4+jc
hkudXpQV7ro/hjP8chMluB87la+is7QpeekNjJhKejdr4R6YFafSroe29nHQ9x4J
IFRDRi1IUhTXRX3qz7Pe6gT65sCxbtclPomGSBuxcHBBztWchtiRQJjI8LKPQdM=
=DI4+
-----END PGP SIGNATURE-----

--9amGYk9869ThD9tj--
