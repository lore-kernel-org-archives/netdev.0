From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v3 1/5] bcma: export bcma_find_core_unit()
Date: Sun,  5 Jan 2014 01:10:43 +0100
Message-ID: <1388880647-7611-2-git-send-email-hauke@hauke-m.de>
References: <1388880647-7611-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:60053 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755139AbaAEAK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 19:10:58 -0500
In-Reply-To: <1388880647-7611-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is used to get a specific core when there is more than
one core of that specific type. This is used in bgmac to reset all GMAC
cores.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/bcma/bcma_private.h |    2 --
 drivers/bcma/main.c         |   13 +------------
 include/linux/bcma/bcma.h   |    9 ++++++++-
 3 files changed, 9 insertions(+), 15 deletions(-)

diff --git a/drivers/bcma/bcma_private.h b/drivers/bcma/bcma_private.h
index 0215f9a..09b632a 100644
--- a/drivers/bcma/bcma_private.h
+++ b/drivers/bcma/bcma_private.h
@@ -33,8 +33,6 @@ int __init bcma_bus_early_register(struct bcma_bus *b=
us,
 int bcma_bus_suspend(struct bcma_bus *bus);
 int bcma_bus_resume(struct bcma_bus *bus);
 #endif
-struct bcma_device *bcma_find_core_unit(struct bcma_bus *bus, u16 core=
id,
-					u8 unit);
=20
 /* scan.c */
 int bcma_bus_scan(struct bcma_bus *bus);
diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index 5a9f6bd..34ea4c5 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -78,18 +78,6 @@ static u16 bcma_cc_core_id(struct bcma_bus *bus)
 	return BCMA_CORE_CHIPCOMMON;
 }
=20
-struct bcma_device *bcma_find_core(struct bcma_bus *bus, u16 coreid)
-{
-	struct bcma_device *core;
-
-	list_for_each_entry(core, &bus->cores, list) {
-		if (core->id.id =3D=3D coreid)
-			return core;
-	}
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(bcma_find_core);
-
 struct bcma_device *bcma_find_core_unit(struct bcma_bus *bus, u16 core=
id,
 					u8 unit)
 {
@@ -101,6 +89,7 @@ struct bcma_device *bcma_find_core_unit(struct bcma_=
bus *bus, u16 coreid,
 	}
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(bcma_find_core_unit);
=20
 bool bcma_wait_value(struct bcma_device *core, u16 reg, u32 mask, u32 =
value,
 		     int timeout)
diff --git a/include/linux/bcma/bcma.h b/include/linux/bcma/bcma.h
index 4d043c3..0b3bb16 100644
--- a/include/linux/bcma/bcma.h
+++ b/include/linux/bcma/bcma.h
@@ -418,7 +418,14 @@ static inline void bcma_maskset16(struct bcma_devi=
ce *cc,
 	bcma_write16(cc, offset, (bcma_read16(cc, offset) & mask) | set);
 }
=20
-extern struct bcma_device *bcma_find_core(struct bcma_bus *bus, u16 co=
reid);
+extern struct bcma_device *bcma_find_core_unit(struct bcma_bus *bus, u=
16 coreid,
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
--=20
1.7.10.4
