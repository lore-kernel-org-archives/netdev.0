From: Wei Yongjun <weiyongjun1@huawei.com>
Subject: [PATCH net-next] net: bcmgenet: Avoid calling platform_device_put() twice in bcmgenet_mii_exit()
Date: Sat, 28 Oct 2017 05:05:46 +0000
Message-ID: <1509167146-93171-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, <netdev@vger.kernel.org>
To: Doug Berger <opendmb@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga06-in.huawei.com ([45.249.212.32]:36292 "EHLO huawei.com"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750950AbdJ1FCT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 01:02:19 -0400
Received: from DGGEMS404-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id 545DCAD10DD0C
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 13:02:05 +0800 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove platform_device_put() call after platform_device_unregister()
from function bcmgenet_mii_exit(), otherwise, we will call
platform_device_put() twice.

Fixes: 9a4e79697009 ("net: bcmgenet: utilize generic Broadcom UniMAC
MDIO controller driver")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index ba3fcfd..5333274 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -571,5 +571,4 @@ void bcmgenet_mii_exit(struct net_device *dev)
 		of_phy_deregister_fixed_link(dn);
 	of_node_put(priv->phy_dn);
 	platform_device_unregister(priv->mii_pdev);
-	platform_device_put(priv->mii_pdev);
 }
