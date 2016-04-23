From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v2 net-next 00/13] net: hns: add support of debug dsaf device
Date: Sat, 23 Apr 2016 17:05:04 +0800
Message-ID: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<davem@davemloft.net>, <will.deacon@arm.com>,
	<catalin.marinas@arm.com>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <salil.mehta@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <xuwei5@hisilicon.com>,
	<linuxarm@huawei.com>
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:47085 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbcDWIsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 04:48:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two kinds of dsaf device in hns, one is for service ports,
contains crossbar in it, can work under different mode. Another is for
debug port, only can work under single port mode. The current code only
declares a dsaf device for both service ports and debug ports.It is not so
readability. This patch separates it to three platform devices to make the
code more simple and readability.

The diagram of all port in one platform device(old):
                                        CPU
                                         |
                                         |        DSAF(one platform device)
    --------------------------------------------------------------      /
    |                           |                  |      |      |     /
    |                          PPE                PPE    PPE     |    /
    |                           |                  |      |      |   /
    |                           |                  |      |      |  /
    |                        crossbar              |      |      | /
    |                           |                  |      |      |/
    |    -----------------------------------       |      |      |
    |    |      |      |      |      |      |      |      |      |
    |    |      |      |      |      |      |      |      |      |
    |   MAC    MAC    MAC    MAC    MAC    MAC    MAC    MAC     |
    |    |      |      |      |      |      |      |      |      |
    --------------------------------------------------------------
         |      |      |      |      |      |      |      |
        PHY    PHY    PHY    PHY    PHY    PHY    PHY    PHY

The diagram of separating ports to three platform(new):
                                                         CPU
                                                          |
                                    -----------------------------------
                                    |                     |           |
    ----------------------------------------------    ---------   ---------
    |                         |                  |    |       |   |   |   |
    |                        PPE                 |    |  PPE  |   |  PPE  |
    |                         |                  |    |   |   |   |   |   |
    |                         |                  |    |   |   |   |   |   |
    |                      crossbar              |    |   |   |   |   |   |
    |                         |                  |    |   |   |   |   |   |
    |   ----------------------------------       |    |   |   |   |   |   |
    |   |     |     |      |      |      |       |    |   |   |   |   |   |
    |   |     |     |      |      |      |       |    |   |   |   |   |   |
    |  MAC   MAC   MAC    MAC    MAC    MAC      |    |  MAC  |   |  MAC  |
    |   |     |     |      |      |      |       |    |   |   |   |   |   |
    ----------------------------------------------    ---------   ---------
        |     |     |      |      |      |    \        /  |        /  |
       PHY   PHY   PHY    PHY    PHY    PHY    \      /  PHY      /  PHY
                                                \    /           /
                                                 \  /           /
                                             DSAF(three platform device)

We take the compatibility into consideration, and it works well by using the
old dts file(tested on d02 board).

For more details, please see individual patches.

MBR.

---
change log:
 Series V2:
  - 1) put DT bindings in separate patches(patch 11 and 12).
    2) add modification of hns dts(patch 13).

 Series V1:
  - first submit

Daode Huang (2):
  net: hns: set debug port irq index to 0
  net: hns: sort the header file by alphabetical order

Yisen Zhuang (11):
  net: hns: add a new dsaf mode for debug port
  net: hns: add attribute port-idx-in-ae in enet node.
  net: hns: add attribute reset-field-offset for dsaf node
  net: hns: add syscon operation for dsaf
  net: hns: separate debug dsaf device from service dsaf device
  net: hns: add attribute cpld_ctrl for dsaf port node
  net: hns: add attribute port-rst-offset for dsaf port node
  net: hns: add attribute port-mode-offset for dsaf port node
  Documentation: Bindings: Update DT binding for separating dsaf dev
    support
  Documentation: Bindings: add port-idx-in-ae for enet node
  dts: hisi: update hns dst for separating dsaf dev support

 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  59 +++++-
 .../devicetree/bindings/net/hisilicon-hns-nic.txt  |  30 ++-
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi       |  72 +++----
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  73 ++-----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 230 ++++++++++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  12 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 134 +++++++-----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  16 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 171 +++++++++------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  61 ++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h  |   1 -
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  | 187 +++++++----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  38 ++--
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  17 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |   3 +
 16 files changed, 610 insertions(+), 496 deletions(-)

-- 
1.9.1
