From: akpm@linux-foundation.org
Subject: [patch 5/8] pcmcia net: use roundup_pow_of_two() macro instead of grotesque loop
Date: Wed, 21 Nov 2007 15:02:56 -0800
Message-ID: <200711212302.lALN2u8h013664@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	rpjday@crashcourse.ca, linux@dominikbrodowski.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43119 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753103AbXKUXDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:03:07 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Robert P. J. Day" <rpjday@crashcourse.ca>

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/pcmcia/pcnet_cs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/pcmcia/pcnet_cs.c~pcmcia-net-use-roundup_pow_of_two-macro-instead-of-grotesque-loop drivers/net/pcmcia/pcnet_cs.c
--- a/drivers/net/pcmcia/pcnet_cs.c~pcmcia-net-use-roundup_pow_of_two-macro-instead-of-grotesque-loop
+++ a/drivers/net/pcmcia/pcnet_cs.c
@@ -38,6 +38,7 @@
 #include <linux/delay.h>
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
+#include <linux/log2.h>
 #include "../8390.h"
 
 #include <pcmcia/cs_types.h>
@@ -1484,8 +1485,7 @@ static int setup_shmem_window(struct pcm
 	window_size = 32 * 1024;
 
     /* Make sure it's a power of two.  */
-    while ((window_size & (window_size - 1)) != 0)
-	window_size += window_size & ~(window_size - 1);
+    window_size = roundup_pow_of_two(window_size);
 
     /* Allocate a memory window */
     req.Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM|WIN_ENABLE;
_
