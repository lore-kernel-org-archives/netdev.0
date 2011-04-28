From: David Decotigny <decot@google.com>
Subject: [PATCHv4 0/7] ethtool: generalize use of ethtool_cmd_speed API
Date: Wed, 27 Apr 2011 21:32:36 -0700
Message-ID: <1303965163-8198-1-git-send-email-decot__38671.1418549114$1303965279$gmane$org@google.com>
Cc: David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	mirq-linux@rere.qmqm.pl, Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyc
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:34619 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab1D1EdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 00:33:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Version 4 of the patch set. Fixes a potential bug appearing if patch 3
were to be applied without 4: pch_gbe hunk from patch 4 moved to patch
3. No other change wrt PATCHv3, all other patches should be equivalent
(only differences: subject/description typo updates).

Regards,

David Decotigny (7):
  ethtool: cosmetics: enforce const-ness in ethtool_cmd_speed
  ethtool: Call ethtool's get/set_settings callbacks with cleaned data
  ethtool: Use full 32 bit speed range in ethtool's set_settings
  ethtool: cosmetic: Use ethtool ethtool_cmd_speed API
  acenic: Fix using the specified speed when configuring NIC
  tulip/de2104x: don't report different speeds depending on port type
  net/igb/e1000/e1000e: more robust ethtool duplex/speed configuration

 arch/mips/txx9/generic/setup_tx4939.c   |   21 ++++++---------
 drivers/infiniband/hw/nes/nes_nic.c     |    4 +-
 drivers/net/3c509.c                     |    2 +-
 drivers/net/acenic.c                    |   12 ++++----
 drivers/net/arm/etherh.c                |    5 ++-
 drivers/net/arm/ks8695net.c             |    7 +++--
 drivers/net/atl1c/atl1c_ethtool.c       |    9 +++---
 drivers/net/atl1e/atl1e_ethtool.c       |    4 +-
 drivers/net/atlx/atl1.c                 |    9 +++---
 drivers/net/atlx/atl2.c                 |    4 +-
 drivers/net/b44.c                       |   13 +++++----
 drivers/net/bcm63xx_enet.c              |    3 +-
 drivers/net/benet/be_ethtool.c          |   16 ++++++------
 drivers/net/bna/bnad_ethtool.c          |    7 +++--
 drivers/net/bnx2.c                      |   19 ++++++-------
 drivers/net/cassini.c                   |   37 ++++++++++++++-------------
 drivers/net/chelsio/cxgb2.c             |   11 ++++---
 drivers/net/cxgb3/cxgb3_main.c          |   14 ++++++----
 drivers/net/cxgb4/cxgb4_main.c          |   14 ++++++----
 drivers/net/cxgb4vf/cxgb4vf_main.c      |    3 +-
 drivers/net/dl2k.c                      |   29 ++++++--------------
 drivers/net/e100.c                      |   10 ++++---
 drivers/net/e1000/e1000.h               |    2 +-
 drivers/net/e1000/e1000_ethtool.c       |   10 ++++---
 drivers/net/e1000/e1000_main.c          |   42 +++++++++++++++++-------------
 drivers/net/e1000e/ethtool.c            |   37 +++++++++++++++++---------
 drivers/net/eepro.c                     |    2 +-
 drivers/net/ehea/ehea_ethtool.c         |   23 +++++++++++++---
 drivers/net/enc28j60.c                  |    5 ++-
 drivers/net/enic/enic_main.c            |    4 +-
 drivers/net/ewrk3.c                     |    2 +-
 drivers/net/forcedeth.c                 |   25 +++++++++++-------
 drivers/net/ibmveth.c                   |    2 +-
 drivers/net/igb/igb.h                   |    2 +-
 drivers/net/igb/igb_ethtool.c           |   11 ++++---
 drivers/net/igb/igb_main.c              |   23 +++++++++++------
 drivers/net/igbvf/ethtool.c             |    8 +++---
 drivers/net/ixgb/ixgb_ethtool.c         |    7 +++--
 drivers/net/ixgbe/ixgbe_ethtool.c       |   11 ++++---
 drivers/net/ixgbevf/ethtool.c           |    8 +++--
 drivers/net/jme.c                       |    3 +-
 drivers/net/ksz884x.c                   |    9 +++---
 drivers/net/mdio.c                      |   23 +++++++++++------
 drivers/net/mii.c                       |   31 ++++++++++++++---------
 drivers/net/mlx4/en_ethtool.c           |    7 +++--
 drivers/net/mv643xx_eth.c               |    6 ++--
 drivers/net/myri10ge/myri10ge.c         |    2 +-
 drivers/net/natsemi.c                   |   11 ++++---
 drivers/net/netxen/netxen_nic_ethtool.c |   15 ++++++-----
 drivers/net/niu.c                       |    4 +-
 drivers/net/ns83820.c                   |    8 +++---
 drivers/net/pch_gbe/pch_gbe_ethtool.c   |   11 +++++---
 drivers/net/pch_gbe/pch_gbe_main.c      |    6 ++--
 drivers/net/pch_gbe/pch_gbe_phy.c       |    4 +-
 drivers/net/pcmcia/smc91c92_cs.c        |    6 ++--
 drivers/net/pcnet32.c                   |   16 ++++++------
 drivers/net/phy/phy.c                   |   12 +++++---
 drivers/net/ps3_gelic_net.c             |    8 +++---
 drivers/net/qla3xxx.c                   |    2 +-
 drivers/net/qlcnic/qlcnic_ethtool.c     |   12 ++++----
 drivers/net/qlge/qlge_ethtool.c         |    2 +-
 drivers/net/r8169.c                     |    5 ++-
 drivers/net/s2io.c                      |    6 ++--
 drivers/net/sc92031.c                   |    8 +++--
 drivers/net/sfc/ethtool.c               |    5 ++-
 drivers/net/sfc/mcdi_phy.c              |    6 ++--
 drivers/net/sfc/mdio_10g.c              |    4 +-
 drivers/net/sfc/tenxpress.c             |    2 +-
 drivers/net/skge.c                      |    7 +++--
 drivers/net/sky2.c                      |    9 +++---
 drivers/net/smc911x.c                   |    4 +-
 drivers/net/smc91x.c                    |    4 +-
 drivers/net/spider_net_ethtool.c        |    2 +-
 drivers/net/stmmac/stmmac_ethtool.c     |    5 +--
 drivers/net/sungem.c                    |   15 ++++++-----
 drivers/net/sunhme.c                    |   19 ++++++-------
 drivers/net/tehuti.c                    |    2 +-
 drivers/net/tg3.c                       |   13 +++++----
 drivers/net/tulip/de2104x.c             |    9 ++----
 drivers/net/tulip/uli526x.c             |    6 ++--
 drivers/net/tun.c                       |    2 +-
 drivers/net/typhoon.c                   |   19 +++++++------
 drivers/net/usb/asix.c                  |   28 +++++++++++---------
 drivers/net/usb/catc.c                  |    2 +-
 drivers/net/usb/dm9601.c                |    6 ++--
 drivers/net/usb/rtl8150.c               |   11 ++++---
 drivers/net/usb/smsc75xx.c              |    7 +++--
 drivers/net/usb/smsc95xx.c              |    7 +++--
 drivers/net/veth.c                      |    2 +-
 drivers/net/via-velocity.c              |   21 +++++++++------
 drivers/net/vmxnet3/vmxnet3_ethtool.c   |    4 +-
 drivers/net/vxge/vxge-ethtool.c         |    7 +++--
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c       |   11 +++++---
 drivers/scsi/fcoe/fcoe.c                |   11 +++++---
 include/linux/ethtool.h                 |   18 +++++++++---
 include/linux/netdevice.h               |    9 +-----
 include/rdma/ib_addr.h                  |   13 +++++----
 net/batman-adv/soft-interface.c         |    2 +-
 net/bridge/br_if.c                      |    4 +-
 net/core/dev.c                          |   24 +++++++++++++++++
 net/core/net-sysfs.c                    |   24 +++++++----------
 101 files changed, 578 insertions(+), 460 deletions(-)

-- 
1.7.3.1

>From 9e2d8a2e2d267acd8230b64a6ff0e1d9f2688037 Mon Sep 17 00:00:00 2001
From: David Decotigny <decot@google.com>
Date: Wed, 27 Apr 2011 17:52:34 -0700
Subject: [PATCHv3 0/7] ethtool: generalize use of ethtool_cmd_speed API
Organization: Google, Inc.

Hi,

Third version of the patch series ensuring ethtool_cmd::speed/_hi
fields are accessed using ethtool_cmd_speed/_set API. Thanks to Ben
and Stephen for their feedbacks that have been integrated here,
including some from Ben suggested in PATCHv1 and added here (intel GbE
drivers: last patch in the series).

Regards,

David Decotigny (7):
  ethtool: cosmetics: enforce const-ness in ethtool_cmd_speed
  ethtool: Call ethtool's get/set_settings callbacks with cleaned data
  ethtool: Use the full 32 bit speed range in ethtool's set_settings
  ethtool: cosmetic: Use ethtool ethtool_cmd_speed API
  acenic: Fix using the specified speed when configuring NIC
  tulip/de2104x: don't report different speeds depending on port type
  net/igb/e1000/e1000e: more robust ethtool duplex/speed configuration

 arch/mips/txx9/generic/setup_tx4939.c   |   21 ++++++---------
 drivers/infiniband/hw/nes/nes_nic.c     |    4 +-
 drivers/net/3c509.c                     |    2 +-
 drivers/net/acenic.c                    |   12 ++++----
 drivers/net/arm/etherh.c                |    5 ++-
 drivers/net/arm/ks8695net.c             |    7 +++--
 drivers/net/atl1c/atl1c_ethtool.c       |    9 +++---
 drivers/net/atl1e/atl1e_ethtool.c       |    4 +-
 drivers/net/atlx/atl1.c                 |    9 +++---
 drivers/net/atlx/atl2.c                 |    4 +-
 drivers/net/b44.c                       |   13 +++++----
 drivers/net/bcm63xx_enet.c              |    3 +-
 drivers/net/benet/be_ethtool.c          |   16 ++++++------
 drivers/net/bna/bnad_ethtool.c          |    7 +++--
 drivers/net/bnx2.c                      |   19 ++++++-------
 drivers/net/cassini.c                   |   37 ++++++++++++++-------------
 drivers/net/chelsio/cxgb2.c             |   11 ++++---
 drivers/net/cxgb3/cxgb3_main.c          |   14 ++++++----
 drivers/net/cxgb4/cxgb4_main.c          |   14 ++++++----
 drivers/net/cxgb4vf/cxgb4vf_main.c      |    3 +-
 drivers/net/dl2k.c                      |   29 ++++++--------------
 drivers/net/e100.c                      |   10 ++++---
 drivers/net/e1000/e1000.h               |    2 +-
 drivers/net/e1000/e1000_ethtool.c       |   10 ++++---
 drivers/net/e1000/e1000_main.c          |   42 +++++++++++++++++-------------
 drivers/net/e1000e/ethtool.c            |   37 +++++++++++++++++---------
 drivers/net/eepro.c                     |    2 +-
 drivers/net/ehea/ehea_ethtool.c         |   23 +++++++++++++---
 drivers/net/enc28j60.c                  |    5 ++-
 drivers/net/enic/enic_main.c            |    4 +-
 drivers/net/ewrk3.c                     |    2 +-
 drivers/net/forcedeth.c                 |   25 +++++++++++-------
 drivers/net/ibmveth.c                   |    2 +-
 drivers/net/igb/igb.h                   |    2 +-
 drivers/net/igb/igb_ethtool.c           |   11 ++++---
 drivers/net/igb/igb_main.c              |   23 +++++++++++------
 drivers/net/igbvf/ethtool.c             |    8 +++---
 drivers/net/ixgb/ixgb_ethtool.c         |    7 +++--
 drivers/net/ixgbe/ixgbe_ethtool.c       |   11 ++++---
 drivers/net/ixgbevf/ethtool.c           |    8 +++--
 drivers/net/jme.c                       |    3 +-
 drivers/net/ksz884x.c                   |    9 +++---
 drivers/net/mdio.c                      |   23 +++++++++++------
 drivers/net/mii.c                       |   31 ++++++++++++++---------
 drivers/net/mlx4/en_ethtool.c           |    7 +++--
 drivers/net/mv643xx_eth.c               |    6 ++--
 drivers/net/myri10ge/myri10ge.c         |    2 +-
 drivers/net/natsemi.c                   |   11 ++++---
 drivers/net/netxen/netxen_nic_ethtool.c |   15 ++++++-----
 drivers/net/niu.c                       |    4 +-
 drivers/net/ns83820.c                   |    8 +++---
 drivers/net/pch_gbe/pch_gbe_ethtool.c   |   11 +++++---
 drivers/net/pch_gbe/pch_gbe_main.c      |    6 ++--
 drivers/net/pch_gbe/pch_gbe_phy.c       |    4 +-
 drivers/net/pcmcia/smc91c92_cs.c        |    6 ++--
 drivers/net/pcnet32.c                   |   16 ++++++------
 drivers/net/phy/phy.c                   |   12 +++++---
 drivers/net/ps3_gelic_net.c             |    8 +++---
 drivers/net/qla3xxx.c                   |    2 +-
 drivers/net/qlcnic/qlcnic_ethtool.c     |   12 ++++----
 drivers/net/qlge/qlge_ethtool.c         |    2 +-
 drivers/net/r8169.c                     |    5 ++-
 drivers/net/s2io.c                      |    6 ++--
 drivers/net/sc92031.c                   |    8 +++--
 drivers/net/sfc/ethtool.c               |    5 ++-
 drivers/net/sfc/mcdi_phy.c              |    6 ++--
 drivers/net/sfc/mdio_10g.c              |    4 +-
 drivers/net/sfc/tenxpress.c             |    2 +-
 drivers/net/skge.c                      |    7 +++--
 drivers/net/sky2.c                      |    9 +++---
 drivers/net/smc911x.c                   |    4 +-
 drivers/net/smc91x.c                    |    4 +-
 drivers/net/spider_net_ethtool.c        |    2 +-
 drivers/net/stmmac/stmmac_ethtool.c     |    5 +--
 drivers/net/sungem.c                    |   15 ++++++-----
 drivers/net/sunhme.c                    |   19 ++++++-------
 drivers/net/tehuti.c                    |    2 +-
 drivers/net/tg3.c                       |   13 +++++----
 drivers/net/tulip/de2104x.c             |    9 ++----
 drivers/net/tulip/uli526x.c             |    6 ++--
 drivers/net/tun.c                       |    2 +-
 drivers/net/typhoon.c                   |   19 +++++++------
 drivers/net/usb/asix.c                  |   28 +++++++++++---------
 drivers/net/usb/catc.c                  |    2 +-
 drivers/net/usb/dm9601.c                |    6 ++--
 drivers/net/usb/rtl8150.c               |   11 ++++---
 drivers/net/usb/smsc75xx.c              |    7 +++--
 drivers/net/usb/smsc95xx.c              |    7 +++--
 drivers/net/veth.c                      |    2 +-
 drivers/net/via-velocity.c              |   21 +++++++++------
 drivers/net/vmxnet3/vmxnet3_ethtool.c   |    4 +-
 drivers/net/vxge/vxge-ethtool.c         |    7 +++--
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c       |   11 +++++---
 drivers/scsi/fcoe/fcoe.c                |   11 +++++---
 include/linux/ethtool.h                 |   18 +++++++++---
 include/linux/netdevice.h               |    9 +-----
 include/rdma/ib_addr.h                  |   13 +++++----
 net/batman-adv/soft-interface.c         |    2 +-
 net/bridge/br_if.c                      |    4 +-
 net/core/dev.c                          |   24 +++++++++++++++++
 net/core/net-sysfs.c                    |   24 +++++++----------
 101 files changed, 578 insertions(+), 460 deletions(-)

-- 
1.7.3.1

