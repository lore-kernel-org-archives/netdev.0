From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: netcp: add missing of_node_put() in netcp_probe()
Date: Sat, 22 Oct 2016 14:40:17 +0000
Message-ID: <1477147217-3271-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Wingman Kwok <w-kwok2@ti.com>,
        Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33203 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936000AbcJVOkZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 10:40:25 -0400
Received: by mail-pf0-f196.google.com with SMTP id i85so11516946pfa.0
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 07:40:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

This node pointer is returned by of_get_child_by_name() with refcount
incremented in this function. of_node_put() on it before exitting this
function.

This is detected by Coccinelle semantic patch.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/ti/netcp_core.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 11609d5..eaa68bc 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -2121,6 +2121,8 @@ static int netcp_probe(struct platform_device *pdev)
 		}
 	}
 
+	of_node_put(interfaces);
+
 	/* Add the device instance to the list */
 	list_add_tail(&netcp_device->device_list, &netcp_devices);
 
@@ -2133,6 +2135,8 @@ static int netcp_probe(struct platform_device *pdev)
 		netcp_delete_interface(netcp_device, netcp_intf->ndev);
 	}
 
+	of_node_put(interfaces);
+
 probe_quit:
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
