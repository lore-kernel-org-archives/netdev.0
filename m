From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH V2 net 09/10] net: hns: adds limitation for debug port mtu
Date: Tue, 22 Mar 2016 16:06:30 +0800
Message-ID: <1458633991-64313-10-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<sergei.shtylyov@cogentembedded.com>, <xieqianqian@huawei.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:34751 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758255AbcCVHvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 03:51:46 -0400
In-Reply-To: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kejian Yan <yankejian@huawei.com>

If mtu for debug port is set more than 1500, it may cause that packets
are dropped by ppe. So maximum value for debug port should be 1500.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
change log:
 PATCH V2:
  - use tabs instead of spaces to indent the value

 PATCH V1:
  - first submit

  Link: https://lkml.org/lkml/2016/3/21/217
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 3 +++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h | 1 +
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 50237fb..a38084a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -470,6 +470,9 @@ int hns_mac_set_mtu(struct hns_mac_cb *mac_cb, u32 new_mtu)
 	u32 max_frm = AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver) ?
 			MAC_MAX_MTU : MAC_MAX_MTU_V2;
 
+	if (mac_cb->mac_type == HNAE_PORT_DEBUG)
+		max_frm = MAC_MAX_MTU_DBG;
+
 	if ((new_mtu < MAC_MIN_MTU) || (new_frm > max_frm) ||
 	    (new_frm > HNS_RCB_RING_MAX_BD_PER_PKT * buf_size))
 		return -EINVAL;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 7b47701..823b6e7 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -28,6 +28,7 @@ struct dsaf_device;
 #define MAC_MAX_MTU		9600
 #define MAC_MAX_MTU_V2		9728
 #define MAC_MIN_MTU		68
+#define MAC_MAX_MTU_DBG		MAC_DEFAULT_MTU
 
 #define MAC_DEFAULT_PAUSE_TIME 0xff
 
-- 
1.9.1
