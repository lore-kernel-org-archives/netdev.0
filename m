From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v3 net-next 00/13] net: hns: add support of ACPI
Date: Mon, 30 May 2016 20:34:11 +0800
Message-ID: <1464611664-93775-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

This series adds HNS support of acpi. The routine will call some ACPI
helper functions, like acpi_dev_found() and acpi_evaluate_dsm(), which
are not included in other cases. In order to make system compile
successfully in other cases except ACPI, it needs to add relative stub
functions to linux/acpi.h. And we use device property functions instead
of serial helper functions to suport both DT and ACPI cases. And then
add the supports of ACPI for HNS.

change log:
 v2->v3:
 1. add Review-by: Andy Shevchenko
 2. fix the potential memory leak

 v1 -> v2:
 1. use acpi_dev_found() instead of acpi_match_device_ids() to check if
it is a acpi node.
 2. use is_of_node() instead of IS_ENABLED() to check if it is a DT node.
 3. split the patch("add support of acpi for hns-mdio") into two patches:
    3.1 Move to use fwnode_handle
    3.2 Add ACPI
 4. add the patch which subject is dsaf misc operation method
 5. fix the comments by Andy Shevchenko

Kejian Yan (13):
  ACPI: bus: add stub acpi_dev_found() to linux/acpi.h
  ACPI: bus: add stub acpi_evaluate_dsm() to linux/acpi.h
  net: hisilicon: cleanup to prepare for other cases
  net: hisilicon: add support of acpi for hns-mdio
  net: hns: use device_* APIs instead of of_* APIs
  net: hns: use platform_get_irq instead of irq_of_parse_and_map
  net: hns: enet specify a reference to dsaf by fwnode_handle
  net: hns: add uniform interface for phy connection
  net: hns: add dsaf misc operation method
  net: hns: dsaf adds support of acpi
  net: hns: register phy device in each mac initial sequence
  net: hns: implement the miscellaneous operation by asl
  net: hns: net: hns: enet adds support of acpi

 drivers/net/ethernet/hisilicon/hns/hnae.c          |  18 +-
 drivers/net/ethernet/hisilicon/hns/hnae.h          |   5 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |   6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |   6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 247 +++++++++++++++-----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |   4 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 105 ++++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  33 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 254 ++++++++++++++++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h |   7 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  15 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |   5 +-
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c    |  10 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  90 +++++---
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |   2 +-
 drivers/net/ethernet/hisilicon/hns_mdio.c          | 147 +++++++-----
 include/linux/acpi.h                               |  13 ++
 18 files changed, 714 insertions(+), 255 deletions(-)

-- 
1.9.1
