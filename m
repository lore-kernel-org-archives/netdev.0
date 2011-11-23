From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 1/2] ehea: Reduce memory usage in buffer pools
Date: Wed, 23 Nov 2011 21:13:02 +1100
Message-ID: <20111123211302.2a37debb@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59152 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711Ab1KWKNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 05:13:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that we enable multiqueue by default the ehea driver is using
quite a lot of memory for its buffer pools. With 4 queues we
consume 64MB in the jumbo packet ring, 16MB in the medium packet
ring and 16MB in the tiny packet ring.

We should only fill the jumbo ring once the MTU is increased but
for now halve it's size so it consumes 32MB. Also reduce the tiny
packet ring, with 4 queues we had 16k entries which is overkill.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-build/drivers/net/ethernet/ibm/ehea/ehea.h
===================================================================
--- linux-build.orig/drivers/net/ethernet/ibm/ehea/ehea.h	2011-11-15 11:35:21.703449412 +1100
+++ linux-build/drivers/net/ethernet/ibm/ehea/ehea.h	2011-11-15 11:48:56.461767694 +1100
@@ -61,9 +61,9 @@
 #ifdef EHEA_SMALL_QUEUES
 #define EHEA_MAX_CQE_COUNT      1023
 #define EHEA_DEF_ENTRIES_SQ     1023
-#define EHEA_DEF_ENTRIES_RQ1    4095
+#define EHEA_DEF_ENTRIES_RQ1    1023
 #define EHEA_DEF_ENTRIES_RQ2    1023
-#define EHEA_DEF_ENTRIES_RQ3    1023
+#define EHEA_DEF_ENTRIES_RQ3    511
 #else
 #define EHEA_MAX_CQE_COUNT      4080
 #define EHEA_DEF_ENTRIES_SQ     4080
