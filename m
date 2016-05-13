From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [patch net-next 00/11] net: hns: add support of ACPI
Date: Fri, 13 May 2016 16:19:06 +0800
Message-ID: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arnd@arndb.de>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <rjw@rjwysocki.net>, <lenb@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

HNS driver needs to run only in ACPI case, so this series adds HNS
support of acpi. The routine will call some ACPI helper functions,
like acpi_match_device_ids() and acpi_evaluate_dsm(), which are not
included in other cases. In order to make system compile successfully
in other cases except ACPI, it needs to add relative stub functions to
linux/acpi.h.

Hanjun Guo (1):
  ACPI: bus: move acpi_match_device_ids() to linux/acpi.h

Kejian Yan (10):
  net: hisilicon: add support of acpi for hns-mdio
  net: hns: use device_* APIs instead of of_* APIs
  net: hns: use platform_get_irq instead of irq_of_parse_and_map
  net: hns: enet specify a reference to dsaf by fwnode_handle
  net: hns: add uniform interface for phy connection
  net: hns: dsaf adds support of acpi
  net: hns: register phy device in each mac initial sequence
  ACPI: bus: add stub acpi_evaluate_dsm() to linux/acpi.h
  net: hns: implement the reset sequence by asl
  net: hns: enet adds support of acpi

 drivers/net/ethernet/hisilicon/hns/hnae.c          |  18 +-
 drivers/net/ethernet/hisilicon/hns/hnae.h          |   5 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 221 +++++++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  95 ++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 372 ++++++++++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |   5 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 112 +++++--
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |   2 +-
 drivers/net/ethernet/hisilicon/hns_mdio.c          | 145 +++++---
 include/acpi/acpi_bus.h                            |   2 -
 include/linux/acpi.h                               |  19 ++
 14 files changed, 712 insertions(+), 290 deletions(-)

-- 
1.9.1
