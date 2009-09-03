From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 2/3] netxen: remove duplicate napi_add
Date: Thu,  3 Sep 2009 16:10:54 -0700
Message-ID: <1252019455-30683-2-git-send-email-dhananjay@netxen.com>
References: <1252019455-30683-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:12131 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S932467AbZICXKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 19:10:55 -0400
In-Reply-To: <1252019455-30683-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicate calls to netxen_napi_add().

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f824a39..53d57dc 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1095,10 +1095,6 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 
 	netdev->irq = adapter->msix_entries[0].vector;
 
-	err = netxen_napi_add(adapter, netdev);
-	if (err)
-		return err;
-
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &netxen_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
@@ -2038,8 +2034,6 @@ netxen_remove_sysfs_entries(struct netxen_adapter *adapter)
 		device_remove_file(dev, &dev_attr_bridged_mode);
 }
 
-static void netxen_watchdog(unsigned long);
-
 #ifdef CONFIG_INET
 
 #define is_netxen_netdev(dev) (dev->netdev_ops == &netxen_netdev_ops)
-- 
1.6.0.2

