From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V6 net-next 0/5] net:hns: Add support of Hip06 SoC to the Hislicon Network Subsystem
Date: Wed, 2 Dec 2015 16:52:46 +0000
Message-ID: <1449075171-4820-1-git-send-email-salil.mehta@huawei.com>
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

This PATCH V6 addresses the review comments provided by
David Miller over the existing use of ENABLE/DISABLE
hash defines with the code. These hash defines are doing
a similar job as implicit type bool would do. So these are
kind of duplicate and are redundant.

PATCH V5:
This PATCH addresses the review comments by Yuval Mintz
 <Yuval.Mintz@qlogic.com>. This rework of comments are basically
 related to:
 1) styling of the code,
 2) RSS default Key initiailization related code
 3) redundant code removal 

PATCH V4:
This addresses the review comment provided by 
Sergei Shtylyov. The changelog of every patch has also
been modified.

PATCH V3:
 Addresses the review comment floated by David Miller 

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

 drivers/net/ethernet/hisilicon/hns/hnae.h          |   58 ++-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |   98 +++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |   14 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |    4 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  213 +++++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |   24 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |    6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |   72 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h  |   32 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |   76 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |    8 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   88 +++-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  483 +++++++++++++++++---
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |   12 +
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |   95 +++-
 15 files changed, 1077 insertions(+), 206 deletions(-)

-- 
1.7.9.5
