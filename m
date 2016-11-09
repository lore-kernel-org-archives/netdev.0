From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 15/17] net: hns: modify tcam table of mask_key
Date: Wed, 9 Nov 2016 18:13:59 +0000
Message-ID: <20161109181401.913728-16-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Qianqian Xie <xieqianqian@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:27924 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754772AbcKISP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:15:58 -0500
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

The packets of wrong mac address(only the last bit is different) can be
received in Big-endian by current definition of mask_key. Thus it needs
to be modified to support Big-endian and ensure Big-endian normal.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 74ca53d..250e4a1 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -1718,6 +1718,10 @@ int hns_dsaf_add_mac_mc_port(struct dsaf_device *dsaf_dev,
 				     0x0,
 				     0xff,
 				     mc_mask);
+
+		mask_key.high.val = le32_to_cpu(mask_key.high.val);
+		mask_key.low.val = le32_to_cpu(mask_key.low.val);
+
 		pmask_key = (struct dsaf_tbl_tcam_data *)(&mask_key);
 	}
 
@@ -1887,6 +1891,9 @@ int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
 		/* config key mask */
 		hns_dsaf_set_mac_key(dsaf_dev, &mask_key, 0x00, 0xff, mc_addr);
 
+		mask_key.high.val = le32_to_cpu(mask_key.high.val);
+		mask_key.low.val = le32_to_cpu(mask_key.low.val);
+
 		pmask_key = (struct dsaf_tbl_tcam_data *)(&mask_key);
 	}
 
-- 
1.7.9.5
