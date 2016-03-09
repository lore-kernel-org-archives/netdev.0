From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH] csum: Update csum_block_add to use rotate
 instead of byteswap
Date: Wed, 9 Mar 2016 10:54:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D4111BB63@AcuExch.aculab.com>
References: <20160308224238.16551.73881.stgit@localhost.localdomain>
 <1457479557.4067.9.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: 'Joe Perches' <joe@perches.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:61800 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348AbcCIK6U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 05:58:20 -0500
In-Reply-To: <1457479557.4067.9.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Joe Perches
> Sent: 08 March 2016 23:26
=2E..
> > +
> > +	if (offset & 1)
> > +		sum =3D (sum << 24) + (sum >> 8);
>=20
> Maybe use ror32(sum, 8);
>=20
> or maybe something like:
>=20
> {
> 	u32 sum;
>=20
> 	/*=A0rotated csum2 of odd offset will be the right checksum */
> 	if (offset & 1)
> 		sum =3D ror32((__force u32)csum2, 8);
> 	else
> 		sum =3D (__force u32)csum2;

Or even:
	sum =3D ror32((__force u32)csum2, (offset & 1) * 8);
to remove the conditional.
Assuming 'rotate by 0 bits' is valid.
If not add 16 to rotate by 16 or 24.

	David
