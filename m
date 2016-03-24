From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 2/7] net: hns: optimizate fmt of snprintf()
Date: Thu, 24 Mar 2016 19:08:01 +0800
Message-ID: <1458817686-159708-3-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:41730 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755550AbcCXKta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 06:49:30 -0400
In-Reply-To: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

It misses string format in function snprintf(), as below:
snprintf(buff, ETH_GSTRING_LEN, g_gmac_stats_string[i].desc);

It needs to add "%s" to fix it as below:
snprintf(buff, ETH_GSTRING_LEN, "%s", g_gmac_stats_string[i].desc);

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 6e2b76e..44abb08 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -664,7 +664,8 @@ static void hns_gmac_get_strings(u32 stringset, u8 *data)
 		return;
 
 	for (i = 0; i < ARRAY_SIZE(g_gmac_stats_string); i++) {
-		snprintf(buff, ETH_GSTRING_LEN, g_gmac_stats_string[i].desc);
+		snprintf(buff, ETH_GSTRING_LEN, "%s",
+			 g_gmac_stats_string[i].desc);
 		buff = buff + ETH_GSTRING_LEN;
 	}
 }
-- 
1.9.1
