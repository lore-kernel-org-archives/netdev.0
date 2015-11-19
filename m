From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 net-next 0/5] net:hns: Add support of Hip06 SoC to the Hislicon Network Subsystem
Date: Fri, 20 Nov 2015 04:58:21 +0800
Message-ID: <1447966706-16219-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <paul.gortmaker@windriver.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>, <arnd@arndb.de>,
	<liguozhu@hisilicon.com>, <yisen.zhuang@huawei.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<salil.mehta@huawei.com>, <mehta.salil.lnk@gmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This PATCH V3 addresses the comment floated by David Miller and
has been created over PATCH V2 sent earlier. 

PATCH V2:
1) Bug Fixes and Clean-up: Internally identified
2) Addresses internal review comments by Kenneth Lee and
   by Huang Daode
3) Addresses the review comment from "Yisen.Zhuang(Zhuangyuzeng)"
4) Adds fix from Fengguang Wu for an error generated from 
   "kbuild test robot" from Intel
5) Ethtool support for TSO set option from Lisheng

PATCH V1:
Adds initial support of Hip06 SoC with below changes:  
This patch-set adds support of new Hisilicon Hip06 SoC to the existing
(already part of net-next) HNS ethernet driver for Hip05 SoC. Hip06 is
a multi-core SoC and is a derivative of Hip05 SoC with lots of new
hardware featres supported like RSS, TSO, hardware VLAN assist etc. 

The changes in the driver are mainly due to following:
 1) changes in the DMA descriptor provided by the Hip06 ethernet 
    hardware. These changes need to co-exist with already present
    Hip05 DMA descriptor and its operating functions. The decision
    to choose the correct type of DMA descriptor is taken dynamically
    depending upon the version of the hardware (i.e. V1/hip05 or
    V2/hip06, see already existing hisilicon-hns-nic.txt binding file
    for the detailed description version and naming).
 2) To support new features added to the Hip06 ethernet hardware:
    a. RSS (Receive Side Scaling)
    b. TSO (TCP Segment Offload)
    c. Hardware VLAN support (currently we are initializing hardware
       to not assist in stripping the vlan tag at hardware level.
       Proper support of this feature and ethtool would come after
       these patches have been accepted)

Kindly note that, this patchset has been based on latest net-next.

Salil Mehta (5):
  net:hns: Add support of Hip06 SoC to the Hislicon Network Subsystem
  net:hns: Add Hip06 "RSS(Receive Side Scaling)" support to HNS Driver
  net:hns: Add Hip06 "TSO(TCP Segment Offload)" support HNS Driver
  net:hns: Add support of ethtool TSO set option for Hip06 in HNS
  net:hns: Add the init code to disable Hip06 "Hardware VLAN assist"

 drivers/net/ethernet/hisilicon/hns/hnae.h          |   56 ++-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |   90 +++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  213 +++++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |   25 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |    6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |   79 +++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h  |   32 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |   68 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |    8 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   88 +++-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  487 +++++++++++++++++---
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |   12 +
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |   95 +++-
 13 files changed, 1072 insertions(+), 187 deletions(-)

-- 
1.7.9.5
