From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] net: move ethtool include to where its used
Date: Fri,  3 Feb 2012 06:17:02 -0500
Message-ID: <1328267822-25690-1-git-send-email-vapier@gentoo.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:44305 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756051Ab2BCLQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 06:16:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The linux/mii.h headers has long been standalone for userspace.  But a
recent commit added linux/ethtool.h to the include list even when it
isn't used.  Since we only need this with __KERNEL__, move the include
down to the right spot.  Now userland no longer needs to pull this in.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 include/linux/mii.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/mii.h b/include/linux/mii.h
index 2783eca..415b397 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -9,7 +9,6 @@
 #define __LINUX_MII_H__
 
 #include <linux/types.h>
-#include <linux/ethtool.h>
 
 /* Generic MII registers. */
 #define MII_BMCR		0x00	/* Basic mode control register */
@@ -151,6 +150,7 @@ struct mii_ioctl_data {
 
 #ifdef __KERNEL__
 
+#include <linux/ethtool.h>
 #include <linux/if.h>
 
 struct ethtool_cmd;
-- 
1.7.8.4
