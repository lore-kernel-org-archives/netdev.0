From: vignesh babu <vignesh.babu@wipro.com>
Subject: [kj] is_power_of_2 in net/pcmcia/pcnet_cs.c
Date: Mon, 13 Aug 2007 18:22:34 +0530
Message-ID: <1187009554.7273.3.camel@merlin.linuxcoe.com>
Reply-To: vigneshbabu@gmail.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel Janitors List <kernel-janitors@lists.osdl.org>
To: dahinds@users.sourceforge.net, p_gortmaker@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:58245 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S945739AbXHMMxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 08:53:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replacing n & (n - 1) for power of 2 check by is_power_of_2(n)

Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
---
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 63de89e..d23bf6e 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -36,6 +36,7 @@
 #include <linux/string.h>
 #include <linux/timer.h>
 #include <linux/delay.h>
+#include <linux/log2.h>
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <../drivers/net/8390.h>
@@ -1486,7 +1487,7 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
 	window_size = 32 * 1024;
 
     /* Make sure it's a power of two.  */
-    while ((window_size & (window_size - 1)) != 0)
+    while (!is_power_of_2(window_size))
 	window_size += window_size & ~(window_size - 1);
 
     /* Allocate a memory window */

-- 
Vignesh Babu BM 
_____________________________________________________________ 
"Why is it that every time I'm with you, makes me believe in magic?"

