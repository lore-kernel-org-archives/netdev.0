From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 3/3] netxen: ratelimit error prints
Date: Mon, 16 Feb 2009 01:18:51 -0800
Message-ID: <1234775931-18518-4-git-send-email-dhananjay@netxen.com>
References: <1234775931-18518-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:48980 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752238AbZBPJS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2009 04:18:57 -0500
In-Reply-To: <1234775931-18518-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If for some reason, read from card memory fails the console
get flooded with failure prints. This patch confines print
under printk_ratelimit().

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 81f55e1..b2f67b9 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1579,8 +1579,9 @@ netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
 		}
 
 		if (j >= MAX_CTL_CHECK) {
-			printk("%s: %s Fail to write through agent\n",
-					__func__, netxen_nic_driver_name);
+			if (printk_ratelimit())
+				dev_err(&adapter->pdev->dev,
+					"failed to write through agent\n");
 			ret = -1;
 			break;
 		}
@@ -1637,8 +1638,9 @@ netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
 		}
 
 		if (j >= MAX_CTL_CHECK) {
-			printk(KERN_ERR "%s: %s Fail to read through agent\n",
-					__func__, netxen_nic_driver_name);
+			if (printk_ratelimit())
+				dev_err(&adapter->pdev->dev,
+					"failed to read through agent\n");
 			break;
 		}
 
@@ -1773,8 +1775,9 @@ netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 		}
 
 		if (j >= MAX_CTL_CHECK) {
-			printk(KERN_ERR "%s: Fail to write through agent\n",
-					netxen_nic_driver_name);
+			if (printk_ratelimit())
+				dev_err(&adapter->pdev->dev,
+					"failed to write through agent\n");
 			ret = -1;
 			break;
 		}
@@ -1843,8 +1846,9 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 		}
 
 		if (j >= MAX_CTL_CHECK) {
-			printk(KERN_ERR "%s: Fail to read through agent\n",
-					netxen_nic_driver_name);
+			if (printk_ratelimit())
+				dev_err(&adapter->pdev->dev,
+					"failed to read through agent\n");
 			break;
 		}
 
-- 
1.6.0.2

