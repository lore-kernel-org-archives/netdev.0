From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 00/15] net: phy: Centralize auto-negotation restart
Date: Tue, 15 Nov 2016 10:06:29 -0800
Message-ID: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36780 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753098AbcKOSG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:06:59 -0500
Received: by mail-pg0-f65.google.com with SMTP id x23so12378509pgx.3
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:06:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series centralizes how ethtool::nway_reset is implemented
by providing a PHYLIB function which calls into genphy_restart_aneg().

All drivers below are converted to use this new helper function. Some
other have specific requirements that make them not quite suitable for
a straight forward conversion.

There is another patch series which implements ethtool::nway_reset
using the helper function introduced that depends on this patch
series.

Florian Fainelli (15):
  net: phy: Add phy_ethtool_nway_reset
  net: nb8800: Utilize phy_ethtool_nway_reset
  net: bcm63xx_enet: Utilize phy_ethtool_nway_reset
  net: mv643xx_eth: Utilize phy_ethtool_nway_reset
  net: smsc911x: Utilize phy_ethtool_nway_reset
  net: ethernet: smsc9420: Utilize phy_ethtool_nway_reset
  net: ethernet: ll_temac: Utilize phy_ethtool_nway_reset
  net: ethernet: ixp4xx_eth: Utilize phy_ethtool_nway_reset
  net: bcmgenet: Utilize phy_ethtool_nway_reset
  net: fs_enet: Utilize phy_ethtool_nway_reset
  net: fec: Utilize phy_ethtool_nway_reset
  net: ethernet: ucc: Utilize phy_ethtool_nway_reset
  net: ethernet: lantiq_etop: Utilize phy_ethtool_nway_reset
  net: usb: ax88172x: Utilize phy_ethtool_nway_reset
  net: usb: lan78xx: Utilize phy_ethtool_nway_reset

 drivers/net/ethernet/aurora/nb8800.c                  | 12 +-----------
 drivers/net/ethernet/broadcom/bcm63xx_enet.c          |  7 ++-----
 drivers/net/ethernet/broadcom/genet/bcmgenet.c        |  9 +--------
 drivers/net/ethernet/freescale/fec_main.c             | 12 +-----------
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c |  7 +------
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c     |  9 +--------
 drivers/net/ethernet/lantiq_etop.c                    |  8 +-------
 drivers/net/ethernet/marvell/mv643xx_eth.c            | 10 +---------
 drivers/net/ethernet/smsc/smsc911x.c                  |  7 +------
 drivers/net/ethernet/smsc/smsc9420.c                  | 10 +---------
 drivers/net/ethernet/xilinx/ll_temac_main.c           |  7 +------
 drivers/net/ethernet/xscale/ixp4xx_eth.c              |  7 +------
 drivers/net/phy/phy.c                                 | 11 +++++++++++
 drivers/net/usb/ax88172a.c                            | 10 +---------
 drivers/net/usb/lan78xx.c                             |  7 +------
 include/linux/phy.h                                   |  1 +
 16 files changed, 27 insertions(+), 107 deletions(-)

-- 
2.9.3
