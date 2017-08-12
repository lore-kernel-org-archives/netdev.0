From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 22/51] lib/rt_names: Drop dead code in rtnl_rttable_n2a()
Date: Sat, 12 Aug 2017 14:04:41 +0200
Message-ID: <20170812120510.28750-23-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48607 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752368AbdHLMFg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:05:36 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 'id' is 32bit unsigned, it can never exceed RT_TABLE_MAX (which is
defined to 0xFFFFFFFF). Therefore drop that never matching conditional.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/rt_names.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index 04c15ff5b15f8..e5efd78e6f810 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -410,10 +410,6 @@ const char *rtnl_rttable_n2a(__u32 id, char *buf, int len)
 {
 	struct rtnl_hash_entry *entry;
 
-	if (id > RT_TABLE_MAX) {
-		snprintf(buf, len, "%u", id);
-		return buf;
-	}
 	if (!rtnl_rttable_init)
 		rtnl_rttable_initialize();
 	entry = rtnl_rttable_hash[id & 255];
-- 
2.13.1
