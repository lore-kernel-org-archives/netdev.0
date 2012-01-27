From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next 2012-01-27
Date: Fri, 27 Jan 2012 20:40:58 +0000
Message-ID: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-tUYO+L8JifUv5PSutHt0"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63425 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751253Ab2A0UlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:41:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-tUYO+L8JifUv5PSutHt0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 9b28ecd66b391349d3492574500f978566195454=
:

  net: usb: qmi_wwan: New driver for Huawei QMI based WWAN devices (2012-01=
-25 16:59:47 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit db3395697cad6e9dff8d21249e0b59dc9bb83b48)

This is a mixture of cleanup, minor bug fixes, and a few features:

- Increase default number of queues to 1 per core
- Add hardware monitor driver for Siena

Ben.

Ben Hutchings (31):
      sfc: Fix some formatting errors reported by checkpatch
      sfc: Avoid assignment in an if-statement, reported by checkpatch
      sfc: Remove parentheses around return expressions, reported by checkp=
atch
      sfc: Const-qualify static data as appropriate, partly prompted by che=
ckpatch
      sfc: Remove unnecessary inclusion of <asm/io.h>, prompted by checkpat=
ch
      sfc: Update MCDI (firmware interface) definitions
      sfc: Rename efx_wanted_channels() to efx_wanted_parallelism()
      sfc: Set default parallelism to per-core by default
      sfc: Remove fallback for invalid permanent MAC address
      sfc: Make handling of MC reboot more reliable
      sfc: Use new names for MC shared memory layout constants
      sfc: Hold efx_nic::stats_lock while reading efx_nic::mac_stats
      sfc: Merge efx_mac_operations into efx_nic_type
      sfc: Merge efx_mcdi_mac_check_fault() and efx_mcdi_get_mac_faults()
      sfc: Remove efx_nic_type::push_multicast_hash operation
      sfc: Consistently test DEBUG macro, not EFX_ENABLE_DEBUG
      sfc: Correct interrupt timer quantum for Siena (normal and turbo mode=
)
      sfc: Remove dependence on NAPI polling in efx_test_eventq_irq()
      Partly revert "sfc: Handle serious errors in exactly one interrupt ha=
ndler"
      sfc: Clean up test interrupt handling
      sfc: Add hwmon driver for boards using SFC9000-family controllers
      sfc: Update the description of SFC_MTD
      sfc: Remove obsolete function efx_dev_name()
      sfc: Remove remnants of on-load self-test
      sfc: Use existing local variables instead of repeated indirect lookup=
s
      sfc: Minor formatting fixes
      sfc: Remove redundant 'rc' variable, always set to 0
      sfc: Rename implementation of ndo_set_rx_mode
      sfc: Make all MAC statistics consistently 64 bits wide
      sfc: Move the end of the non-GRO RX path into its own function
      sfc: Replace efx_rx_buffer::is_page and other booleans with a flags f=
ield

Matthew Slattery (1):
      sfc: Support extraction of CAPABILITIES from GET_BOARD_CFG response.

 drivers/net/ethernet/sfc/Kconfig         |   13 +-
 drivers/net/ethernet/sfc/Makefile        |    2 +-
 drivers/net/ethernet/sfc/bitfield.h      |   18 +-
 drivers/net/ethernet/sfc/efx.c           |  198 +-
 drivers/net/ethernet/sfc/efx.h           |   10 +-
 drivers/net/ethernet/sfc/ethtool.c       |  138 +-
 drivers/net/ethernet/sfc/falcon.c        |   42 +-
 drivers/net/ethernet/sfc/falcon_boards.c |   12 +-
 drivers/net/ethernet/sfc/falcon_xmac.c   |   15 +-
 drivers/net/ethernet/sfc/mac.h           |   21 -
 drivers/net/ethernet/sfc/mcdi.c          |  115 +-
 drivers/net/ethernet/sfc/mcdi.h          |   34 +-
 drivers/net/ethernet/sfc/mcdi_mac.c      |   61 +-
 drivers/net/ethernet/sfc/mcdi_mon.c      |  415 ++++
 drivers/net/ethernet/sfc/mcdi_pcol.h     | 3542 ++++++++++++++++++--------=
----
 drivers/net/ethernet/sfc/mcdi_phy.c      |   36 +-
 drivers/net/ethernet/sfc/mdio_10g.c      |    2 +-
 drivers/net/ethernet/sfc/mtd.c           |   14 +-
 drivers/net/ethernet/sfc/net_driver.h    |  189 +-
 drivers/net/ethernet/sfc/nic.c           |   69 +-
 drivers/net/ethernet/sfc/nic.h           |   20 +-
 drivers/net/ethernet/sfc/qt202x_phy.c    |    6 +-
 drivers/net/ethernet/sfc/rx.c            |  119 +-
 drivers/net/ethernet/sfc/selftest.c      |  110 +-
 drivers/net/ethernet/sfc/selftest.h      |    1 -
 drivers/net/ethernet/sfc/siena.c         |   33 +-
 drivers/net/ethernet/sfc/spi.h           |    2 +-
 drivers/net/ethernet/sfc/tenxpress.c     |    2 +-
 drivers/net/ethernet/sfc/tx.c            |    4 +-
 drivers/net/ethernet/sfc/txc43128_phy.c  |    2 +-
 30 files changed, 3108 insertions(+), 2137 deletions(-)
 delete mode 100644 drivers/net/ethernet/sfc/mac.h
 create mode 100644 drivers/net/ethernet/sfc/mcdi_mon.c

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-tUYO+L8JifUv5PSutHt0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABCAAGBQJPIwvbAAoJEGkILBsOca609uIIALaUIzyQWbPk+aqOBS5kCn+x
0+nmFSSw/5Ukf1fVYQNdmZwf1EYjdk9TEK9T1R13QkF13xBByWddeHOVPX4HUULv
RNkkevPfJNFwrm1WbJMwzWCNET1qbessDb6B5K8srC1ll4hVozn5u2VDnAXdfVvM
4/qlC/0KeCUeq7m7Nd7EhMWz7wJqAfB6tw0I1BkkrE//gXfafuOQMVUyQAGQyME4
72VAfmI2EFVcDVn7aE1kErA08575qS37VX1ZLAZOYF2ZD5s+zHddZwzUsG6hF3eP
w2oS2sbbKt10q9qRf1fKiBC8jA6g944XCVG/vHVPEe0tnpoIIZnkrkxv9yq4jG8=
=k6Yx
-----END PGP SIGNATURE-----

--=-tUYO+L8JifUv5PSutHt0--
