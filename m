From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT] netxen: fix CONFIG_INET=n build
Date: Tue, 28 Jul 2009 12:10:03 -0700
Message-ID: <1248808203-9578-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, randy.dunlap@oracle.com,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:58294 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750743AbZG1TKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2009 15:10:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrap dest IP hashing code with #ifdef CONFIG_INET,
this feature makes no sense without INET, but other
driver can still work.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2bbefa6..40549a0 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1875,6 +1875,8 @@ static void netxen_nic_poll_controller(struct net_device *netdev)
 }
 #endif
 
+#ifdef CONFIG_INET
+
 #define is_netxen_netdev(dev) (dev->netdev_ops == &netxen_netdev_ops)
 
 static int
@@ -1993,6 +1995,7 @@ static struct notifier_block	netxen_netdev_cb = {
 static struct notifier_block netxen_inetaddr_cb = {
 	.notifier_call = netxen_inetaddr_event,
 };
+#endif
 
 static struct pci_driver netxen_driver = {
 	.name = netxen_nic_driver_name,
@@ -2012,8 +2015,10 @@ static int __init netxen_init_module(void)
 	if ((netxen_workq = create_singlethread_workqueue("netxen")) == NULL)
 		return -ENOMEM;
 
+#ifdef CONFIG_INET
 	register_netdevice_notifier(&netxen_netdev_cb);
 	register_inetaddr_notifier(&netxen_inetaddr_cb);
+#endif
 
 	return pci_register_driver(&netxen_driver);
 }
@@ -2024,8 +2029,10 @@ static void __exit netxen_exit_module(void)
 {
 	pci_unregister_driver(&netxen_driver);
 
+#ifdef CONFIG_INET
 	unregister_inetaddr_notifier(&netxen_inetaddr_cb);
 	unregister_netdevice_notifier(&netxen_netdev_cb);
+#endif
 	destroy_workqueue(netxen_workq);
 }
 
-- 
1.6.0.2

