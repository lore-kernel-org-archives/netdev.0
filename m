From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 00/19] net: hns: fix some bugs in hns driver
Date: Tue, 21 Jun 2016 11:56:20 +0800
Message-ID: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <yankejian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:42932 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbcFUDiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 23:38:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series includes some bugs fixed. All these patches needs to be
applied after the patchset about ACPI support, so this series is 
floated to net-next list.

The patches are:
 > from Daode, fixes about pfc pause frame, getting coaslesce, led 
control logic, TSO on|off and tcam table configuration.

 > from Jun He, fix the potential leak to port unavailable

 > from Kejian, fix bug of loopback and failing to test ping6

 > from Qianqian, fix the several typo in hns driver

For more details, please see individual patches.

MBR.

Daode Huang (9):
  net: hns: bugfix about pfc pause frame statistics
  net: hns: add spin lock for tcam table operation
  net: hns: fix bug of getting the wrong tcam data
  net: hns: add get_coalesce_range api for hns
  net: hns: delete redundancy ring enable operations
  net: hns: bug fix about led control logic when link down
  net: hns: fix sbm default parameters config error
  net: hns: change the default coalesce usecs
  net: hns: bug fix about TSO on|off when there is traffic

Jun He (1):
  net: hns: fix bug that alloc skb fail lead to port unavailable

Kejian Yan (3):
  net: hns: add skb_reset_mac_header() after skb being alloc
  net: hns: select Hilink before serdes loopback for HNS V2
  net: hns: fix ethtool loopback fail bug

Qianqian Xie (6):
  net: hns: bug fix of ge reset sequence
  net: hns: fix hns dsaf v1 dont support tx_pause close
  net: hns: typo fix of annotation info for hns_nic_reset_subtask()
  net: hns: Remove unnecessary device resource free
  net: hns: fix the error info when dma_set_mask_and_coherent fail
  net: hns: fix the wrong speed for bond

 drivers/net/ethernet/hisilicon/hns/hnae.c          |   1 -
 drivers/net/ethernet/hisilicon/hns/hnae.h          |   6 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  53 ++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 190 ++++++++++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  12 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |  44 +++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  21 ++-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  68 ++++----
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |  47 ++---
 11 files changed, 291 insertions(+), 155 deletions(-)

-- 
1.9.1
