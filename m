From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: add address and vlan to fdb warning messages
Date: Tue, 11 Oct 2016 14:33:51 -0700
Message-ID: <1476221632-18488-1-git-send-email-roopa@cumulusnetworks.com>
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36122 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752581AbcJKVeA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 17:34:00 -0400
Received: by mail-pf0-f170.google.com with SMTP id e6so7826340pfk.3
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 14:34:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds vlan and address to warning messages printed
in the bridge fdb code for debuggability.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_fdb.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 6b43c8c..1257a88 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -536,8 +536,8 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		if (fdb->is_local)
 			return 0;
 		br_warn(br, "adding interface %s with same address "
-		       "as a received packet\n",
-		       source ? source->dev->name : br->dev->name);
+		       "as a received packet (addr:%pM, vlan:%d)\n",
+		       source ? source->dev->name : br->dev->name, addr, vid);
 		fdb_delete(br, fdb);
 	}
 
@@ -583,9 +583,10 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		/* attempt to update an entry for a local interface */
 		if (unlikely(fdb->is_local)) {
 			if (net_ratelimit())
-				br_warn(br, "received packet on %s with "
-					"own address as source address\n",
-					source->dev->name);
+				br_warn(br, "received packet on %s with own "
+					"address as source address "
+					"(addr:%pM, vlan:%d)\n",
+					source->dev->name, addr, vid);
 		} else {
 			/* fastpath: update of existing entry */
 			if (unlikely(source != fdb->dst)) {
-- 
1.9.1
