From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V7 net-next 0/5] net:hns: Add support of Hip06 SoC to the Hislicon Network Subsystem
Date: Thu, 3 Dec 2015 12:17:52 +0000
Message-ID: <1449145077-9400-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
	<liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>,
	<salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This PATCH V7 addresses the TAB formatting comments by 
Sergei Shtylyov. Missing TABs at some other palces have
also been corrected.
 
PATCH V6:
This addresses the review comments provided by
David Miller over the existing use of ENABLE/DISABLE
hash defines with the code. These hash defines are doing
a similar job as implicit type bool would do. So these are
kind of duplicate and are redundant.

PATCH V5:
This PATCH addresses the review comments by Yuval Mintz
 <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>. This rework of comments are basically
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
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  188 +++++---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  483 +++++++++++++++++---
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |   12 +
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |   95 +++-
 15 files changed, 1127 insertions(+), 256 deletions(-)

-- 
1.7.9.5


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
