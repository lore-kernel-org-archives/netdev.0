From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next 2012-07-11
Date: Thu, 12 Jul 2012 00:13:09 +0100
Message-ID: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-q+hWtQGNCmEiO1Vu8Xhp"
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34114 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758437Ab2GKXNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 19:13:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-q+hWtQGNCmEiO1Vu8Xhp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit c56bf6fe785abbd83751a462f0c7067f7145b97a=
:

  ipv6: fix a bad cast in ip6_dst_lookup_tail() (2012-07-06 00:23:41 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit 9a46fccdd28f9939c10f81748e1430afbb95138d)

1. 128-bit MMIO writes for TX push, by Stuart Hodgson.  We previously
   tried to do this with write-combining, but that turned out to be
   unsafe.  Now we use SSE (on x86_64 only).
2. Fix potential badness when running a self-test with SR-IOV enabled.
3. Fix calculation of some interface statistics that could run backward.
4. Miscellaneous cleanup.

Ben.

Ben Hutchings (10):
      sfc: Work around bogus 'uninitialised variable' warning
      sfc: Use generic DMA API, not PCI-DMA API
      sfc: Remove dead write to tso_state::packet_space
      sfc: Stop changing header offsets on TX
      sfc: Use strlcpy() to copy ethtool stats names
      sfc: Use dev_kfree_skb() in efx_end_loopback()
      sfc: Explain why efx_mcdi_exit_assertion() ignores result of efx_mcdi=
_rpc()
      sfc: Disable VF queues during register self-test
      sfc: Fix interface statistics running backward
      sfc: Correct some comments on enum reset_type

Stuart Hodgson (1):
      sfc: Implement 128-bit writes for efx_writeo_page

 drivers/net/ethernet/sfc/bitfield.h    |    5 ++
 drivers/net/ethernet/sfc/efx.c         |   10 ++--
 drivers/net/ethernet/sfc/enum.h        |    8 ++--
 drivers/net/ethernet/sfc/ethtool.c     |    2 +-
 drivers/net/ethernet/sfc/falcon.c      |   35 +++++++++++--
 drivers/net/ethernet/sfc/falcon_xmac.c |   12 ++--
 drivers/net/ethernet/sfc/filter.c      |    2 +-
 drivers/net/ethernet/sfc/io.h          |   51 +++++++++++++++++
 drivers/net/ethernet/sfc/mcdi.c        |   11 +++-
 drivers/net/ethernet/sfc/net_driver.h  |    9 ++-
 drivers/net/ethernet/sfc/nic.c         |   11 ++---
 drivers/net/ethernet/sfc/nic.h         |   18 ++++++
 drivers/net/ethernet/sfc/rx.c          |   22 ++++----
 drivers/net/ethernet/sfc/selftest.c    |   64 ++++++----------------
 drivers/net/ethernet/sfc/siena.c       |   37 ++++++++++---
 drivers/net/ethernet/sfc/tx.c          |   93 ++++++++++++++--------------=
----
 16 files changed, 237 insertions(+), 153 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


--=-q+hWtQGNCmEiO1Vu8Xhp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJP/giFAAoJEGkILBsOca60bVIH/0+4MNYlyQZoJHUxIFMibmqy
a0seOe8n9Xs8wiURH95ioArDZISxQme1pMrzva/75of6s/2o1zjbTriY8Ju0/s1V
yUwKVfBS3TiVe+JlhNVZDqniYqHEtYpSnnYiloGaLPEMqBG5KQx71a6i+qsMoXJa
xFMmpCN1i4OHvRTo8HCBmHzRWsS2msnjJmVaj4EMTb7fD9DahKF5seolY+eFXVc8
YQz7EayAVE0goJqwiKqDkRm+Tawt/kWDP2w3dsZ98tNJCAq9LdDqKOfipo9SaAK5
SCqq1wweqAYX8ohwZy7RUJDWVONBONhAhF7dKFJjT83qrNH50L1/eALHmGL+PiA=
=M2gu
-----END PGP SIGNATURE-----

--=-q+hWtQGNCmEiO1Vu8Xhp--
