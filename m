From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH 1/5] netfilter: ipvs: Clean up tests if NULL returned on failure
Date: Tue, 21 Mar 2017 14:14:35 +0530
Message-ID: <1490085879-1827-2-git-send-email-singhalsimran0@gmail.com>
References: <1490085879-1827-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org, outreachy-kernel@googlegroups.com
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490085879-1827-1-git-send-email-singhalsimran0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some functions like kmalloc/kzalloc return NULL on failure. When NULL
represents failure, !x is commonly used.

@@
expression *e;
identifier l1;
@@
e = \(kmalloc\|kzalloc\|kcalloc\|devm_kzalloc\)(...);
...
- e == NULL
+ !e

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---
 
 --This is my contribution to the netfilter project of
   Outreachy Round 14.
 
 net/netfilter/ipvs/ip_vs_ctl.c   | 4 ++--
 net/netfilter/ipvs/ip_vs_dh.c    | 2 +-
 net/netfilter/ipvs/ip_vs_lblc.c  | 2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c | 4 ++--
 net/netfilter/ipvs/ip_vs_sh.c    | 2 +-
 net/netfilter/ipvs/ip_vs_wrr.c   | 2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5aeb0dd..efe348a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -910,7 +910,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	}
 
 	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
-	if (dest == NULL)
+	if (!dest)
 		return -ENOMEM;
 
 	dest->stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
@@ -1228,7 +1228,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 #endif
 
 	svc = kzalloc(sizeof(struct ip_vs_service), GFP_KERNEL);
-	if (svc == NULL) {
+	if (!svc) {
 		IP_VS_DBG(1, "%s(): no memory\n", __func__);
 		ret = -ENOMEM;
 		goto out_err;
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 75f798f..22a2535 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -159,7 +159,7 @@ static int ip_vs_dh_init_svc(struct ip_vs_service *svc)
 
 	/* allocate the DH table for this service */
 	s = kzalloc(sizeof(struct ip_vs_dh_state), GFP_KERNEL);
-	if (s == NULL)
+	if (!s)
 		return -ENOMEM;
 
 	svc->sched_data = s;
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 5824927..d7c6031 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -352,7 +352,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	 *    Allocate the ip_vs_lblc_table for this service
 	 */
 	tbl = kmalloc(sizeof(*tbl), GFP_KERNEL);
-	if (tbl == NULL)
+	if (!tbl)
 		return -ENOMEM;
 
 	svc->sched_data = tbl;
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 703f118..b0a9e1c 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -113,7 +113,7 @@ static void ip_vs_dest_set_insert(struct ip_vs_dest_set *set,
 	}
 
 	e = kmalloc(sizeof(*e), GFP_ATOMIC);
-	if (e == NULL)
+	if (!e)
 		return;
 
 	ip_vs_dest_hold(dest);
@@ -515,7 +515,7 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	 *    Allocate the ip_vs_lblcr_table for this service
 	 */
 	tbl = kmalloc(sizeof(*tbl), GFP_KERNEL);
-	if (tbl == NULL)
+	if (!tbl)
 		return -ENOMEM;
 
 	svc->sched_data = tbl;
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 16aaac6..99f3c3e 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -235,7 +235,7 @@ static int ip_vs_sh_init_svc(struct ip_vs_service *svc)
 
 	/* allocate the SH table for this service */
 	s = kzalloc(sizeof(struct ip_vs_sh_state), GFP_KERNEL);
-	if (s == NULL)
+	if (!s)
 		return -ENOMEM;
 
 	svc->sched_data = s;
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 17e6d44..0923e6c 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -116,7 +116,7 @@ static int ip_vs_wrr_init_svc(struct ip_vs_service *svc)
 	 *    Allocate the mark variable for WRR scheduling
 	 */
 	mark = kmalloc(sizeof(struct ip_vs_wrr_mark), GFP_KERNEL);
-	if (mark == NULL)
+	if (!mark)
 		return -ENOMEM;
 
 	mark->cl = list_entry(&svc->destinations, struct ip_vs_dest, n_list);
-- 
2.7.4
