From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: DM9000 issue with mem resource management
Date: Thu, 5 Jun 2008 17:42:58 +0200
Message-ID: <200806051743.00614.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart151589832.5msRuPoDZE";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:59907 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752391AbYFEPnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 11:43:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart151589832.5msRuPoDZE
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi everybody,

I ran into a resource-related bug in the DM9000 driver.

When the platform device has only 2 resources, dm9000_probe() doesn't set=20
db->irq_res, which results in a segfault when the pointer gets dereferenced=
=20
in dm9000_open().

I tried to fix the issue, and found out that the resource management code i=
s=20
quite broken.

If I understand things correctly, specifying 3 resources makes the DM9000=20
driver ioremap() the memory, while specifying 2 resources implies that the=
=20
platform code already ioremap()ed the memory. Is that right ?

If so, why does dm9000_probe() call request_mem_region() on ioremap()ed=20
memory ?

Wouldn't it also be simpler to use release_mem_region() in=20
dm9000_release_board() instead of release_resource() + kfree() ?

I'd be grateful if someone could confirm my assumptions. I'll then submit a=
=20
patch to fix those issues.

Best regards,

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart151589832.5msRuPoDZE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBISAmE8y9gWxC9vpcRAu6VAJ0UVedUkDvwa0VF/8RMfrizm4yX5ACgnWrv
umLf6Vz4u/7Ni+XBy2fy0Tw=
=joMe
-----END PGP SIGNATURE-----

--nextPart151589832.5msRuPoDZE--
