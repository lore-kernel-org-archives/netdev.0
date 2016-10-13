From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH NET] ethtool: silence warning on bit loss
Date: Thu, 13 Oct 2016 16:13:55 -0700
Message-ID: <1476400435-18400-1-git-send-email-jesse.brandeburg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12842 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751317AbcJMXTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 19:19:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse was complaining when we went to prototype some code
using ethtool_cmd_speed_set and SPEED_100000, which uses
the upper 16 bits of __u32 speed for the first time.

CHECK
...
.../uapi/linux/ethtool.h:123:28: warning:
  cast truncates bits from constant value (186a0 becomes 86a0)

The warning is actually bogus, as no bits are really lost, but
we can get rid of the sparse warning with this one small change.

Reported-by: Preethi Banala <preethi.banala@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---
 include/uapi/linux/ethtool.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 099a420..8e54723 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -119,8 +119,7 @@ struct ethtool_cmd {
 static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 					 __u32 speed)
 {
-
-	ep->speed = (__u16)speed;
+	ep->speed = (__u16)(speed & 0xFFFF);
 	ep->speed_hi = (__u16)(speed >> 16);
 }
 
-- 
1.8.3.1
