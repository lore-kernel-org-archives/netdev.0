From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] net: fix some compiler warning in net/core/neighbour.c
Date: Thu,  6 Dec 2012 10:04:04 +0800
Message-ID: <1354759444-4937-1-git-send-email-amwang@redhat.com>
Cc: Shan Wei <davidshan@tencent.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980Ab2LFCEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 21:04:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

net/core/neighbour.c:65:12: warning: 'zero' defined but not used [-Wunused-variable]
net/core/neighbour.c:66:12: warning: 'unres_qlen_max' defined but not used [-Wunused-variable]

These variables are only used when CONFIG_SYSCTL is defined,
so move them under #ifdef CONFIG_SYSCTL.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: Shan Wei <davidshan@tencent.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 36fc692..c815f28 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -62,9 +62,6 @@ static void __neigh_notify(struct neighbour *n, int type, int flags);
 static void neigh_update_notify(struct neighbour *neigh);
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 
-static int zero;
-static int unres_qlen_max = INT_MAX / SKB_TRUESIZE(ETH_FRAME_LEN);
-
 static struct neigh_table *neigh_tables;
 #ifdef CONFIG_PROC_FS
 static const struct file_operations neigh_stat_seq_fops;
@@ -2772,6 +2769,8 @@ EXPORT_SYMBOL(neigh_app_ns);
 #endif /* CONFIG_ARPD */
 
 #ifdef CONFIG_SYSCTL
+static int zero;
+static int unres_qlen_max = INT_MAX / SKB_TRUESIZE(ETH_FRAME_LEN);
 
 static int proc_unres_qlen(ctl_table *ctl, int write, void __user *buffer,
 			   size_t *lenp, loff_t *ppos)
