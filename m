From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] drivers: net: xgene-v2: Fix error return code in xge_mdio_config()
Date: Tue, 25 Apr 2017 11:36:50 +0000
Message-ID: <20170425113650.22730-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Iyappan Subramanian <isubramanian@apm.com>,
        Keyur Chudgar <kchudgar@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36340 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1946890AbdDYLg5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 07:36:57 -0400
Received: by mail-pg0-f67.google.com with SMTP id v1so3355880pgv.3
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 04:36:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return error code -ENODEV from the no PHY found error
handling case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/apm/xgene-v2/mdio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/apm/xgene-v2/mdio.c b/drivers/net/ethernet/apm/xgene-v2/mdio.c
index a583c6a..f5fe3bb 100644
--- a/drivers/net/ethernet/apm/xgene-v2/mdio.c
+++ b/drivers/net/ethernet/apm/xgene-v2/mdio.c
@@ -135,6 +135,7 @@ int xge_mdio_config(struct net_device *ndev)
 	phydev = phy_find_first(mdio_bus);
 	if (!phydev) {
 		dev_err(dev, "no PHY found\n");
+		ret = -ENODEV;
 		goto err;
 	}
 	phydev = phy_connect(ndev, phydev_name(phydev),
