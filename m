From: Matthew Whitehead <tedheadster@gmail.com>
Subject: [PATCH net-next] 8390 ei_debug : Reenable the use of debugging in 8390 based chips
Date: Mon, 14 Oct 2013 16:33:14 -0400
Message-ID: <1381782794-11334-1-git-send-email-tedheadster@gmail.com>
Cc: Matthew Whitehead <tedheadster@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f44.google.com ([209.85.128.44]:54035 "EHLO
	mail-qe0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933190Ab3JNUdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 16:33:24 -0400
Received: by mail-qe0-f44.google.com with SMTP id 6so5620705qeb.17
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 13:33:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethernet boards based on the 8390 chip had an '#ifdef notdef' disabling the
use of the debug variable ei_debug. Reenable it for those of us who still
occasionally use it.

Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
---
 drivers/net/ethernet/8390/8390.h     |    2 +-
 drivers/net/ethernet/8390/axnet_cs.c |    5 -----
 drivers/net/ethernet/8390/lib8390.c  |    4 ++--
 3 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/8390/8390.h b/drivers/net/ethernet/8390/8390.h
index ef325ff..2375087 100644
--- a/drivers/net/ethernet/8390/8390.h
+++ b/drivers/net/ethernet/8390/8390.h
@@ -21,7 +21,7 @@ struct e8390_pkt_hdr {
   unsigned short count; /* header + packet length in bytes */
 };
 
-#ifdef notdef
+#ifdef EI_DEBUG
 extern int ei_debug;
 #else
 #define ei_debug 1
diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index d801c141..581560c 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -810,11 +810,6 @@ module_pcmcia_driver(axnet_cs_driver);
 #define ei_block_input (ei_local->block_input)
 #define ei_get_8390_hdr (ei_local->get_8390_hdr)
 
-/* use 0 for production, 1 for verification, >2 for debug */
-#ifndef ei_debug
-int ei_debug = 1;
-#endif
-
 /* Index to functions. */
 static void ei_tx_intr(struct net_device *dev);
 static void ei_tx_err(struct net_device *dev);
diff --git a/drivers/net/ethernet/8390/lib8390.c b/drivers/net/ethernet/8390/lib8390.c
index b329f5c..4ec5e38 100644
--- a/drivers/net/ethernet/8390/lib8390.c
+++ b/drivers/net/ethernet/8390/lib8390.c
@@ -100,8 +100,8 @@
 #define ei_get_8390_hdr (ei_local->get_8390_hdr)
 
 /* use 0 for production, 1 for verification, >2 for debug */
-#ifndef ei_debug
-int ei_debug = 1;
+#ifdef EI_DEBUG
+int ei_debug = EI_DEBUG;
 #endif
 
 /* Index to functions. */
-- 
1.7.2.5
