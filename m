From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2-net-next] bridge: mdb: add support for offloaded mdb entries
Date: Mon, 22 Feb 2016 15:26:13 +0100
Message-ID: <1456151173-12370-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33194 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932502AbcBVO0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 09:26:17 -0500
Received: by mail-wm0-f48.google.com with SMTP id g62so159287295wme.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 06:26:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Mark MDB entries which are offloaded to HW with "offload" flag

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 bridge/mdb.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/bridge/mdb.c b/bridge/mdb.c
index 24c4903..ae20f38 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -60,10 +60,11 @@ static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e,
 			      (const void *)&e->addr.u.ip6;
 	if (n->nlmsg_type == RTM_DELMDB)
 		fprintf(f, "Deleted ");
-	fprintf(f, "dev %s port %s grp %s %s", ll_index_to_name(ifindex),
+	fprintf(f, "dev %s port %s grp %s %s %s", ll_index_to_name(ifindex),
 		ll_index_to_name(e->ifindex),
 		inet_ntop(af, src, abuf, sizeof(abuf)),
-		(e->state & MDB_PERMANENT) ? "permanent" : "temp");
+		(e->state & MDB_PERMANENT) ? "permanent" : "temp",
+		(e->flags & MDB_FLAGS_OFFLOAD) ? "offload" : "");
 	if (e->vid)
 		fprintf(f, " vid %hu", e->vid);
 	fprintf(f, "\n");
-- 
2.5.0
