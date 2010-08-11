From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 5/8] qlcnic: fix link status message
Date: Wed, 11 Aug 2010 05:05:26 -0700
Message-ID: <1281528329-8812-6-git-send-email-amit.salecha@qlogic.com>
References: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:64737 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751827Ab0HKMFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 08:05:30 -0400
In-Reply-To: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Display interface name for link status message.
With dev_info pci number get printed.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 96e8e75..7c9072d 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1934,14 +1934,16 @@ void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup)
 	struct net_device *netdev = adapter->netdev;
 
 	if (adapter->ahw.linkup && !linkup) {
-		dev_info(&netdev->dev, "NIC Link is down\n");
+		printk(KERN_INFO "%s: %s NIC Link is down\n",
+		       qlcnic_driver_name, netdev->name);
 		adapter->ahw.linkup = 0;
 		if (netif_running(netdev)) {
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 		}
 	} else if (!adapter->ahw.linkup && linkup) {
-		dev_info(&netdev->dev, "NIC Link is up\n");
+		printk(KERN_INFO "%s: %s NIC Link is up\n",
+		       qlcnic_driver_name, netdev->name);
 		adapter->ahw.linkup = 1;
 		if (netif_running(netdev)) {
 			netif_carrier_on(netdev);
-- 
1.6.0.2

