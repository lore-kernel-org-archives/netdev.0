From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH net-next] bonding: bond_update_speed_duplex() can return void since no callers check its return
Date: Thu, 26 Apr 2012 14:20:30 -0700 (PDT)
Message-ID: <20120426212030.269072900341@tardy>
Reply-To: Rick Jones <rick.jones2@hp.com>
Cc: <fubar@us.ibm.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:47868 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755508Ab2DZVUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 17:20:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

As none of the callers of bond_update_speed_duplex (need to) check its
return value, there is little point in it returning anything.

Signed-off-by: Rick Jones <rick.jones2@hp.com>
---

Compile tested only

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 44e6a64..16dbf53 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -549,9 +549,9 @@ down:
  * Get link speed and duplex from the slave's base driver
  * using ethtool. If for some reason the call fails or the
  * values are invalid, set speed and duplex to -1,
- * and return error.
+ * and return.
  */
-static int bond_update_speed_duplex(struct slave *slave)
+static void bond_update_speed_duplex(struct slave *slave)
 {
 	struct net_device *slave_dev = slave->dev;
 	struct ethtool_cmd ecmd;
@@ -563,24 +563,24 @@ static int bond_update_speed_duplex(struct slave *slave)
 
 	res = __ethtool_get_settings(slave_dev, &ecmd);
 	if (res < 0)
-		return -1;
+		return;
 
 	slave_speed = ethtool_cmd_speed(&ecmd);
 	if (slave_speed == 0 || slave_speed == ((__u32) -1))
-		return -1;
+		return;
 
 	switch (ecmd.duplex) {
 	case DUPLEX_FULL:
 	case DUPLEX_HALF:
 		break;
 	default:
-		return -1;
+		return;
 	}
 
 	slave->speed = slave_speed;
 	slave->duplex = ecmd.duplex;
 
-	return 0;
+	return;
 }
 
 /*
