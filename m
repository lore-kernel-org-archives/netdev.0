From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH NEXT 5/6] netxen: Fix a panic during driver unload in device_remove_file
Date: Fri, 3 Feb 2012 13:35:14 -0800
Message-ID: <1328304915-12858-6-git-send-email-rajesh.borundia@qlogic.com>
References: <1328304915-12858-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>, <stable@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:27992
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757959Ab2BCVvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 16:51:11 -0500
In-Reply-To: <1328304915-12858-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Pass adapter->pdev->dev instead of netdev->dev

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index f517c16..8dc4a134 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -2930,13 +2930,12 @@ static struct bin_attribute bin_attr_mem = {
 static void
 netxen_create_sysfs_entries(struct netxen_adapter *adapter)
 {
-	struct net_device *netdev = adapter->netdev;
-	struct device *dev = &netdev->dev;
+	struct device *dev = &adapter->pdev->dev;
 
 	if (adapter->capabilities & NX_FW_CAPABILITY_BDG) {
 		/* bridged_mode control */
 		if (device_create_file(dev, &dev_attr_bridged_mode)) {
-			dev_warn(&netdev->dev,
+			dev_warn(dev,
 				"failed to create bridged_mode sysfs entry\n");
 		}
 	}
@@ -2945,8 +2944,7 @@ netxen_create_sysfs_entries(struct netxen_adapter *adapter)
 static void
 netxen_remove_sysfs_entries(struct netxen_adapter *adapter)
 {
-	struct net_device *netdev = adapter->netdev;
-	struct device *dev = &netdev->dev;
+	struct device *dev = &adapter->pdev->dev;
 
 	if (adapter->capabilities & NX_FW_CAPABILITY_BDG)
 		device_remove_file(dev, &dev_attr_bridged_mode);
-- 
1.7.3.3
