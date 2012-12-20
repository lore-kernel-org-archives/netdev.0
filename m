From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 3/3] iproute2: make `bridge mdb` output consistent with input
Date: Thu, 20 Dec 2012 22:31:55 +0800
Message-ID: <1356013915-20835-3-git-send-email-amwang@redhat.com>
References: <1356013915-20835-1-git-send-email-amwang@redhat.com>
Cc: bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9286 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751227Ab2LTOcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 09:32:08 -0500
In-Reply-To: <1356013915-20835-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge -> dev
group -> grp

Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 bridge/mdb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/bridge/mdb.c b/bridge/mdb.c
index 6217c5f..81d479b 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -53,12 +53,12 @@ static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e)
 	SPRINT_BUF(abuf);
 
 	if (e->addr.proto == htons(ETH_P_IP))
-		fprintf(f, "bridge %s port %s group %s %s\n", ll_index_to_name(ifindex),
+		fprintf(f, "dev %s port %s grp %s %s\n", ll_index_to_name(ifindex),
 			ll_index_to_name(e->ifindex),
 			inet_ntop(AF_INET, &e->addr.u.ip4, abuf, sizeof(abuf)),
 			(e->state & MDB_PERMANENT) ? "permanent" : "temp");
 	else
-		fprintf(f, "bridge %s port %s group %s %s\n", ll_index_to_name(ifindex),
+		fprintf(f, "dev %s port %s grp %s %s\n", ll_index_to_name(ifindex),
 			ll_index_to_name(e->ifindex),
 			inet_ntop(AF_INET6, &e->addr.u.ip6, abuf, sizeof(abuf)),
 			(e->state & MDB_PERMANENT) ? "permanent" : "temp");
-- 
1.7.7.6
