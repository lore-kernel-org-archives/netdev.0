From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-08-22
Date: Thu, 22 Aug 2013 13:43:12 +0100
Message-ID: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-O44NHqqpX9FkiKq6zBeV"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13404 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402Ab3HVMnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 08:43:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-O44NHqqpX9FkiKq6zBeV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 563b44951e76bd23ba3fabcc3a0c708d8f59c5fb=
:

  Merge branch 'openvswitch_vxlan' (2013-08-20 00:16:47 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to f76fe120d81c96fa2a17ae41f0647c963dbb43cd:

  sfc: Update and improve kernel-doc for efx_mcdi_state & efx_mcdi_iface (2=
013-08-21 20:20:41 +0100)

1. Merge of the fix that I just asked you to pull for net.  This does
*not* merge in anything else that isn't already in net-next.
2. Refactoring and cleanup in preparation for new hardware support.
3. Update MCDI (firmware interface) definitions.

Ben.

----------------------------------------------------------------
Ben Hutchings (33):
      sfc: Fix lookup of default RX MAC filters when steered using ethtool
      Merge branch 'sfc-3.11'
      sfc: const-qualify source pointers for MMIO write functions
      sfc: Use efx_mcdi_mon() to find efx_mcdi_mon structure from efx_nic
      sfc: Move details of a Falcon bug workaround out of ethtool.c
      sfc: Move more Falcon-specific code and definitions into falcon.c
      sfc: Introduce and use MCDI_DECLARE_BUF macro
      sfc: Rationalise MCDI buffer accessors
      sfc: Fill out the set of MCDI accessors
      sfc: Introduce and use MCDI_CTL_SDU_LEN_MAX_V1 macro for Siena-specif=
ic code
      sfc: Use proper macros to declare and access MCDI arrays
      sfc: Ensure MCDI buffers, but not lengths, are dword aligned
      sfc: Add and use MCDI_SET_QWORD() and MCDI_SET_ARRAY_QWORD()
      sfc: Move siena_reset_hw() and siena_map_reset_reason() into MCDI mod=
ule
      sfc: Move efx_mcdi_mac_reconfigure() to siena.c and rename
      sfc: Collect all MCDI port functions into mcdi_port.c
      sfc: Make efx_mcdi_init() call efx_mcdi_handle_assertion()
      sfc: Make MCDI independent of Siena
      sfc: Add GFP flags to efx_nic_alloc_buffer() and make most callers al=
low blocking
      sfc: Make struct efx_special_buffer less special
      sfc: Rename Falcon-architecture register definitions
      sfc: Remove efx_process_channel_now()
      sfc: Rework IRQ enable/disable
      sfc: Limit scope of a Falcon A1 IRQ workaround
      sfc: Stop RX refill before flushing RX queues
      sfc: Remove bogus call to efx_release_tx_buffers()
      sfc: Refactor queue teardown sequence to allow for EF10 flush behavio=
ur
      sfc: Move and rename Falcon/Siena common NIC operations
      sfc: Translate MCDI error numbers received in events
      sfc: Update MCDI protocol definitions for EF10
      sfc: Add support for MCDI v2
      sfc: Fix race in completion handling
      sfc: Update and improve kernel-doc for efx_mcdi_state & efx_mcdi_ifac=
e

 drivers/net/ethernet/sfc/Makefile                  |    6 +-
 drivers/net/ethernet/sfc/efx.c                     |  216 +-
 drivers/net/ethernet/sfc/efx.h                     |    3 -
 drivers/net/ethernet/sfc/ethtool.c                 |   23 +-
 drivers/net/ethernet/sfc/falcon.c                  |  639 ++-
 drivers/net/ethernet/sfc/falcon_xmac.c             |  362 --
 drivers/net/ethernet/sfc/farch.c                   | 1781 +++++++
 drivers/net/ethernet/sfc/{regs.h =3D> farch_regs.h}  |  266 +-
 drivers/net/ethernet/sfc/filter.c                  |    4 +-
 drivers/net/ethernet/sfc/io.h                      |   18 +-
 drivers/net/ethernet/sfc/mcdi.c                    |  477 +-
 drivers/net/ethernet/sfc/mcdi.h                    |  184 +-
 drivers/net/ethernet/sfc/mcdi_mac.c                |  130 -
 drivers/net/ethernet/sfc/mcdi_mon.c                |   15 +-
 drivers/net/ethernet/sfc/mcdi_pcol.h               | 5536 ++++++++++++++++=
++--
 .../net/ethernet/sfc/{mcdi_phy.c =3D> mcdi_port.c}   |  325 +-
 drivers/net/ethernet/sfc/net_driver.h              |  157 +-
 drivers/net/ethernet/sfc/nic.c                     | 1812 +------
 drivers/net/ethernet/sfc/nic.h                     |  263 +-
 drivers/net/ethernet/sfc/phy.h                     |   17 -
 drivers/net/ethernet/sfc/ptp.c                     |   81 +-
 drivers/net/ethernet/sfc/rx.c                      |    9 +-
 drivers/net/ethernet/sfc/selftest.c                |   11 -
 drivers/net/ethernet/sfc/siena.c                   |  284 +-
 drivers/net/ethernet/sfc/siena_sriov.c             |   98 +-
 drivers/net/ethernet/sfc/tx.c                      |   24 +-
 drivers/net/ethernet/sfc/workarounds.h             |    2 -
 27 files changed, 8901 insertions(+), 3842 deletions(-)
 delete mode 100644 drivers/net/ethernet/sfc/falcon_xmac.c
 create mode 100644 drivers/net/ethernet/sfc/farch.c
 rename drivers/net/ethernet/sfc/{regs.h =3D> farch_regs.h} (92%)
 delete mode 100644 drivers/net/ethernet/sfc/mcdi_mac.c
 rename drivers/net/ethernet/sfc/{mcdi_phy.c =3D> mcdi_port.c} (74%)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-O44NHqqpX9FkiKq6zBeV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQEcBAABCAAGBQJSFgdgAAoJEGkILBsOca6025UIAKCrKTfeSP3v5Ci9HptsBEOA
+7VVOrRZe3/w40fNIkQK6Jh9HODdEdpVW52XDCA401Y30oJsLPUDG+CWXzH59jKt
8onP+TGbInyLqRxrpsQ1ThKjNSKVFlNU7ZT9I5z/yfmXQTUlsSwJb59Qnvl6ekOL
j/e5Mk2zw1uJNbqMRMCojrXeksgpDKxmT4rBKhq564EhT1N9eaD8hC56D8jx77O0
HXAnH38bdU9nZglCDdJcR2AzDKGMPBaeYfcDpCADMvHS1D+6RrL9q0kH8VEBfeFt
ZnGRcg2eCewbRwqr/HEVzBP2grlLEluxPdLDidE8DiiUJV8NIsQa4EeAwao1SKk=
=6vfe
-----END PGP SIGNATURE-----

--=-O44NHqqpX9FkiKq6zBeV--
