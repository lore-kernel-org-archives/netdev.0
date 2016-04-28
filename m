From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 00/10] net: hns: add support of debug dsaf device
Date: Thu, 28 Apr 2016 15:01:32 +0800
Message-ID: <1461826902-51368-1-git-send-email-Yisen.Zhuang@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:46450 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbcD1GqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 02:46:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two kinds of dsaf device in hns, one is for service ports,
contains crossbar in it, can work under different mode. Another is for
debug port, only can work under single port mode. The current code only
declared a dsaf device for both service ports and debug ports.It is not so
readability. This patch separate it to three platform devices to make the
code simple and more readability.

all port in one platform device(old):
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

separate all ports to three platform(new):
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

I have tested this patchset on d02 board, it is compatible with the dts in
d02 board.

For more details, please see individual patches.

MBR.

Daode Huang (3):
  net: hns: set debug port irq index to 0
  net: hns: add syscon operation for dsaf
  net: hns: sort the header file by alphabetical order

Yisen Zhuang (6):
  net: hns: add attribute port-idx-in-ae in enet node.
  net: hns: add attribute reset-field-offset for dsaf node
  net: hns: separate debug dsaf device from service dsaf device
  net: hns: add attribute cpld_ctrl for dsaf port node
  net: hns: add attribute port-rst-offset for dsaf port node
  net: hns: add attribute port-mode-offset for dsaf port node

huangdaode (1):
  net: hns: add a new dsaf mode for debug port

 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  60 +++++-
 .../devicetree/bindings/net/hisilicon-hns-nic.txt  |  30 ++-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  73 ++-----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 231 ++++++++++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  12 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 141 ++++++++-----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  16 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 173 +++++++++------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  51 +----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h  |   1 -
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  | 187 +++++++----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  38 ++--
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  17 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |   3 +
 15 files changed, 584 insertions(+), 451 deletions(-)

-- 
1.9.1
