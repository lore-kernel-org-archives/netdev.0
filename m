From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH v2 net-next 00/10] Add support for DCB feature in hns3 driver
Date: Tue, 26 Sep 2017 10:25:08 +0800
Message-ID: <1506392718-50463-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patchset contains some enhancement related to DCB before
adding support for DCB feature.

This patchset depends on the following patchset:
https://patchwork.ozlabs.org/cover/815646/
https://patchwork.ozlabs.org/cover/816145/

High Level Architecture:

       [ tc qdisc ]	       [ lldpad ]
             |                     |
             |                     |
             |                     |
       [ hns3_enet ]        [ hns3_dcbnl ]
             \                    /
                \              /
                   \        /
                 [ hclge_dcb ]
                   /      \
                /            \
             /                  \
     [ hclge_main ]        [ hclge_tm ]

Current patch-set support following functionality:
1. Use of tc qdisc to configure the tc num and prio_tc_map.
2. Use of lldptool to configure the tc schedule mode, tc
   bandwidth(if schedule mode is ETS), prio_tc_map and
   PFC parameter.

---
V2: Fix for not defining variables in local loop.

V1: Initial Submit.

Yunsheng Lin (10):
  net: hns3: Support for dynamically assigning tx buffer to TC
  net: hns3: Add support for dynamically buffer reallocation
  net: hns3: Add support for PFC setting in TM module
  net: hns3: Add support for port shaper setting in TM module
  net: hns3: Add tc-based TM support for sriov enabled port
  net: hns3: Add some interface for the support of DCB feature
  net: hns3: Add hclge_dcb module for the support of DCB feature
  net: hns3: Add dcb netlink interface for the support of DCB feature
  net: hns3: Setting for fc_mode and dcb enable flag in TM module
  net: hns3: Add mqprio support when interacting with network stack

 drivers/net/ethernet/hisilicon/Kconfig             |   9 +
 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  20 ++
 .../net/ethernet/hisilicon/hns3/hns3pf/Makefile    |   4 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |   6 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.c | 327 +++++++++++++++++++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.h |  21 ++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 214 +++++++++-----
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |   8 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c  | 231 +++++++++++++--
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h  |  15 +
 .../ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c    | 106 +++++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 137 +++++++--
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |   7 +
 13 files changed, 977 insertions(+), 128 deletions(-)
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c

-- 
1.9.1
