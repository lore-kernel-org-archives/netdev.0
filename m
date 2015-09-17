From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH v2 0/5] net: Hisilicon Network Subsystem support
Date: Thu, 17 Sep 2015 14:51:45 +0800
Message-ID: <1442472710-20909-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<davem@davemloft.net>, <paul.gortmaker@windriver.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is V2 of Hisilicon Network Subsystem(HNS) patchesets taking care
about LKML comments.

Please find out the changes from the change logs. 
This patchset is rebased on mainline kernel Linux 4.3-rc1 branch.

[PATCH v2 1/5] Device Tree Binding Documentation
[PATCH v2 2/5] Merge MDIO Module
[PATCH v2 3/5] Hisilicon Network Acceleration Engine Framework
[PATCH v2 4/5] Distributed System Area Fabric Module
[PATCH v2 5/5] Basic Ethernet Driver Module

Changes from V1:
1. Remove "inline" in C file (according to LKML comment, same in below).
2. Fix a bug about class_find_device.
3. Change the DTS pattern on hnae, restruct it to compatible with Hi1610 soc.
4. Unified hip04_mdio and hip05_mdio into hns_mdio, which is more usaul for 
   later SOCs.

V1 Patches Reference: https://lkml.org/lkml/2015/8/14/165

Thanks

huangdaode (5):
  net: add Hisilicon Network Subsystem support (config and documents)
  net: add Hisilicon Network Subsystem MDIO support
  net: add Hisilicon Network Subsystem hnae framework support
  net: add Hisilicon Network Subsystem DSAF support
  net: add Hisilicon Network Subsystem basic ethernet support

 .../bindings/net/hisilicon-hip04-net.txt           |    4 +-
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |   49 +
 .../devicetree/bindings/net/hisilicon-hns-mdio.txt |   22 +
 .../devicetree/bindings/net/hisilicon-hns-nic.txt  |   47 +
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi       |  193 ++
 drivers/net/ethernet/hisilicon/Kconfig             |   34 +-
 drivers/net/ethernet/hisilicon/Makefile            |    4 +-
 drivers/net/ethernet/hisilicon/hip04_mdio.c        |  185 --
 drivers/net/ethernet/hisilicon/hns/Makefile        |   12 +
 drivers/net/ethernet/hisilicon/hns/hnae.c          |  507 ++++
 drivers/net/ethernet/hisilicon/hns/hnae.h          |  583 +++++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  777 +++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |  704 ++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.h |   45 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  900 +++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  456 ++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 2445 ++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  427 ++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |  317 +++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h |   43 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  583 +++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h  |  105 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  | 1023 ++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |  137 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  972 ++++++++
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c    |  836 +++++++
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h    |   15 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 1646 +++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |   84 +
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   | 1230 ++++++++++
 drivers/net/ethernet/hisilicon/hns_mdio.c          |  520 +++++
 31 files changed, 14716 insertions(+), 189 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
 create mode 100644 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
 delete mode 100644 drivers/net/ethernet/hisilicon/hip04_mdio.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hnae.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hnae.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_enet.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_enet.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns_mdio.c

-- 
1.9.1
