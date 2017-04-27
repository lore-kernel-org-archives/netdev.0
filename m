From: Yankejian <yankejian@huawei.com>
Subject: [PATCH net v4 0/3] net: hns: bug fix for HNS driver
Date: Thu, 27 Apr 2017 10:44:10 +0800
Message-ID: <1493261053-68197-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <salil.mehta@huawei.com>,
        <yisen.zhuang@huawei.com>, <matthias.bgg@gmail.com>,
        <yankejian@huawei.com>, <lipeng321@huawei.com>,
        <zhouhuiru@huawei.com>, <huangdaode@hisilicon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:5806 "EHLO
        dggrg01-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1033568AbdD0CYU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 22:24:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lipeng <lipeng321@huawei.com>

The first two patches [1/3] [2/3] of this serie add support defered
dsaf probe when mdio and mbigen module is not insmod. The third
patch [3/3] fixes a bug that skb still be used after freed, which will
cuase panic.

For more details, please refer to individual patch.

change log:
V3 -> V4:
1. Delete redundant commit message;
2. add Reviewed-by: Matthias Brugger <mbrugger@suse.com>;

V2 -> V3:
1. Check return value when  platform_get_irq in hns_rcb_get_cfg;

V1 -> V2:
1. Return appropriate errno in hns_mac_register_phy;

lipeng (3):
  net: hns: support deferred probe when can not obtain irq
  net: hns: support deferred probe when no mdio
  net: hns: fixed bug that skb used after kfree

 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 39 +++++++++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |  4 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c |  8 ++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c     | 22 ++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_enet.h     |  6 ++--
 6 files changed, 57 insertions(+), 24 deletions(-)

-- 
1.9.1
