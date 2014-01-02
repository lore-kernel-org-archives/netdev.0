From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 1/5] bcma: export bcma_find_core_unit()
Date: Thu,  2 Jan 2014 20:18:58 +0100
Message-ID: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:51579 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751406AbaABTTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 14:19:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is used to get a specific core when there is more than
one core of that specific type. This is used in bgmac to reset all GMAC
cores.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/bcma/bcma_private.h |    2 --
 drivers/bcma/main.c         |   13 +------------
 include/linux/bcma/bcma.h   |    9 ++++++++-
 3 files changed, 9 insertions(+), 15 deletions(-)

diff --git a/drivers/bcma/bcma_private.h b/drivers/bcma/bcma_private.h
index 0215f9a..09b632a 100644
--- a/drivers/bcma/bcma_private.h
+++ b/drivers/bcma/bcma_private.h
@@ -33,8 +33,6 @@ int __init bcma_bus_early_register(struct bcma_bus *bus,
 int bcma_bus_suspend(struct bcma_bus *bus);
 int bcma_bus_resume(struct bcma_bus *bus);
 #endif
-struct bcma_device *bcma_find_core_unit(struct bcma_bus *bus, u16 coreid,
-					u8 unit);
 
 /* scan.c */
 int bcma_bus_scan(struct bcma_bus *bus);
diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index 5a9f6bd..34ea4c5 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -78,18 +78,6 @@ static u16 bcma_cc_core_id(struct bcma_bus *bus)
 	return BCMA_CORE_CHIPCOMMON;
 }
 
-struct bcma_device *bcma_find_core(struct bcma_bus *bus, u16 coreid)
-{
-	struct bcma_device *core;
-
-	list_for_each_entry(core, &bus->cores, list) {
-		if (core->id.id == coreid)
-			return core;
-	}
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(bcma_find_core);
-
 struct bcma_device *bcma_find_core_unit(struct bcma_bus *bus, u16 coreid,
 					u8 unit)
 {
@@ -101,6 +89,7 @@ struct bcma_device *bcma_find_core_unit(struct bcma_bus *bus, u16 coreid,
 	}
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(bcma_find_core_unit);
 
 bool bcma_wait_value(struct bcma_device *core, u16 reg, u32 mask, u32 value,
 		     int timeout)
diff --git a/include/linux/bcma/bcma.h b/include/linux/bcma/bcma.h
index 4d043c3..0b3bb16 100644
--- a/include/linux/bcma/bcma.h
+++ b/include/linux/bcma/bcma.h
@@ -418,7 +418,14 @@ static inline void bcma_maskset16(struct bcma_device *cc,
 	bcma_write16(cc, offset, (bcma_read16(cc, offset) & mask) | set);
 }
 
-extern struct bcma_device *bcma_find_core(struct bcma_bus *bus, u16 coreid);
+extern struct bcma_device *bcma_find_core_unit(struct bcma_bus *bus, u16 coreid,
+					       u8 unit);
+static inline struct bcma_device *bcma_find_core(struct bcma_bus *bus,
+						 u16 coreid)
+{
+	return bcma_find_core_unit(bus, coreid, 0);
+}
+
 extern bool bcma_core_is_enabled(struct bcma_device *core);
 extern void bcma_core_disable(struct bcma_device *core, u32 flags);
 extern int bcma_core_enable(struct bcma_device *core, u32 flags);
-- 
1.7.10.4
