From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 08/11] net: Remove vrf header file
Date: Tue, 29 Sep 2015 20:07:17 -0700
Message-ID: <1443582438-23823-9-git-send-email-dsa@cumulusnetworks.com>
References: <1443582438-23823-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34409 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbbI3DHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 23:07:40 -0400
Received: by padhy16 with SMTP id hy16so24932308pad.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 20:07:37 -0700 (PDT)
In-Reply-To: <1443582438-23823-1-git-send-email-dsa@cumulusnetworks.com>
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
index 3f2d7a9d0bbf..fa43fa2f30e4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11273,7 +11273,6 @@ M:	Shrijeet Mukherjee <shm@cumulusnetworks.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/vrf.c
-F:	include/net/vrf.h
 F:	Documentation/networking/vrf.txt
 
 VT1211 HARDWARE MONITOR DRIVER
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index df872f4efb0d..64f2ab663ffe 100644
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
1.9.1
