From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-08-22 v2
Date: Thu, 22 Aug 2013 20:22:06 +0100
Message-ID: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29670 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393Ab3HVTWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 15:22:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 563b44951e76bd23ba3fabcc3a0c708d8f59c5fb:

  Merge branch 'openvswitch_vxlan' (2013-08-20 00:16:47 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to f073dde03b3e8d11050d82f52caaf75fd924e069:

  sfc: Make efx_mcdi_init() call efx_mcdi_handle_assertion() (2013-08-21 19:43:09 +0100)

1. Merge of the fix that I just asked you to pull for net.  This does
*not* merge in anything else that isn't already in net-next.
2. Refactoring and cleanup in preparation for new hardware support.

Ben.

----------------------------------------------------------------
Ben Hutchings (17):
      sfc: Fix lookup of default RX MAC filters when steered using ethtool
      Merge branch 'sfc-3.11'
      sfc: const-qualify source pointers for MMIO write functions
      sfc: Use efx_mcdi_mon() to find efx_mcdi_mon structure from efx_nic
      sfc: Move details of a Falcon bug workaround out of ethtool.c
      sfc: Move more Falcon-specific code and definitions into falcon.c
      sfc: Introduce and use MCDI_DECLARE_BUF macro
      sfc: Rationalise MCDI buffer accessors
      sfc: Fill out the set of MCDI accessors
      sfc: Introduce and use MCDI_CTL_SDU_LEN_MAX_V1 macro for Siena-specific code
      sfc: Use proper macros to declare and access MCDI arrays
      sfc: Ensure MCDI buffers, but not lengths, are dword aligned
      sfc: Add and use MCDI_SET_QWORD() and MCDI_SET_ARRAY_QWORD()
      sfc: Move siena_reset_hw() and siena_map_reset_reason() into MCDI module
      sfc: Move efx_mcdi_mac_reconfigure() to siena.c and rename
      sfc: Collect all MCDI port functions into mcdi_port.c
      sfc: Make efx_mcdi_init() call efx_mcdi_handle_assertion()

 drivers/net/ethernet/sfc/Makefile                  |   3 +-
 drivers/net/ethernet/sfc/ethtool.c                 |  23 +-
 drivers/net/ethernet/sfc/falcon.c                  | 563 ++++++++++++++++++++-
 drivers/net/ethernet/sfc/falcon_xmac.c             | 362 -------------
 drivers/net/ethernet/sfc/filter.c                  |   2 +-
 drivers/net/ethernet/sfc/io.h                      |  18 +-
 drivers/net/ethernet/sfc/mcdi.c                    | 206 ++++----
 drivers/net/ethernet/sfc/mcdi.h                    | 131 +++--
 drivers/net/ethernet/sfc/mcdi_mac.c                | 130 -----
 drivers/net/ethernet/sfc/mcdi_mon.c                |  13 +-
 drivers/net/ethernet/sfc/mcdi_pcol.h               |   4 +-
 .../net/ethernet/sfc/{mcdi_phy.c => mcdi_port.c}   | 322 +++++++++---
 drivers/net/ethernet/sfc/net_driver.h              |   2 +
 drivers/net/ethernet/sfc/nic.h                     |  44 +-
 drivers/net/ethernet/sfc/phy.h                     |  17 -
 drivers/net/ethernet/sfc/ptp.c                     |  72 +--
 drivers/net/ethernet/sfc/regs.h                    | 260 ----------
 drivers/net/ethernet/sfc/siena.c                   | 153 ++----
 drivers/net/ethernet/sfc/siena_sriov.c             |  81 ++-
 drivers/net/ethernet/sfc/workarounds.h             |   2 -
 20 files changed, 1130 insertions(+), 1278 deletions(-)
 delete mode 100644 drivers/net/ethernet/sfc/falcon_xmac.c
 delete mode 100644 drivers/net/ethernet/sfc/mcdi_mac.c
 rename drivers/net/ethernet/sfc/{mcdi_phy.c => mcdi_port.c} (74%)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
