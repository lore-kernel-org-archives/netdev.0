From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH 2/2] iproute2: use named constants instead of number literals to fill rtnl_rttable_hash
Date: Fri,  7 Mar 2014 19:21:37 +0900
Message-ID: <1394187697-1147-2-git-send-email-yamato@redhat.com>
References: <1394187697-1147-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13313 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753178AbaCGKWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 05:22:13 -0500
In-Reply-To: <1394187697-1147-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 lib/rt_names.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index b005a64..911e4d2 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -314,21 +314,27 @@ int rtnl_rtrealm_a2n(__u32 *id, const char *arg)
 }
 
 
-static struct rtnl_hash_entry dflt_table_entry  = { .id = 253, .name = "default" };
-static struct rtnl_hash_entry main_table_entry  = { .id = 254, .name = "main" };
-static struct rtnl_hash_entry local_table_entry = { .id = 255, .name = "local" };
+static struct rtnl_hash_entry dflt_table_entry  = { .name = "default" };
+static struct rtnl_hash_entry main_table_entry  = { .name = "main" };
+static struct rtnl_hash_entry local_table_entry = { .name = "local" };
 
 static struct rtnl_hash_entry * rtnl_rttable_hash[256] = {
-	[253] = &dflt_table_entry,
-	[254] = &main_table_entry,
-	[255] = &local_table_entry,
+	[RT_TABLE_DEFAULT] = &dflt_table_entry,
+	[RT_TABLE_MAIN]    = &main_table_entry,
+	[RT_TABLE_LOCAL]   = &local_table_entry,
 };
 
 static int rtnl_rttable_init;
 
 static void rtnl_rttable_initialize(void)
 {
+	int i;
+
 	rtnl_rttable_init = 1;
+	for (i = 0; i < 256; i++) {
+		if (rtnl_rttable_hash[i])
+			rtnl_rttable_hash[i]->id = i;
+	}
 	rtnl_hash_initialize(CONFDIR "/rt_tables",
 			     rtnl_rttable_hash, 256);
 }
-- 
1.8.5.3
