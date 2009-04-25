From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 00/13] OF device tree handling of PHY drivers
Date: Sat, 25 Apr 2009 16:52:34 -0600
Message-ID: <20090425224458.32392.31296.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:62952 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbZDYWwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 18:52:39 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1420774rvb.1
        for <netdev@vger.kernel.org>; Sat, 25 Apr 2009 15:52:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds common code for reading PHY connection data out of
the OpenFirmware device tree.  This simplifies the network drivers
which use the device tree and which currently implement their own
solutions for reading the PHY data out of the device tree directly.

I would like to see this series, or at least the core changes (1-4)
plus the tested drivers (5-8 & 12, but #12 is a new driver and it
may need more review), go into -next for 2.6.31.

Due to dependencies, I think it is easiest if all of them go in via the
same tree.  David, are you willing to merge them via yours?  Four of the
patches are outside of drivers/net (patches 1 and 4 touch drivers/of/,
and patches 9 & 10 touch arch/powerpc), but I personally have no issues
if those changes go through you.  I just need to double check with BenH.

For those who are interested, I've pushed these changes out to my git
server.

The following changes since commit 9f5a691253924fd033a58c6b1fed57bb0a4eccf4:
  Linus Torvalds (1):
        Merge branch 'fixes-for-linus' of git://git.monstr.eu/linux-2.6-microblaze

are available in the git repository at:

  git://git.secretlab.ca/git/linux-2.6 next-net

Grant Likely (13):
      of: add of_parse_phandle() helper for parsing phandle properties
      phylib: rework to prepare for OF registration of PHYs
      phylib: add *_direct() variants of phy_connect and phy_attach functions
      openfirmware: Add OF phylib support code
      net: Rework mpc5200 fec driver to use of_mdio infrastructure.
      net: rework fsl_pq_mdio driver to use of_mdio infrastructure
      net: Rework gianfar driver to use of_mdio infrastructure.
      net: Rework pasemi_mac driver to use of_mdio infrastructure
      net: Rework ucc_geth driver to use of_mdio infrastructure
      powerpc/82xx: Rework Embedded Planet ep8248e platform to use of_mdio
      net: Rework fs_enet driver to use of_mdio infrastructure
      net: add Xilinx ll_temac device driver
      net: fix fsl_pq_mdio driver to use module_init()

 arch/powerpc/platforms/82xx/ep8248e.c     |    9 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c |   32 +-
 drivers/net/Kconfig                       |    8 +
 drivers/net/Makefile                      |    2 +
 drivers/net/fec_mpc52xx.c                 |  180 ++----
 drivers/net/fec_mpc52xx_phy.c             |   26 +-
 drivers/net/fs_enet/fs_enet-main.c        |   69 +--
 drivers/net/fs_enet/mii-bitbang.c         |   29 +-
 drivers/net/fs_enet/mii-fec.c             |   26 +-
 drivers/net/fsl_pq_mdio.c                 |   53 +--
 drivers/net/gianfar.c                     |  109 ++---
 drivers/net/gianfar.h                     |    4 +-
 drivers/net/ll_temac.h                    |  374 +++++++++++
 drivers/net/ll_temac_main.c               |  969 +++++++++++++++++++++++++++++
 drivers/net/ll_temac_mdio.c               |  120 ++++
 drivers/net/pasemi_mac.c                  |   28 +-
 drivers/net/pasemi_mac.h                  |    1 -
 drivers/net/phy/mdio_bus.c                |   29 +-
 drivers/net/phy/phy_device.c              |  163 ++++--
 drivers/net/ucc_geth.c                    |   47 +-
 drivers/net/ucc_geth.h                    |    2 +-
 drivers/of/Kconfig                        |    6 +
 drivers/of/Makefile                       |    1 +
 drivers/of/base.c                         |   24 +
 drivers/of/of_mdio.c                      |  139 ++++
 include/linux/fs_enet_pd.h                |    6 +-
 include/linux/of.h                        |    3 +
 include/linux/of_mdio.h                   |   22 +
 include/linux/phy.h                       |    6 +
 29 files changed, 1946 insertions(+), 541 deletions(-)
 create mode 100644 drivers/net/ll_temac.h
 create mode 100644 drivers/net/ll_temac_main.c
 create mode 100644 drivers/net/ll_temac_mdio.c
 create mode 100644 drivers/of/of_mdio.c
 create mode 100644 include/linux/of_mdio.h


--
Grant Likely, B.Sc. P.Eng.
Secret Lab Technologies Ltd.
