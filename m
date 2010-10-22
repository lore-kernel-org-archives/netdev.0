From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 5/5] netdev: bfin_mac: disable hardware checksum if writeback cache is enabled
Date: Fri, 22 Oct 2010 01:59:21 -0400
Message-ID: <1287727161-24671-5-git-send-email-vapier@gentoo.org>
References: <1287727161-24671-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:40762 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752795Ab0JVF7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Oct 2010 01:59:43 -0400
In-Reply-To: <1287727161-24671-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

With writeback caches, corrupted RX packets will be sent up the stack
without any error markings.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index 4827f6b..692187d 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -17,7 +17,14 @@
 #include <linux/etherdevice.h>
 #include <linux/bfin_mac.h>
 
+/*
+ * Disable hardware checksum for bug #5600 if writeback cache is
+ * enabled. Otherwize, corrupted RX packet will be sent up stack
+ * without error mark.
+ */
+#ifndef CONFIG_BFIN_EXTMEM_WRITEBACK
 #define BFIN_MAC_CSUM_OFFLOAD
+#endif
 
 #define TX_RECLAIM_JIFFIES (HZ / 5)
 
-- 
1.7.3.1

