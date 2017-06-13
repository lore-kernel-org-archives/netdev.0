From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 net-next 0/8] Hisilicon Network Subsystem 3 Ethernet Driver
Date: Wed, 14 Jun 2017 00:10:27 +0100
Message-ID: <20170613231035.494020-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
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
       [Ethernet Client]  [RoCE Client] . . . [ Ethernet Client ]     
    ---------------------------------------------     |
                         |                            |
     [ HNAE3 Framework (Register/unregister) ]        |
                         |                            |
    ---------------------------------------------     |
                   [ HNAE Device ]                    |
                         |                            |
                   [ HCLGE Layer]                     |
         ________________|_________________           |
        |                |                 |          |
    [ MDIO ]    [ Scheduler/Shaper ]  [ Debugfs ]     |
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
 4. Debugfs support 
 5. HNAE framework and hardware compatability layer
 6. Scheduler and Shaper support in transmit function
 7. MDIO support

Change Log:
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
 drivers/net/ethernet/hisilicon/Kconfig             |   24 +
 drivers/net/ethernet/hisilicon/Makefile            |    1 +
 drivers/net/ethernet/hisilicon/hns3/Makefile       |    7 +
 drivers/net/ethernet/hisilicon/hns3/hnae3.c        |  305 ++
 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  449 +++
 .../net/ethernet/hisilicon/hns3/hns3pf/Makefile    |   11 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c |  347 ++
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  743 ++++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 4255 ++++++++++++++++++++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |  495 +++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c    |  295 ++
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c  | 1018 +++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h  |  108 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2842 +++++++++++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  585 +++
 .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  |  894 ++++
 17 files changed, 12387 insertions(+)
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
2.7.4
