From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: don't indicate expiry on NTF_EXT_LEARNED fdb entries
Date: Thu, 16 Feb 2017 13:38:04 -0800
Message-ID: <1487281084-11769-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        jiri@resnulli.us, idosch@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34135 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932975AbdBPViI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 16:38:08 -0500
Received: by mail-pf0-f169.google.com with SMTP id e4so8185494pfg.1
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 13:38:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

added_by_external_learn fdb entries are added and expired by
external entities like switchdev driver or external controllers.
ageing is already disabled for such entries. Hence, don't
indicate expiry for such fdb entries.

CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_fdb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 4ac1157..4f598dc 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -65,7 +65,7 @@ static inline unsigned long hold_time(const struct net_bridge *br)
 static inline int has_expired(const struct net_bridge *br,
 				  const struct net_bridge_fdb_entry *fdb)
 {
-	return !fdb->is_static &&
+	return !fdb->is_static && !fdb->added_by_external_learn &&
 		time_before_eq(fdb->updated + hold_time(br), jiffies);
 }
 
-- 
1.7.10.4
