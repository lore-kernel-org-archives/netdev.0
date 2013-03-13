From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH v2 1/1] ipv4: fix definition of FIB_TABLE_HASHSZ
Date: Wed, 13 Mar 2013 14:24:15 +0400
Message-ID: <1363170255-11769-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>,
	Tingwei Liu <tingw.liu@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44739 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754451Ab3CMKZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 06:25:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>

a long time ago by the commit

  commit 93456b6d7753def8760b423ac6b986eb9d5a4a95
  Author: Denis V. Lunev <den@openvz.org>
  Date:   Thu Jan 10 03:23:38 2008 -0800

    [IPV4]: Unify access to the routing tables.

the defenition of FIB_HASH_TABLE size has obtained wrong dependency:
it should depend upon CONFIG_IP_MULTIPLE_TABLES (as was in the original
code) but it was depended from CONFIG_IP_ROUTE_MULTIPATH

This patch returns the situation to the original state.

The problem was spotted by Tingwei Liu.

Signed-off-by: Denis V. Lunev <den@openvz.org>
CC: Tingwei Liu <tingw.liu@gmail.com>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
Changes from v1:
- corrected CONFIG_IP_MULTIPLE_TABLES branches. HASHSZ should be 256
  if defined
- holy crap. Original patch has wrong define CONFIG_IP_MULTIPLE_TABLES
  I have forgotten all things in kernel :( Fixed too. Checked both
  branches with #error inside

 include/net/ip_fib.h |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 9497be1..3a7ce04 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -152,18 +152,16 @@ struct fib_result_nl {
 };
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-
 #define FIB_RES_NH(res)		((res).fi->fib_nh[(res).nh_sel])
-
-#define FIB_TABLE_HASHSZ 2
-
 #else /* CONFIG_IP_ROUTE_MULTIPATH */
-
 #define FIB_RES_NH(res)		((res).fi->fib_nh[0])
+#endif /* CONFIG_IP_ROUTE_MULTIPATH */
 
+#ifdef CONFIG_IP_MULTIPLE_TABLES
 #define FIB_TABLE_HASHSZ 256
-
-#endif /* CONFIG_IP_ROUTE_MULTIPATH */
+#else
+#define FIB_TABLE_HASHSZ 2
+#endif
 
 extern __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
 
-- 
1.7.7.6
