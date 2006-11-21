From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 3/11] [NET] neighbour: Use kmemdup where applicable
Date: Tue, 21 Nov 2006 01:27:33 -0200
Message-ID: <20061121032733.GD7039@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:6893 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1030684AbWKUD1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:27:39 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/core/neighbour.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 0e097ba..ba509a4 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1266,10 +1266,9 @@ void pneigh_enqueue(struct neigh_table *
 struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 				      struct neigh_table *tbl)
 {
-	struct neigh_parms *p = kmalloc(sizeof(*p), GFP_KERNEL);
+	struct neigh_parms *p = kmemdup(&tbl->parms, sizeof(*p), GFP_KERNEL);
 
 	if (p) {
-		memcpy(p, &tbl->parms, sizeof(*p));
 		p->tbl		  = tbl;
 		atomic_set(&p->refcnt, 1);
 		INIT_RCU_HEAD(&p->rcu_head);
@@ -2625,14 +2624,14 @@ int neigh_sysctl_register(struct net_dev
 			  int p_id, int pdev_id, char *p_name, 
 			  proc_handler *handler, ctl_handler *strategy)
 {
-	struct neigh_sysctl_table *t = kmalloc(sizeof(*t), GFP_KERNEL);
+	struct neigh_sysctl_table *t = kmemdup(&neigh_sysctl_template,
+					       sizeof(*t), GFP_KERNEL);
 	const char *dev_name_source = NULL;
 	char *dev_name = NULL;
 	int err = 0;
 
 	if (!t)
 		return -ENOBUFS;
-	memcpy(t, &neigh_sysctl_template, sizeof(*t));
 	t->neigh_vars[0].data  = &p->mcast_probes;
 	t->neigh_vars[1].data  = &p->ucast_probes;
 	t->neigh_vars[2].data  = &p->app_probes;
-- 
1.4.2.1.g3d5c

