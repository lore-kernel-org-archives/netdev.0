From: Ronen Arad <ronen.arad@intel.com>
Subject: [PATCH] rtnetlink: fix gcc -Wconversion warning
Date: Fri,  9 Oct 2015 10:35:47 -0700
Message-ID: <1444412147-21589-1-git-send-email-ronen.arad@intel.com>
Cc: Ronen Arad <ronen.arad@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39401 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758634AbbJIRgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2015 13:36:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTA_ALIGNTO is currently define as 4. It has to be 4U to prevent warning
for RTA_ALIGN and RTA_DATA expansions when -Wconversion gcc option is
enabled.
This follows NLMSG_ALIGNTO definition in <include/uapi/linux/netlink.h>.

Signed-off-by: Ronen Arad <ronen.arad@intel.com>
---
 include/uapi/linux/rtnetlink.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 4db0b3c..123a5af 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -160,7 +160,7 @@ struct rtattr {
 
 /* Macros to handle rtattributes */
 
-#define RTA_ALIGNTO	4
+#define RTA_ALIGNTO	4U
 #define RTA_ALIGN(len) ( ((len)+RTA_ALIGNTO-1) & ~(RTA_ALIGNTO-1) )
 #define RTA_OK(rta,len) ((len) >= (int)sizeof(struct rtattr) && \
 			 (rta)->rta_len >= sizeof(struct rtattr) && \
-- 
2.1.0
