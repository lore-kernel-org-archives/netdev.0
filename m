From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 11/15]: sch_api: introduce constant for rate table size
Date: Wed, 23 Jan 2008 17:36:51 +0100 (MET)
Message-ID: <20080123163610.6459.76735.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49733 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681AbYAWQgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:52 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: sch_api: introduce constant for rate table size

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b21f31e516f993016f8a1ade331bcaf71576b4e2
tree e59049e1fb3f2711d83c196d2f54b5021dc68330
parent 3e73383f7c353af51e8cc475f1c217a6b81fcecf
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:56 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:56 +0100

 include/linux/pkt_sched.h |    2 ++
 net/sched/sch_api.c       |    3 ++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 919af93..3276135 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -83,6 +83,8 @@ struct tc_ratespec
 	__u32		rate;
 };
 
+#define TC_RTAB_SIZE	1024
+
 /* FIFO section */
 
 struct tc_fifo_qopt
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 8db554d..7e3c048 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -244,7 +244,8 @@ struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r, struct nlattr *ta
 		}
 	}
 
-	if (tab == NULL || r->rate == 0 || r->cell_log == 0 || nla_len(tab) != 1024)
+	if (tab == NULL || r->rate == 0 || r->cell_log == 0 ||
+	    nla_len(tab) != TC_RTAB_SIZE)
 		return NULL;
 
 	rtab = kmalloc(sizeof(*rtab), GFP_KERNEL);
