From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 00/13] Rework network drivers to use of_mdio common code
Date: Sat, 21 Mar 2009 16:28:10 -0600
Message-ID: <20090321222047.20493.87335.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, galak@kernel.crashing.org,
	davem@davemloft.net
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:31077 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146AbZCUW2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 18:28:16 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2085459wff.4
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2009 15:28:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series reworks some of the phylib code and adds of_mdio helper
functions to make it easier for device drivers to retrieve the PHY
configuration by reading the OF device tree.

Most of these changes have been only compile tested, but not booted on
real hardware.  Exceptions are mpc52xx and ll_temac which have been tested,
and pasemi which hasn't even been compile tested because my 64bit
environment is broken at the moment.

For those with access to hardware, please test and provide me with feedback.

This series also adds a new network driver for the Xilinx ll_temac
10/100/1000 MAC.

For those who are interested, this series is available on my git server at:

git://git.secretlab.ca/git/linux-2.6-mpc52xx test

Right now it is based on current mainline plus a bunch of patches that I've
already got in Benh's -next tree (but is not actually based on Benh's tree).
I'll probably rebase before I post v3

Changes since v1:
- Add ll_temac driver
- Clean up of_node_put() calls
- removal of dead code from ucc_geth driver
- Fix changes to gianfar driver to not try to connect to tbi phy.


diffstat:
 arch/powerpc/boot/dts/virtex440-ml507.dts |   14 +-
 arch/powerpc/platforms/82xx/ep8248e.c     |    7 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c |   29 +-
 drivers/net/Kconfig                       |    8 +
 drivers/net/Makefile                      |    2 +
 drivers/net/fec_mpc52xx.c                 |  228 +++----
 drivers/net/fec_mpc52xx_phy.c             |   26 +-
 drivers/net/fs_enet/fs_enet-main.c        |   69 +--
 drivers/net/fs_enet/mii-bitbang.c         |   29 +-
 drivers/net/fs_enet/mii-fec.c             |   26 +-
 drivers/net/gianfar.c                     |  103 ++--
 drivers/net/gianfar.h                     |    3 +-
 drivers/net/gianfar_mii.c                 |   52 +--
 drivers/net/pasemi_mac.c                  |   19 +-
 drivers/net/pasemi_mac.h                  |    1 -
 drivers/net/phy/marvell.c                 |    2 +
 drivers/net/phy/mdio_bus.c                |   29 +-
 drivers/net/phy/phy_device.c              |  163 ++++--
 drivers/net/ucc_geth.c                    |   65 +--
 drivers/net/ucc_geth.h                    |    2 -
 drivers/net/ucc_geth_mii.c                |   17 +-
 drivers/net/xilinx_temac.c                |  970 +++++++++++++++++++++++++++++
 drivers/net/xilinx_temac.h                |  374 +++++++++++
 drivers/net/xilinx_temac_mdio.c           |  119 ++++
 drivers/of/Kconfig                        |    6 +
 drivers/of/Makefile                       |    1 +
 drivers/of/base.c                         |   24 +
 drivers/of/of_mdio.c                      |  139 ++++
 include/linux/fs_enet_pd.h                |    6 +-
 include/linux/of.h                        |    3 +
 include/linux/of_mdio.h                   |   22 +
 include/linux/phy.h                       |    6 +
 32 files changed, 1989 insertions(+), 575 deletions(-)
 create mode 100644 drivers/net/xilinx_temac.c
 create mode 100644 drivers/net/xilinx_temac.h
 create mode 100644 drivers/net/xilinx_temac_mdio.c
 create mode 100644 drivers/of/of_mdio.c
 create mode 100644 include/linux/of_mdio.h

--
Grant Likely, B.Sc. P.Eng.
Secret Lab Technologies Ltd.
