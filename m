From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/2] sfc: split out Falcon driver
Date: Fri, 25 Nov 2016 17:44:46 +0000
Message-ID: <e897bd71-1772-705c-5640-25112140b009@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:55293 "EHLO
        nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932463AbcKYRpC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 12:45:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series splits out support for the obsolescent SFC4000 family into its
 own driver, sfc-falcon.
See patch #1 for rationale.

Edward Cree (2):
  sfc: separate out SFC4000 ("Falcon") support into new sfc-falcon
    driver
  sfc: remove obvious Falcon-related code

 drivers/net/ethernet/Kconfig                    |    1 +
 drivers/net/ethernet/Makefile                   |    1 +
 drivers/net/ethernet/sfc/Kconfig                |    8 +-
 drivers/net/ethernet/sfc/Makefile               |    7 +-
 drivers/net/ethernet/sfc/efx.c                  |   29 +-
 drivers/net/ethernet/sfc/ethtool.c              |   15 +-
 drivers/net/ethernet/sfc/falcon.c               | 2907 --------------------
 drivers/net/ethernet/sfc/falcon/Kconfig         |   21 +
 drivers/net/ethernet/sfc/falcon/Makefile        |    6 +
 drivers/net/ethernet/sfc/falcon/bitfield.h      |  542 ++++
 drivers/net/ethernet/sfc/falcon/efx.c           | 3350 +++++++++++++++++++++++
 drivers/net/ethernet/sfc/falcon/efx.h           |  277 ++
 drivers/net/ethernet/sfc/falcon/enum.h          |  171 ++
 drivers/net/ethernet/sfc/falcon/ethtool.c       | 1343 +++++++++
 drivers/net/ethernet/sfc/falcon/falcon.c        | 2903 ++++++++++++++++++++
 drivers/net/ethernet/sfc/falcon/falcon_boards.c |  764 ++++++
 drivers/net/ethernet/sfc/falcon/farch.c         | 2892 +++++++++++++++++++
 drivers/net/ethernet/sfc/falcon/farch_regs.h    | 2932 ++++++++++++++++++++
 drivers/net/ethernet/sfc/falcon/filter.h        |  272 ++
 drivers/net/ethernet/sfc/falcon/io.h            |  290 ++
 drivers/net/ethernet/sfc/falcon/mdio_10g.c      |  323 +++
 drivers/net/ethernet/sfc/falcon/mdio_10g.h      |  110 +
 drivers/net/ethernet/sfc/falcon/mtd.c           |  133 +
 drivers/net/ethernet/sfc/falcon/net_driver.h    | 1464 ++++++++++
 drivers/net/ethernet/sfc/falcon/nic.c           |  527 ++++
 drivers/net/ethernet/sfc/falcon/nic.h           |  513 ++++
 drivers/net/ethernet/sfc/falcon/phy.h           |   50 +
 drivers/net/ethernet/sfc/falcon/qt202x_phy.c    |  495 ++++
 drivers/net/ethernet/sfc/falcon/rx.c            |  974 +++++++
 drivers/net/ethernet/sfc/falcon/selftest.c      |  808 ++++++
 drivers/net/ethernet/sfc/falcon/selftest.h      |   55 +
 drivers/net/ethernet/sfc/falcon/tenxpress.c     |  494 ++++
 drivers/net/ethernet/sfc/falcon/tx.c            |  649 +++++
 drivers/net/ethernet/sfc/falcon/tx.h            |   27 +
 drivers/net/ethernet/sfc/falcon/txc43128_phy.c  |  560 ++++
 drivers/net/ethernet/sfc/falcon/workarounds.h   |   44 +
 drivers/net/ethernet/sfc/falcon_boards.c        |  764 ------
 drivers/net/ethernet/sfc/farch.c                |  165 +-
 drivers/net/ethernet/sfc/mcdi.c                 |    1 -
 drivers/net/ethernet/sfc/mcdi_port.c            |    1 -
 drivers/net/ethernet/sfc/mdio_10g.c             |  323 ---
 drivers/net/ethernet/sfc/mdio_10g.h             |  110 -
 drivers/net/ethernet/sfc/net_driver.h           |    4 +-
 drivers/net/ethernet/sfc/nic.h                  |  172 +-
 drivers/net/ethernet/sfc/phy.h                  |   50 -
 drivers/net/ethernet/sfc/qt202x_phy.c           |  495 ----
 drivers/net/ethernet/sfc/rx.c                   |   19 +-
 drivers/net/ethernet/sfc/siena.c                |    1 -
 drivers/net/ethernet/sfc/tenxpress.c            |  494 ----
 drivers/net/ethernet/sfc/tx.c                   |   22 +-
 drivers/net/ethernet/sfc/txc43128_phy.c         |  560 ----
 drivers/net/ethernet/sfc/workarounds.h          |   21 -
 52 files changed, 23076 insertions(+), 6083 deletions(-)
 delete mode 100644 drivers/net/ethernet/sfc/falcon.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/Kconfig
 create mode 100644 drivers/net/ethernet/sfc/falcon/Makefile
 create mode 100644 drivers/net/ethernet/sfc/falcon/bitfield.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/efx.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/efx.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/enum.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/ethtool.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/falcon.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/falcon_boards.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/farch.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/farch_regs.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/filter.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/io.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/mdio_10g.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/mdio_10g.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/mtd.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/net_driver.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/nic.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/nic.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/phy.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/qt202x_phy.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/rx.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/selftest.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/selftest.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/tenxpress.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/tx.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/tx.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/txc43128_phy.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/workarounds.h
 delete mode 100644 drivers/net/ethernet/sfc/falcon_boards.c
 delete mode 100644 drivers/net/ethernet/sfc/mdio_10g.c
 delete mode 100644 drivers/net/ethernet/sfc/mdio_10g.h
 delete mode 100644 drivers/net/ethernet/sfc/phy.h
 delete mode 100644 drivers/net/ethernet/sfc/qt202x_phy.c
 delete mode 100644 drivers/net/ethernet/sfc/tenxpress.c
 delete mode 100644 drivers/net/ethernet/sfc/txc43128_phy.c
