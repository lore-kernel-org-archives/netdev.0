From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the Hisilicon RoCE Driver
Date: Wed, 24 Aug 2016 04:44:48 +0800
Message-ID: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>
To: <dledford@redhat.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is meant to add support of ACPI to the Hisilicon RoCE driver.
Following changes have been made in the driver(s):

Patch 1/2: HNS Ethernet Driver: changes to support ACPI have been done in
   the RoCE reset function part of the HNS ethernet driver. Earlier it only
   supported DT/syscon.

Patch 2/2. HNS RoCE driver: changes done in RoCE driver are meant to detect
   the type and then either use DT specific or ACPI spcific functions. Where
   ever possible, this patch tries to make use of "Unified Device Property
   Interface" APIs to support both DT and ACPI through single interface.

NOTE 1: ACPI changes done in both of the drivers depend upon the ACPI Table
     (DSDT and IORT tables) changes part of UEFI/BIOS. These changes are NOT
     part of this patch-set.
NOTE 2: Reset function in Patch 1/2 depends upon the reset function added in
     ACPI tables(basically DSDT table) part of the UEFI/BIOS. Again, this
     change is NOT reflected in this patch-set.

Salil Mehta (2):
  net: hns: Add support of ACPI to HNS driver RoCE Reset function
  IB/hns: Add support of ACPI to the Hisilicon RoCE driver

 drivers/infiniband/hw/hns/hns_roce_device.h        |    2 +-
 drivers/infiniband/hw/hns/hns_roce_eq.c            |    2 +-
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c         |   37 ++++--
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h         |    2 +-
 drivers/infiniband/hw/hns/hns_roce_main.c          |  127 ++++++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |   17 +--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   47 ++++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |    9 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |   53 +++++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h |    3 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |    4 +-
 11 files changed, 228 insertions(+), 75 deletions(-)

-- 
1.7.9.5
