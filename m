From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] ethtool.h: define DIV_ROUND_UP for userland
Date: Tue,  1 Mar 2016 16:20:41 +0100
Message-ID: <1456845641-6985-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:42272 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593AbcCAPU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 10:20:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DIV_ROUND_UP and is defined in linux/kernel.h only for the kernel. INT_MAX
needs limits.h in userland.

When ethtool.h is included by a userland app, we got the following errors:

include/linux/ethtool.h:1218:8: error: variably modified 'queue_mask' at file scope
  __u32 queue_mask[DIV_ROUND_UP(MAX_NUM_QUEUE, 32)];
        ^

.../usr/include/linux/ethtool.h: In function 'ethtool_validate_speed':
.../usr/include/linux/ethtool.h:1471:18: error: 'INT_MAX' undeclared (first use in this function)
  return speed <= INT_MAX || speed == SPEED_UNKNOWN
                  ^

Fixes: ac2c7ad0e5d6 ("net/ethtool: introduce a new ioctl for per queue setting")
Fixes: e02564ee334a ("ethtool: make validate_speed accept all speeds between 0 and INT_MAX")
CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
CC: Kan Liang <kan.liang@intel.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/ethtool.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 37fd6dc33de4..d4e1351fe9b5 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -16,6 +16,11 @@
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
+#ifndef __KERNEL__
+#include <limits.h> /* for INT_MAX */
+#define DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))
+#endif
+
 /* All structures exposed to userland should be defined such that they
  * have the same layout for 32-bit and 64-bit userland.
  */
-- 
2.4.2
