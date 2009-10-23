From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 00/27] sfc: Cleanup and preparation for new hardware
Date: Fri, 23 Oct 2009 19:27:21 +0100
Message-ID: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8378 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978AbZJWS1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:27:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

This is a mixture of small cleanups, refactoring, renaming and an update
to the register definitions.  There's more to come, in particular
support for the new hardware, but I'll let you digest this batch first.

Ben.

Ben Hutchings (27):
  sfc: Remove redundant header gmii.h
  sfc: Remove redundant hardware initialisation
  sfc: Rename Falcon-specific board code and types
  sfc: Merge sfe4001.c into falcon_boards.c
  sfc: Remove boards.h, moving last remaining declaration to falcon.h
  sfc: Remove versioned bitfield macros
  sfc: Move RX data FIFO thresholds out of struct efx_nic_type
  sfc: Update hardware definitions for Siena
  sfc: Rename register I/O header and functions used by both Falcon and
    Siena
  sfc: Eliminate indirect lookups of queue size constants
  sfc: Define DMA address mask explicitly in terms of descriptor field
    width
  sfc: Move all TX DMA length limiting into tx.c
  sfc: Merge struct efx_blinker into struct efx_board
  sfc: Change order of device removal to reverse of probe order
  sfc: Remove declarations of nonexistent functions
  sfc: Move efx_xmit_done() declaration into correct stanza
  sfc: Move shared members of struct falcon_nic_data into struct
    efx_nic
  sfc: Maintain interrupt moderation values in ticks, not microseconds
  sfc: Removed kernel-doc for nonexistent member of efx_phy_operations
  sfc: Remove pointless abstraction of memory BAR number
  sfc: Merge falcon_probe_phy() into falcon_probe_port()
  sfc: Remove incorrect assertion from efx_pci_remove_main()
  sfc: Remove unnecessary tests of efx->membase
  sfc: Move MTD probe after netdev registration and name allocation
  sfc: Merge efx_fc_resolve() into efx_mdio_get_pause()
  sfc: Remove unused code for non-autoneg speed/duplex switching
  sfc: Rename 'xfp' file and functions to reflect reality

 drivers/net/sfc/Makefile                    |    4 +-
 drivers/net/sfc/bitfield.h                  |   13 -
 drivers/net/sfc/boards.c                    |  328 ---
 drivers/net/sfc/boards.h                    |   28 -
 drivers/net/sfc/efx.c                       |   89 +-
 drivers/net/sfc/efx.h                       |   11 +-
 drivers/net/sfc/ethtool.c                   |    8 +-
 drivers/net/sfc/falcon.c                    | 1122 +++++-----
 drivers/net/sfc/falcon.h                    |    4 +-
 drivers/net/sfc/falcon_boards.c             |  752 +++++++
 drivers/net/sfc/falcon_gmac.c               |   95 +-
 drivers/net/sfc/falcon_hwdefs.h             | 1333 -----------
 drivers/net/sfc/falcon_io.h                 |  258 ---
 drivers/net/sfc/falcon_xmac.c               |  178 +-
 drivers/net/sfc/gmii.h                      |   60 -
 drivers/net/sfc/io.h                        |  256 +++
 drivers/net/sfc/mdio_10g.c                  |  121 +-
 drivers/net/sfc/mdio_10g.h                  |    1 -
 drivers/net/sfc/net_driver.h                |   56 +-
 drivers/net/sfc/phy.h                       |    6 +-
 drivers/net/sfc/{xfp_phy.c => qt202x_phy.c} |   80 +-
 drivers/net/sfc/regs.h                      | 3180 +++++++++++++++++++++++++++
 drivers/net/sfc/rx.c                        |   16 +-
 drivers/net/sfc/selftest.c                  |    5 +-
 drivers/net/sfc/sfe4001.c                   |  435 ----
 drivers/net/sfc/tenxpress.c                 |    3 +-
 drivers/net/sfc/tx.c                        |   83 +-
 drivers/net/sfc/workarounds.h               |    2 +
 28 files changed, 5091 insertions(+), 3436 deletions(-)
 delete mode 100644 drivers/net/sfc/boards.c
 delete mode 100644 drivers/net/sfc/boards.h
 create mode 100644 drivers/net/sfc/falcon_boards.c
 delete mode 100644 drivers/net/sfc/falcon_hwdefs.h
 delete mode 100644 drivers/net/sfc/falcon_io.h
 delete mode 100644 drivers/net/sfc/gmii.h
 create mode 100644 drivers/net/sfc/io.h
 rename drivers/net/sfc/{xfp_phy.c => qt202x_phy.c} (73%)
 create mode 100644 drivers/net/sfc/regs.h
 delete mode 100644 drivers/net/sfc/sfe4001.c

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

