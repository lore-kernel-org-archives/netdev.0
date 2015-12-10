From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 2/2] net:hns: print MAC with %pM
Date: Thu, 10 Dec 2015 17:23:10 +0200
Message-ID: <1449760990-111046-2-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1449760990-111046-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	huangdaode <huangdaode@hisilicon.com>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7410 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259AbbLJPXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 10:23:15 -0500
In-Reply-To: <1449760990-111046-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

printf() has a dedicated specifier to print MAC addresses. Use it instead of
pushing each byte via stack.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 49 +++++++---------------
 1 file changed, 14 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 636b205..1c33bd0 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -1376,12 +1376,8 @@ int hns_dsaf_set_mac_uc_entry(
 	if (MAC_IS_ALL_ZEROS(mac_entry->addr) ||
 	    MAC_IS_BROADCAST(mac_entry->addr) ||
 	    MAC_IS_MULTICAST(mac_entry->addr)) {
-		dev_err(dsaf_dev->dev,
-			"set_uc %s Mac %02x:%02x:%02x:%02x:%02x:%02x err!\n",
-			dsaf_dev->ae_dev.name, mac_entry->addr[0],
-			mac_entry->addr[1], mac_entry->addr[2],
-			mac_entry->addr[3], mac_entry->addr[4],
-			mac_entry->addr[5]);
+		dev_err(dsaf_dev->dev, "set_uc %s Mac %pM err!\n",
+			dsaf_dev->ae_dev.name, mac_entry->addr);
 		return -EINVAL;
 	}
 
@@ -1448,12 +1444,8 @@ int hns_dsaf_set_mac_mc_entry(
 
 	/* mac addr check */
 	if (MAC_IS_ALL_ZEROS(mac_entry->addr)) {
-		dev_err(dsaf_dev->dev,
-			"set uc %s Mac %02x:%02x:%02x:%02x:%02x:%02x err!\n",
-			dsaf_dev->ae_dev.name, mac_entry->addr[0],
-			mac_entry->addr[1], mac_entry->addr[2],
-			mac_entry->addr[3],
-			mac_entry->addr[4], mac_entry->addr[5]);
+		dev_err(dsaf_dev->dev, "set uc %s Mac %pM err!\n",
+			dsaf_dev->ae_dev.name, mac_entry->addr);
 		return -EINVAL;
 	}
 
@@ -1527,11 +1519,8 @@ int hns_dsaf_add_mac_mc_port(struct dsaf_device *dsaf_dev,
 
 	/*chechk mac addr */
 	if (MAC_IS_ALL_ZEROS(mac_entry->addr)) {
-		dev_err(dsaf_dev->dev,
-			"set_entry failed,addr %02x:%02x:%02x:%02x:%02x:%02x!\n",
-			mac_entry->addr[0], mac_entry->addr[1],
-			mac_entry->addr[2], mac_entry->addr[3],
-			mac_entry->addr[4], mac_entry->addr[5]);
+		dev_err(dsaf_dev->dev, "set_entry failed,addr %pM!\n",
+			mac_entry->addr);
 		return -EINVAL;
 	}
 
@@ -1614,9 +1603,8 @@ int hns_dsaf_del_mac_entry(struct dsaf_device *dsaf_dev, u16 vlan_id,
 
 	/*check mac addr */
 	if (MAC_IS_ALL_ZEROS(addr) || MAC_IS_BROADCAST(addr)) {
-		dev_err(dsaf_dev->dev,
-			"del_entry failed,addr %02x:%02x:%02x:%02x:%02x:%02x!\n",
-			addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
+		dev_err(dsaf_dev->dev, "del_entry failed,addr %pM!\n",
+			addr);
 		return -EINVAL;
 	}
 
@@ -1680,11 +1668,8 @@ int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
 
 	/*check mac addr */
 	if (MAC_IS_ALL_ZEROS(mac_entry->addr)) {
-		dev_err(dsaf_dev->dev,
-			"del_port failed, addr %02x:%02x:%02x:%02x:%02x:%02x!\n",
-			mac_entry->addr[0], mac_entry->addr[1],
-			mac_entry->addr[2], mac_entry->addr[3],
-			mac_entry->addr[4], mac_entry->addr[5]);
+		dev_err(dsaf_dev->dev, "del_port failed, addr %pM!\n",
+			mac_entry->addr);
 		return -EINVAL;
 	}
 
@@ -1761,11 +1746,8 @@ int hns_dsaf_get_mac_uc_entry(struct dsaf_device *dsaf_dev,
 	/* check macaddr */
 	if (MAC_IS_ALL_ZEROS(mac_entry->addr) ||
 	    MAC_IS_BROADCAST(mac_entry->addr)) {
-		dev_err(dsaf_dev->dev,
-			"get_entry failed,addr %02x:%02x:%02x:%02x:%02x:%02x\n",
-			mac_entry->addr[0], mac_entry->addr[1],
-			mac_entry->addr[2], mac_entry->addr[3],
-			mac_entry->addr[4], mac_entry->addr[5]);
+		dev_err(dsaf_dev->dev, "get_entry failed,addr %pM\n",
+			mac_entry->addr);
 		return -EINVAL;
 	}
 
@@ -1812,11 +1794,8 @@ int hns_dsaf_get_mac_mc_entry(struct dsaf_device *dsaf_dev,
 	/*check mac addr */
 	if (MAC_IS_ALL_ZEROS(mac_entry->addr) ||
 	    MAC_IS_BROADCAST(mac_entry->addr)) {
-		dev_err(dsaf_dev->dev,
-			"get_entry failed,addr %02x:%02x:%02x:%02x:%02x:%02x\n",
-			mac_entry->addr[0], mac_entry->addr[1],
-			mac_entry->addr[2], mac_entry->addr[3],
-			mac_entry->addr[4], mac_entry->addr[5]);
+		dev_err(dsaf_dev->dev, "get_entry failed,addr %pM\n",
+			mac_entry->addr);
 		return -EINVAL;
 	}
 
-- 
2.6.2
