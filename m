From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] PCMCIA NET:  Use roundup_pow_of_two() macro instead of
 grotesque loop.
Date: Tue, 6 Nov 2007 09:41:21 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0711060936290.4980@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:35109 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbXKFOnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 09:43:06 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

  i'm just going to assume that loop is rounding up to the next power
of two, right?


diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index db6a97d..07eae16 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -38,6 +38,7 @@
 #include <linux/delay.h>
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
+#include <linux/log2.h>
 #include "../8390.h"

 #include <pcmcia/cs_types.h>
@@ -1484,8 +1485,7 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
 	window_size = 32 * 1024;

     /* Make sure it's a power of two.  */
-    while ((window_size & (window_size - 1)) != 0)
-	window_size += window_size & ~(window_size - 1);
+    window_size = roundup_pow_of_two(window_size);

     /* Allocate a memory window */
     req.Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM|WIN_ENABLE;
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
