From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 00/33] sfc version 2.3
Date: Fri, 12 Dec 2008 12:46:24 +0000
Message-ID: <20081212124622.GK32518@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:42205 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752651AbYLLMqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:46:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The big changes here are to add support for Solarflare's new multi-speed
PHY and reference design.  There are also a number of small fixes, clean-
up and new features.

Ben.

Ben Hutchings (31):
  sfc: Board support fixes
  sfc: Change SPI lengths to type size_t
  sfc: Do not use pci_disable_device() to disable bus mastering
  sfc: Remove unneeded register write
  sfc: Correct interpretation of second param to ethtool phys_id()
  sfc: Clean up waits for flash/EEPROM operations
  sfc: Work around unreliable strap pins
  sfc: Restore phy_flash_cfg module parameter
  sfc: Provide hints to irqbalance daemon
  sfc: Abbreviate self-test names so they are not truncated
  sfc: Don't count RX checksum errors during loopback self-test
  sfc: Remove MII extension cruft
  sfc: Add support for MMDs numbered >15
  sfc: Add phy_type device attribute
  sfc: Clean up board identification
  sfc: Clean up MDIO flag setting
  sfc: Add support for sub-10G speeds
  sfc: Implement auto-negotiation
  sfc: Rework MAC, PHY and board event handling
  sfc: Add support for Solarflare 10Xpress SFT9001
  sfc: Add support for SFN4111T
  sfc: Fix format arguments for warning about MSI-X allocation
  sfc: Generate unique names for per-NIC workqueues
  sfc: Remove leading spaces
  sfc: Specify a meaningful component for loopback RX-side and PHY
    tests
  sfc: Use mutex_lock_interruptible() for ethtool EEPROM access
  sfc: Use model numbers for PHY type names
  sfc: Treat probe as unsuccessful if it scheduled a reset
  sfc: Use kzalloc() to ensure struct efx_spi_device is fully
    initialised
  sfc: Fix synchronisation of efx_mtd_{probe,rename,remove}
  sfc: Version 2.3

Neil Turton (1):
  sfc: Add option to use a separate channel for TX completions

Steve Hodgson (1):
  sfc: Make reset_workqueue driver-global rather than per-NIC

 drivers/net/sfc/Makefile        |    4 +-
 drivers/net/sfc/boards.c        |   70 ++---
 drivers/net/sfc/boards.h        |   14 +-
 drivers/net/sfc/efx.c           |  331 ++++++++++++-------
 drivers/net/sfc/enum.h          |   32 +-
 drivers/net/sfc/ethtool.c       |  137 ++++++---
 drivers/net/sfc/falcon.c        |  472 ++++++++++++++++-----------
 drivers/net/sfc/falcon.h        |    3 +
 drivers/net/sfc/falcon_gmac.c   |  229 +++++++++++++
 drivers/net/sfc/falcon_hwdefs.h |  160 +++++++++
 drivers/net/sfc/falcon_xmac.c   |  261 +++------------
 drivers/net/sfc/gmii.h          |  137 +--------
 drivers/net/sfc/mac.h           |   16 +-
 drivers/net/sfc/mdio_10g.c      |  453 ++++++++++++++++++--------
 drivers/net/sfc/mdio_10g.h      |   52 +++-
 drivers/net/sfc/mtd.c           |    2 +-
 drivers/net/sfc/net_driver.h    |  113 ++++++-
 drivers/net/sfc/phy.h           |    7 +-
 drivers/net/sfc/selftest.c      |   41 ++-
 drivers/net/sfc/selftest.h      |    2 -
 drivers/net/sfc/sfe4001.c       |  153 +++++++--
 drivers/net/sfc/spi.h           |    2 +-
 drivers/net/sfc/tenxpress.c     |  686 +++++++++++++++++++++++++++++----------
 drivers/net/sfc/workarounds.h   |   12 +-
 drivers/net/sfc/xfp_phy.c       |   38 +--
 25 files changed, 2232 insertions(+), 1195 deletions(-)
 create mode 100644 drivers/net/sfc/falcon_gmac.c

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
