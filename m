From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: netcp: drop kfree for memory allocated with devm_kzalloc
Date: Sat, 22 Oct 2016 12:32:04 +0000
Message-ID: <1477139524-26359-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Wingman Kwok <w-kwok2@ti.com>,
        Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35365 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932718AbcJVMcM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 08:32:12 -0400
Received: by mail-pf0-f193.google.com with SMTP id s8so11274252pfj.2
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 05:32:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

It's not necessary to free memory allocated with devm_kzalloc in the
remove path and using kfree leads to a double free.

Fixes: 84640e27f230 ("net: netcp: Add Keystone NetCP core ethernet
driver")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/ti/netcp_core.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 11609d5..2fb5b6d 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -2058,7 +2058,6 @@ static void netcp_delete_interface(struct netcp_device *netcp_device,
 		if (module->release)
 			module->release(intf_modpriv->module_priv);
 		list_del(&intf_modpriv->intf_list);
-		kfree(intf_modpriv);
 	}
 	WARN(!list_empty(&netcp->module_head), "%s interface module list is not empty!\n",
 	     ndev->name);
@@ -2153,7 +2152,6 @@ static int netcp_remove(struct platform_device *pdev)
 		dev_dbg(&pdev->dev, "Removing module \"%s\"\n", module->name);
 		module->remove(netcp_device, inst_modpriv->module_priv);
 		list_del(&inst_modpriv->inst_list);
-		kfree(inst_modpriv);
 	}
 
 	/* now that all modules are removed, clean up the interfaces */
