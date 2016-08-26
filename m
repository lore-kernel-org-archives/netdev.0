From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: ethernet: ti: cpsw: fix error return code in cpsw_set_channels()
Date: Fri, 26 Aug 2016 14:35:43 +0000
Message-ID: <1472222143-3604-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36769 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752176AbcHZOv2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 10:51:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return a negative error code from the cpsw_fill_rx_channels()
error handling case instead of 0, as done elsewhere in this function.

Fixes: ce52c744574b ("net: ethernet: ti: cpsw: add ethtool channels support")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/ti/cpsw.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 4273e7f..c6cff3d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2217,7 +2217,8 @@ static int cpsw_set_channels(struct net_device *ndev,
 	}
 
 	if (cpsw_common_res_usage_state(cpsw)) {
-		if (cpsw_fill_rx_channels(priv))
+		ret = cpsw_fill_rx_channels(priv);
+		if (ret)
 			goto err;
 
 		/* After this receive is started */
