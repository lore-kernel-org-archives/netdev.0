From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V4 net-next 0/8] Hisilicon Network Subsystem 3 Ethernet Driver
Date: Sat, 22 Jul 2017 23:09:34 +0100
Message-ID: <20170722220942.78852-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch-set contains the support of the HNS3 (Hisilicon Network Subsystem 3)
Ethernet driver for hip08 family of SoCs and future upcoming SoCs.

Hisilicon's new hip08 SoCs have integrated ethernet based on PCI Express and
hence there was a need of new driver over the previous HNS driver which is 
already part of the Linux mainline. This new driver is NOT backward
compatible with HNS.

This current driver is meant to control the Physical Function and there would
soon be a support of a separate driver for Virtual Function once this base PF
driver has been accepted. Also, this driver is the ongoing development work and
HNS3 Ethernet driver would be incrementally enhanced with more new features.

High Level Architecture:

        [ Ethtool ]
	   ^  |
           |  | 
      [Ethernet Client]  [ODP/UIO Client] . . . [ RoCE Client ]     
                         |                            |
                   [ HNAE Device ]                    |
                         |                            |
    ---------------------------------------------     |
                         |                            |
     [ HNAE3 Framework (Register/unregister) ]        |
                         |                            |
    ---------------------------------------------     |
                         |                            |
                   [ HCLGE Layer]                     |
         ________________|_________________           |
        |                |                 |          |
    [ MDIO ]    [ Scheduler/Shaper ]  [ Debugfs* ]    |
        |                |                 |          |
        |________________|_________________|          |     
                         |                            |
             [ IMP command Interface ]                |
    ---------------------------------------------     |
              HIP08  H A R D W A R E                  *


Current patch-set broadly adds the support of the following PF functionality:
 1. Basic Rx and Tx functionality 
 2. TSO support
 3. Ethtool support
 4. * Debugfs support -> this patch for now has been taken off.
 5. HNAE framework and hardware compatability layer
 6. Scheduler and Shaper support in transmit function
 7. MDIO support

Change Log:
V3->V4: Addressed below comments:
        * Andrew Lunn: Various comments on MDIO, ethtool, ENET driver etc,
        * Stephen Hemminger: change access and updation to 64 but statistics
        * Bo You: some spelling mistakes and checkpatch.pl errors.
V2->V3: Addressed comments
        * Yuval Mintz: Removal of redundant userprio-to-tc code
        * Stephen Hemminger: Ethtool & interuupt enable
        * Andrew Lunn: On C45/C22 PHy support, HNAE, ethtool
        * Florian Fainelli: C45/C22 and phy_connect/attach
        * Intel kbuild errors
V1->V2: Addressed some comments by kbuild, Yuval MIntz, Andrew Lunn &
        Florian Fainelli in the following patches:
        * Add support of HNS3 Ethernet Driver for hip08 SoC
        * Add MDIO support to HNS3 Ethernet driver for hip08 SoC
        * Add support of debugfs interface to HNS3 driver

Salil Mehta (8):
  net: hns3: Add support of HNS3 Ethernet Driver for hip08 SoC
  net: hns3: Add support of the HNAE3 framework
  net: hns3: Add HNS3 IMP(Integrated Mgmt Proc) Cmd Interface Support
  net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support
  net: hns3: Add support of TX Scheduler & Shaper to HNS3 driver
  net: hns3: Add MDIO support to HNS3 Ethernet driver for hip08 SoC
  net: hns3: Add Ethtool support to HNS3 driver
  net: hns3: Add HNS3 driver to kernel build framework & MAINTAINERS

 MAINTAINERS                                        |    8 +
 drivers/net/ethernet/hisilicon/Kconfig             |   27 +
 drivers/net/ethernet/hisilicon/Makefile            |    1 +
 drivers/net/ethernet/hisilicon/hns3/Makefile       |    7 +
 drivers/net/ethernet/hisilicon/hns3/hnae3.c        |  319 ++
 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  449 +++
 .../net/ethernet/hisilicon/hns3/hns3pf/Makefile    |   11 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c |  347 ++
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  742 ++++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 4240 ++++++++++++++++++++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |  494 +++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c    |  230 ++
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c  | 1018 +++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h  |  108 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2894 +++++++++++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  598 +++
 .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  |  543 +++
 17 files changed, 12036 insertions(+)
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hnae3.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hnae3.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c

-- 
2.11.0
