From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 0/6] sfc: Changes for 2.6.29
Date: Tue, 4 Nov 2008 20:31:18 +0000
Message-ID: <20081104203117.GW7331@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:49581 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752915AbYKDUbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 15:31:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series includes one bug fix also submitted for .28, and a
number of features that were removed from the out-of-tree driver before
submission and have now been simplified and cleaned up.

The MTD driver exposes only the flash partition used for the "expansion
ROM".  We are working on gPXE support for our boards and this makes it
easy for users and developers to update their boards.  We do not want
to expose flash through the ethtool EEPROM access functions because
they are unsuitable for flash and we already map them to the gPXE
configuration partition which really is in EEPROM.

The hardware monitoring code is now mostly contained in the lm87 and
lm90 drivers.  We just configure the sensor limits as necessary and
shut down the PHY in case of an alarm.

Driverlink provides an API to share the NIC's resources with other
drivers that implement hardware-assisted network device virtualisation.
This has already been used to good effect in Xen Linux.  We hope to do
the same for mainline Linux kernels acting as a hypervisor or dom0.

Ben.

Ben Hutchings (6):
  sfc: Correct address of gPXE boot configuration in EEPROM
  sfc: Clean up non-volatile memory partitioning
  sfc: Expose flash region storing boot code as MTD
  sfc: Use lm87 and lm90 drivers for board temperature/power monitoring
  sfc: Do not reset when hardware monitor detects a fault
  sfc: Add driverlink API to support virtual NIC drivers

 drivers/net/sfc/Kconfig          |    8 +
 drivers/net/sfc/Makefile         |    4 +-
 drivers/net/sfc/boards.c         |  136 ++++++++++
 drivers/net/sfc/driverlink.c     |  481 +++++++++++++++++++++++++++++++++++
 drivers/net/sfc/driverlink.h     |   70 +++++
 drivers/net/sfc/driverlink_api.h |  516 ++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/efx.c            |   70 ++++--
 drivers/net/sfc/efx.h            |   10 +
 drivers/net/sfc/enum.h           |    4 +-
 drivers/net/sfc/ethtool.c        |   15 +-
 drivers/net/sfc/falcon.c         |  102 +++++++-
 drivers/net/sfc/falcon_hwdefs.h  |    1 -
 drivers/net/sfc/mdio_10g.c       |   35 +++
 drivers/net/sfc/mdio_10g.h       |    7 +
 drivers/net/sfc/mtd.c            |  268 ++++++++++++++++++++
 drivers/net/sfc/net_driver.h     |   23 ++
 drivers/net/sfc/sfe4001.c        |  116 ++++-----
 drivers/net/sfc/spi.h            |   34 +++-
 drivers/net/sfc/tenxpress.c      |   18 ++-
 drivers/net/sfc/workarounds.h    |    2 +
 drivers/net/sfc/xfp_phy.c        |    9 +
 21 files changed, 1818 insertions(+), 111 deletions(-)
 create mode 100644 drivers/net/sfc/driverlink.c
 create mode 100644 drivers/net/sfc/driverlink.h
 create mode 100644 drivers/net/sfc/driverlink_api.h
 create mode 100644 drivers/net/sfc/mtd.c

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
