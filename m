From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: Cleanup handling of VLAN_HLEN as a part of max
 frame size
Date: Wed, 08 Apr 2015 17:01:36 -0700
Message-ID: <1428537696.2729.4.camel@jtkirshe-mobl>
References: <alpine.NEB.2.11.1504081019220.3388@chris.i8u.org>
	 <20150408204630.4643.37880.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-fdvbd6Ig+XS0Fb9QuG0h"
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	mike@cchtml.com, htodd@twofifty.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Aaron Brown <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:61807 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754738AbbDIABh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 20:01:37 -0400
In-Reply-To: <20150408204630.4643.37880.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-fdvbd6Ig+XS0Fb9QuG0h
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-08 at 14:02 -0700, Alexander Duyck wrote:
> When the VLAN_HLEN was added to the calculation for the maximum frame
> size
> there seems to have been a number of issues added to the driver.
>=20
> The first issue is that in some cases the maximum frame size for a
> device
> never really reached the actual maximum frame size as the VLAN header
> length was not included the calculation for that value.  As a result
> some
> parts only supported a maximum frame size of either 1496 in the case
> of
> parts that didn't support jumbo frames, and 8996 in the case of the
> parts
> that do.
>=20
> The second issue is the fact that there were several checks that
> weren't
> updated so as a result setting an MTU of 1500 was treated as enabling
> jumbo
> frames as the calculated value was 1522 instead of 1518.  I have
> addressed
> those by replacing ETH_FRAME_LEN with VLAN_ETH_FRAME_LEN where
> appropriate.
>=20
> The final issue was the fact that lowering the MTU below 1500 would
> cause
> the driver to allocate 2K buffers for the rings.  This is an old issue
> that
> was fixed several years ago in igb/ixgbe and I am addressing now by
> just
> replacing =3D=3D with a <=3D so that we always just round up to 1522 for
> anything
> that isn't a jumbo frame.
>=20
> Fixes: c751a3d58cf2d ("e1000e: Correctly include VLAN_HLEN when
> changing interface MTU")
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>=20
> I have only build tested this though I am 99% sure the fixes here are
> correct.  This patch should fix issues on 82573 and ich8 w/ setting an
> MTU
> of 1500, and for the PCH series w/ setting an MTU of 9000.
>=20
> I assume I can get away with bumping the max_hw_frame_size for the PCH
> parts from 9018 to 9022 based on the fact that the Windows INF for the
> parts
> lists supporting either 1514, 4088, and 9014 all of which exclude the
> 8
> bytes for CRC and VLAN header.
>=20
>  drivers/net/ethernet/intel/e1000e/82571.c   |    2 +-
>  drivers/net/ethernet/intel/e1000e/ich8lan.c |   10 +++++-----
>  drivers/net/ethernet/intel/e1000e/netdev.c  |   18 ++++++++----------
>  3 files changed, 14 insertions(+), 16 deletions(-)

I have applied your patch to my queue, thanks Alex.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-fdvbd6Ig+XS0Fb9QuG0h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJcFgAAoJEOVv75VaS+3OwuUP/RbmZijLABlqvI+f8QMzibFs
9RgcfWwTV+C4HInCfaR8FrhqlWd5LAhA7ZeJsdURaLWsnfynH9cCRQtwds0DKaXi
veZ2wrYxmwBk+xOEgKYMbL7Sd9R8MmupO4jJW8W01qwz9bw5pSn+gQ3bet6SOB4q
1fpAVoMYWqQ5Z+39BR5QtEMff0mM8ffpJ+EERT05YmvTYfI9XWVgZiUwd6LOTLx8
5rtqM89wHPtlMbLcbqGFqM8FjE+inFJzYi1L6o+vbNe/653Trh+1WwDhsP5CUWp0
qcshFuAh7XALCkgXQ6EMl587S+qYpzMzSJJhwyWy7lPGjJxqxNsgRlTkvzx4+ggX
fiy93lbnxYEnONrBA9r6vUdqk/LvYui5murlmQokXXToNGPFUdblQ2Iixk9qZ4KT
CYJZTyznU+Siyc4QTcbxn+wzKUPxAWZj9Ci8qdPJHx24klj1Bt+5xpvDM0jrW9sw
GthWj34rIWYLk+ZBpITgdmvy24xzJSUYrJS6HS67bK6qSXG8HVEI85oF5PvYUzr3
uu038zDBUbtDJYrCR2rBCkCJ6AaZZxytN/fsA7zK3F/8pDhCmqYD32u0q1yLEDmS
G1hE69NV37MTvhJRWIXbmHRS+VAJP8pPaCH7PH3KUvVUQbI414tcHY+D/GTr1lUN
BWfrB1St8H/dU3rw9Q5n
=l89j
-----END PGP SIGNATURE-----

--=-fdvbd6Ig+XS0Fb9QuG0h--
