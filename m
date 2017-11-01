From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 0/9] net: hns3: add support for reset
Date: Wed, 1 Nov 2017 22:47:13 +0800
Message-ID: <1509547642-51110-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are 4 reset types for HNS3 PF driver, include global reset,
core reset, IMP reset, PF reset.The core reset will reset all datapath
of all functions except IMP, MAC and PCI interface. Global reset is equal
with the core reset plus all MAC reset. IMP reset is caused by watchdog
timer expiration, the same range with core reset. PF reset will reset
whole physical function. 

This patchset adds reset support for hns3 driver and fix some related bugs.

Lipeng (2):
  net: hns3: Add timeout process in hns3_enet
  net: hns3: Add reset interface implementation in client

qumingguang (7):
  net: hns3: Refactor the mapping of tqp to vport
  net: hns3: Refactor mac_init function
  net: hns3: Refactor the initialization of command queue
  net: hns3: Add support for misc interrupt
  net: hns3: Add reset process in hclge_main
  net: hns3: Fix a misuse to devm_free_irq
  net: hns3: hns3:fix a bug about statistic counter in reset process

 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  19 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c |  39 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  13 +
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 454 ++++++++++++++++++++-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |  18 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 244 ++++++++++-
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |   2 +
 7 files changed, 750 insertions(+), 39 deletions(-)

-- 
1.9.1
