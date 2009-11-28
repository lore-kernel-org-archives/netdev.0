From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 30/32] sfc: Add support for SFC9000 family
Date: Sat, 28 Nov 2009 03:58:45 +0000
Message-ID: <1259380725.2811.74.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42960 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753421AbZK1D6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:58:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for the SFC9000 family of 10G Ethernet controllers
and LAN-on-motherboard chips, starting with the SFL9021 'Siena' and
SFC9020 'Bethpage'.

The SFC9000 family is based on the SFC4000 'Falcon' architecture, but
with some significant changes:

- Two ports are associated with two independent PCI functions
  (except SFC9010)
- Integrated 10GBASE-T PHY(s) (SFL9021/9022)
- MAC, PHY and board peripherals are managed by firmware
  - Driver does not require board-specific code
  - Firmware supports wake-on-LAN and lights-out management through NC-SI
- IPv6 checksum offload and RSS
- Filtering by MAC address and VLAN (not included in this code)
- PCI SR-IOV (not included in this code)

Credit for this code is largely due to my colleagues at Solarflare:

   Guido Barzini
   Steve Hodgson
   Kieran Mansley
   Matthew Slattery
   Neil Turton

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
No diff as it's too large for netdev.

Ben.

 drivers/net/sfc/Kconfig       |   13 +-
 drivers/net/sfc/Makefile      |    7 +-
 drivers/net/sfc/bitfield.h    |    2 +
 drivers/net/sfc/efx.c         |   26 +
 drivers/net/sfc/efx.h         |    2 +
 drivers/net/sfc/enum.h        |    2 +
 drivers/net/sfc/ethtool.c     |    3 +
 drivers/net/sfc/mac.h         |    3 +
 drivers/net/sfc/mcdi.c        | 1112 +++++++++++++++++++++++++++++
 drivers/net/sfc/mcdi.h        |  130 ++++
 drivers/net/sfc/mcdi_mac.c    |  152 ++++
 drivers/net/sfc/mcdi_pcol.h   | 1578 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/mcdi_phy.c    |  597 ++++++++++++++++
 drivers/net/sfc/mtd.c         |  267 +++++++-
 drivers/net/sfc/net_driver.h  |   10 +-
 drivers/net/sfc/nic.c         |   59 ++-
 drivers/net/sfc/nic.h         |   23 +
 drivers/net/sfc/phy.h         |   17 +
 drivers/net/sfc/siena.c       |  604 ++++++++++++++++
 drivers/net/sfc/workarounds.h |    5 +
 20 files changed, 4585 insertions(+), 27 deletions(-)
 create mode 100644 drivers/net/sfc/mcdi.c
 create mode 100644 drivers/net/sfc/mcdi.h
 create mode 100644 drivers/net/sfc/mcdi_mac.c
 create mode 100644 drivers/net/sfc/mcdi_pcol.h
 create mode 100644 drivers/net/sfc/mcdi_phy.c
 create mode 100644 drivers/net/sfc/siena.c


