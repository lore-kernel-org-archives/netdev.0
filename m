From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 08/11] net: Remove vrf header file
Date: Thu, 24 Sep 2015 18:21:04 -0600
Message-ID: <1443140467-69297-9-git-send-email-dsa@cumulusnetworks.com>
References: <1443140467-69297-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33211 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbbIYAV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 20:21:27 -0400
Received: by pacex6 with SMTP id ex6so87397809pac.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 17:21:26 -0700 (PDT)
In-Reply-To: <1443140467-69297-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move remaining structs to VRF driver and delete the vrf header file.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 MAINTAINERS       |  1 -
 drivers/net/vrf.c | 16 +++++++++++++++-
 include/net/vrf.h | 29 -----------------------------
 3 files changed, 15 insertions(+), 31 deletions(-)
 delete mode 100644 include/net/vrf.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 97c005e12926..5775010e751b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11248,7 +11248,6 @@ M:	Shrijeet Mukherjee <shm@cumulusnetworks.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/vrf.c
-F:	include/net/vrf.h
 
 VT1211 HARDWARE MONITOR DRIVER
 M:	Juerg Haefliger <juergh@gmail.com>
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index fcf5f534d11e..388517fc6e15 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -34,7 +34,6 @@
 #include <net/rtnetlink.h>
 #include <net/route.h>
 #include <net/addrconf.h>
-#include <net/vrf.h>
 #include <net/l3mdev.h>
 
 #define DRV_NAME	"vrf"
@@ -45,6 +44,21 @@
 #define vrf_master_get_rcu(dev) \
 	((struct net_device *)rcu_dereference(dev->rx_handler_data))
 
+struct slave {
+	struct list_head        list;
+	struct net_device       *dev;
+};
+
+struct slave_queue {
+	struct list_head        all_slaves;
+};
+
+struct net_vrf {
+	struct slave_queue      queue;
+	struct rtable           *rth;
+	u32                     tb_id;
+};
+
 struct pcpu_dstats {
 	u64			tx_pkts;
 	u64			tx_bytes;
diff --git a/include/net/vrf.h b/include/net/vrf.h
deleted file mode 100644
index e83fc38770dd..000000000000
--- a/include/net/vrf.h
+++ /dev/null
@@ -1,29 +0,0 @@
-/*
- * include/net/net_vrf.h - adds vrf dev structure definitions
- * Copyright (c) 2015 Cumulus Networks
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#ifndef __LINUX_NET_VRF_H
-#define __LINUX_NET_VRF_H
-
-struct slave {
-	struct list_head	list;
-	struct net_device	*dev;
-};
-
-struct slave_queue {
-	struct list_head	all_slaves;
-};
-
-struct net_vrf {
-	struct slave_queue	queue;
-	struct rtable           *rth;
-	u32			tb_id;
-};
-
-#endif /* __LINUX_NET_VRF_H */
-- 
2.3.8 (Apple Git-58)
