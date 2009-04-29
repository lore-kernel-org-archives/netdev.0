From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 00/16] MDIO and ethtool enhancements
Date: Wed, 29 Apr 2009 19:01:26 +0100
Message-ID: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:53284 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753395AbZD2SBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:01:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first part of this series introduce counterparts to <linux/mii.h>
and the mii module for use with MDIO clause 45 devices and controllers
that support both clause 22 and clause 45, and change several 10G
Ethernet drivers to use them.

The remaining patches are a bit miscellaneous:
- Extend generic flow control/pause frame support and change the sfc
driver to use it
- Add fields to the ethtool_cmd structure to report the supported MDIO
mode(s) and link partner advertising flags, and implement these in the
mdio and mii modules
- Add support for backplane (1000BASE-KR and 10GBASE-KR/KX4) modes to
ethtool and the mdio module

I have a few questions to be resolved:
- Is the naming of functions and constants in <linux/mdio.h> reasonable,
or is more qualification required?
- Is it reasonable to carry on using the MII ioctl interface with flags?
- Are there more drivers that could use these generic definitions (I
haven't looked at the Broadcom drivers yet)?
- Does the backplane code work at all (I don't have any suitable
hardware yet)?

Ben.

Ben Hutchings (16):
  ethtool: Add port type PORT_OTHER
  mdio: Add register definitions for MDIO (clause 45)
  mdio: Add generic MDIO (clause 45) support functions
  sfc: Use generic MDIO functions and definitions
  chelsio: Use generic MDIO definitions and mdio_mii_ioctl()
  cxgb3: Use generic MDIO definitions and mdio_mii_ioctl()
  ixgbe: Use generic MDIO definitions and functions
  ixgb: Use generic MDIO definitions
  s2io: Use generic MDIO definitions
  mii: Simplify mii_resolve_flowctrl_fdx()
  mii: Add mii_advertise_flowctrl()
  mdio: Add mdio45_ethtool_spauseparam_an()
  sfc: Use generic MDIO flow control auto-negotiation functions
  ethtool/mdio: Report MDIO mode support and link partner advertising
  ethtool/mdio: Support backplane mode negotiation
  mii: Report mdio_support and lp_advertising from generic_mii_ioctl()

 drivers/net/Kconfig             |    6 +
 drivers/net/Makefile            |    1 +
 drivers/net/chelsio/common.h    |    2 +-
 drivers/net/chelsio/cphy.h      |   45 +++--
 drivers/net/chelsio/cxgb2.c     |   36 +---
 drivers/net/chelsio/mv88x201x.c |   45 +++--
 drivers/net/chelsio/my3126.c    |   10 +-
 drivers/net/chelsio/subr.c      |   43 +++--
 drivers/net/cxgb3/ael1002.c     |  146 +++++++-------
 drivers/net/cxgb3/common.h      |   53 +++---
 drivers/net/cxgb3/cxgb3_main.c  |   71 ++------
 drivers/net/cxgb3/t3_hw.c       |   78 ++++----
 drivers/net/cxgb3/vsc8211.c     |   70 ++++---
 drivers/net/ixgb/ixgb_hw.c      |   20 +-
 drivers/net/ixgb/ixgb_hw.h      |   14 +--
 drivers/net/ixgbe/ixgbe_82598.c |   33 ++--
 drivers/net/ixgbe/ixgbe_82599.c |   17 +-
 drivers/net/ixgbe/ixgbe_main.c  |   42 ++++
 drivers/net/ixgbe/ixgbe_phy.c   |   95 +++------
 drivers/net/ixgbe/ixgbe_type.h  |   33 +---
 drivers/net/mdio.c              |  414 +++++++++++++++++++++++++++++++++++++++
 drivers/net/mii.c               |   91 ++++++----
 drivers/net/s2io-regs.h         |    5 -
 drivers/net/s2io.c              |   21 +-
 drivers/net/sfc/Kconfig         |    2 +-
 drivers/net/sfc/efx.c           |   10 +-
 drivers/net/sfc/ethtool.c       |   19 +--
 drivers/net/sfc/falcon.c        |  137 ++++----------
 drivers/net/sfc/falcon_hwdefs.h |    3 -
 drivers/net/sfc/falcon_xmac.c   |    2 +-
 drivers/net/sfc/mdio_10g.c      |  385 +++++++-----------------------------
 drivers/net/sfc/mdio_10g.h      |  282 ++++-----------------------
 drivers/net/sfc/net_driver.h    |   34 +---
 drivers/net/sfc/selftest.c      |   21 +-
 drivers/net/sfc/selftest.h      |    2 +-
 drivers/net/sfc/tenxpress.c     |  226 +++++++++-------------
 drivers/net/sfc/xenpack.h       |   15 +-
 drivers/net/sfc/xfp_phy.c       |   51 +++---
 include/linux/ethtool.h         |   15 ++-
 include/linux/mdio.h            |  312 +++++++++++++++++++++++++++++
 include/linux/mii.h             |   34 ++--
 41 files changed, 1532 insertions(+), 1409 deletions(-)
 create mode 100644 drivers/net/mdio.c
 create mode 100644 include/linux/mdio.h

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

