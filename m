From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 2/2] pkt_sched: Fix sch_tree_lock()
Date: Tue, 26 Aug 2008 01:19:28 +0200
Message-ID: <20080825231928.GC12082@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:7698 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442AbYHYXSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 19:18:12 -0400
Received: by ug-out-1314.google.com with SMTP id c2so658338ugf.37
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 16:18:10 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(apply after: [PATCH 1/2] pkt_sched: Fix gen_estimator locks)

-------------->

pkt_sched: Fix sch_tree_lock()

Use new qdisc_root_sleeping_lock() instead of qdisc_root_lock() as
sch_tree_lock() because this lock could be used while dev is
deactivated, but we never need to use this with noop_qdisc as a root.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 include/net/sch_generic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index ef8a7e2..e556962 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -232,12 +232,12 @@ static inline struct net_device *qdisc_dev(struct Qdisc *qdisc)
 
 static inline void sch_tree_lock(struct Qdisc *q)
 {
-	spin_lock_bh(qdisc_root_lock(q));
+	spin_lock_bh(qdisc_root_sleeping_lock(q));
 }
 
 static inline void sch_tree_unlock(struct Qdisc *q)
 {
-	spin_unlock_bh(qdisc_root_lock(q));
+	spin_unlock_bh(qdisc_root_sleeping_lock(q));
 }
 
 #define tcf_tree_lock(tp)	sch_tree_lock((tp)->q)
