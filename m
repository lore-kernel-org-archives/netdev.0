From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2] bridge: add address and vlan to fdb warning messages
Date: Tue, 11 Oct 2016 16:12:56 -0700
Message-ID: <1476227576-14405-1-git-send-email-roopa@cumulusnetworks.com>
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33728 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754266AbcJKXNy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 19:13:54 -0400
Received: by mail-pa0-f45.google.com with SMTP id vu5so22047486pab.0
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 16:13:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds vlan and address to warning messages printed
in the bridge fdb code for debuggability.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
v2 - address comments from stephen
        - use %u format specifier for vlan
        - move print string to a single line

 net/bridge/br_fdb.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 6b43c8c..e4a4176 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -535,9 +535,8 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		 */
 		if (fdb->is_local)
 			return 0;
-		br_warn(br, "adding interface %s with same address "
-		       "as a received packet\n",
-		       source ? source->dev->name : br->dev->name);
+		br_warn(br, "adding interface %s with same address as a received packet (addr:%pM, vlan:%u)\n",
+		       source ? source->dev->name : br->dev->name, addr, vid);
 		fdb_delete(br, fdb);
 	}
 
@@ -583,9 +582,8 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		/* attempt to update an entry for a local interface */
 		if (unlikely(fdb->is_local)) {
 			if (net_ratelimit())
-				br_warn(br, "received packet on %s with "
-					"own address as source address\n",
-					source->dev->name);
+				br_warn(br, "received packet on %s with own address as source address (addr:%pM, vlan:%u)\n",
+					source->dev->name, addr, vid);
 		} else {
 			/* fastpath: update of existing entry */
 			if (unlikely(source != fdb->dst)) {
-- 
1.9.1
