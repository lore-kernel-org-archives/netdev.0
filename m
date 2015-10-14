From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next] net: hisilicon net: fix a bug about led
Date: Wed, 14 Oct 2015 10:28:57 +0800
Message-ID: <1444789737-25428-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <liguozhu@huawei.com>, <yisen.zhuang@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<yankejian@huawei.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:21830 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbbJNCNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 22:13:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lipeng <lipeng321@huawei.com>

this patch fixes a bug in hns driver. the link led is on at the beginning,
but at this time the ethernet port is on down status. it needs to reset
the led status on init sequence.

Signed-off-by: lipeng <lipeng321@huawei.com>
Signed-off-by: yankejian <yankejian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 95bf42a..f8f7347 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -744,9 +744,11 @@ int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, int mac_idx)
 	mac_cb->serdes_vaddr = dsaf_dev->sds_base;
 
 	if (dsaf_dev->cpld_base &&
-	    mac_idx < DSAF_SERVICE_PORT_NUM_PER_DSAF)
+	    mac_idx < DSAF_SERVICE_PORT_NUM_PER_DSAF) {
 		mac_cb->cpld_vaddr = dsaf_dev->cpld_base +
 			mac_cb->mac_id * CPLD_ADDR_PORT_OFFSET;
+		cpld_led_reset(mac_cb);
+	}
 	mac_cb->sfp_prsnt = 0;
 	mac_cb->txpkt_for_led = 0;
 	mac_cb->rxpkt_for_led = 0;
-- 
1.9.1
