From: Tom Parkin <tparkin@katalix.com>
Subject: Supporting more devices with dev_alloc_name()
Date: Thu, 25 Oct 2012 17:56:32 +0100
Message-ID: <20121025165632.GC7857@raven>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LwW0XdcUbUexiWVK"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:34768 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757202Ab2JYRFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 13:05:43 -0400
Received: from localhost (cpc28-brad20-2-0-cust174.17-1.cable.virginmedia.com [77.97.157.175])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: tom)
	by mail.katalix.com (Postfix) with ESMTPSA id DFACDA6207F
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 17:56:33 +0100 (BST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LwW0XdcUbUexiWVK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi list,

I've recently been trying to create large-scale L2TPv3 configurations
of up to 50,000 Ethernet pseudowires.

One of the limitations I've hit has been to do with dev_alloc_name().
By default, l2tp_eth uses "l2tpeth%d" for device names, which is
expanded by dev_alloc_name() into l2tpeth1, l2tpeth2, etc.  However,
the algorithm dev_alloc_name() uses to derive the next free number for
this scheme is bounded by the number of bits in a single page.  For
kernels/platforms with a 4kB page, this limits these "autoderived"
names to 32k.

In my testing I've been able to work around this by specifying
interface names during the bringup of the l2tpeth interfaces, thereby
bypassing dev_alloc_name() altogether.  Using this approach I am able
to comfortably create 50k interfaces, even on fairly modest hardware.
But it seems a shame to have to do this; it would be much nicer if
the kernel were able to autogenerate names for more devices.

Is this something that would be worth my working on a patch for, or
would the increased code complexity be too great an overhead to
consider for such outlandish use-cases?

Thanks,
Tom
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--LwW0XdcUbUexiWVK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJQiW9AAAoJEJSMBmUKuovQlOkH/2ZdA0Rfwj/gWGXJ2M0HLV6I
GSwmqTjlDKX4/7dAEE+EQK23KSRmMYZtY9aJc9Zvjxq6jC05KRyBZCUkQ8FCu6TL
egwadlfim57y1maNS10woMpdjOLOMO1gP1xUtkaEof3YICOpjKHnV05wi+JNlmP5
8whkvaQY6bhEeUH+cUtkLsHEMaibyGlWcy7VQv20j1DQO8kaIxhZ+XXzk74ld+Xp
N3HI/pzWSCGXw9GoBvhdWJg/cfAm4J+PxIZeQiey4irsfcKtoGwS+sWSZDosuDYl
FJFiMX9Jd7I+8oCPP/BEDbbE2Js58ZJC4IB7GdzefRKDUmUC0zpX061TUp2oDaU=
=7Gwy
-----END PGP SIGNATURE-----

--LwW0XdcUbUexiWVK--
