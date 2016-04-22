From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 00/10] net: hns: add support of debug dsaf device
Date: Fri, 22 Apr 2016 15:20:09 +0800
Message-ID: <1461309619-167621-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<davem@davemloft.net>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <salil.mehta@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <linuxarm@huawei.com>
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:55440 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbcDVHDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 03:03:06 -0400
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



Daode Huang (3):
  net: hns: set debug port irq index to 0
  net: hns: add syscon operation for dsaf
  net: hns: sort the header file by alphabetical order

Yisen Zhuang (7):
  net: hns: add a new dsaf mode for debug port
  net: hns: add attribute port-idx-in-ae in enet node.
  net: hns: add attribute reset-field-offset for dsaf node
  net: hns: separate debug and service device from dsaf device
  net: hns: add attribute cpld_ctrl for dsaf port node
  net: hns: add attribute port-rst-offset for dsaf port node
  net: hns: add attribute port-mode-offset for dsaf port node

 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  59 +++++-
 .../devicetree/bindings/net/hisilicon-hns-nic.txt  |  30 ++-
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
 15 files changed, 580 insertions(+), 454 deletions(-)

-- 
1.9.1
