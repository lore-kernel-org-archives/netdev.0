From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 4/4] ethtool.h: define INT_MAX for userland
Date: Fri,  4 Mar 2016 11:52:19 +0100
Message-ID: <1457088739-1065-5-git-send-email-nicolas.dichtel@6wind.com>
References: <20160303.170804.2300821465150459193.davem@davemloft.net>
 <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, ben@decadent.org.uk,
	Karen Xie <kxie@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Airlie <airlied@linux.ie>,
	dri-devel@lists.freedesktop.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:49078 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbcCDKws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 05:52:48 -0500
In-Reply-To: <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

INT_MAX needs limits.h in userland.
When ethtool.h is included by a userland app, we got the following error:

.../usr/include/linux/ethtool.h: In function 'ethtool_validate_speed':
.../usr/include/linux/ethtool.h:1471:18: error: 'INT_MAX' undeclared (first use in this function)
  return speed <= INT_MAX || speed == SPEED_UNKNOWN
                  ^

Fixes: e02564ee334a ("ethtool: make validate_speed accept all speeds between 0 and INT_MAX")
CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/ethtool.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 9c22249ebf35..2835b07416b7 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -17,6 +17,10 @@
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
+#ifndef __KERNEL__
+#include <limits.h> /* for INT_MAX */
+#endif
+
 /* All structures exposed to userland should be defined such that they
  * have the same layout for 32-bit and 64-bit userland.
  */
-- 
2.4.2
