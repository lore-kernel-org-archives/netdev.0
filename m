From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 5/17 net-2.6.26] [NETNS]: Register neighbour table parameters in the correct namespace.
Date: Tue, 19 Feb 2008 10:31:25 +0300
Message-ID: <1203406297-32725-5-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:65080 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755431AbYBSHbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 02:31:16 -0500
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

neigh_sysctl_register should register sysctl entries inside correct namespace
to avoid naming conflict. Typical example is a loopback. Entries for it
present in all namespaces.

Required to make inetdev_event working.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/core/neighbour.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 7bb6a9a..c895ad4 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2732,7 +2732,8 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	neigh_path[NEIGH_CTL_PATH_PROTO].procname = p_name;
 	neigh_path[NEIGH_CTL_PATH_PROTO].ctl_name = p_id;
 
-	t->sysctl_header = register_sysctl_paths(neigh_path, t->neigh_vars);
+	t->sysctl_header =
+		register_net_sysctl_table(p->net, neigh_path, t->neigh_vars);
 	if (!t->sysctl_header)
 		goto free_procname;
 
-- 
1.5.3.rc5

