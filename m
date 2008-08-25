From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix dev_graft_qdisc() locking
Date: Tue, 26 Aug 2008 00:48:54 +0200
Message-ID: <20080825224854.GA12082@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:43013 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551AbYHYWrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 18:47:51 -0400
Received: by nf-out-0910.google.com with SMTP id d3so835796nfc.21
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 15:47:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: Fix dev_graft_qdisc() locking

During dev_graft_qdisc() dev is deactivated, so qdisc_root_lock()
returns wrong lock of noop_qdisc instead of qdisc_sleeping.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_api.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 4f9397f..85e078c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -624,7 +624,7 @@ static struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
 	struct Qdisc *oqdisc = dev_queue->qdisc_sleeping;
 	spinlock_t *root_lock;
 
-	root_lock = qdisc_root_lock(oqdisc);
+	root_lock = qdisc_lock(oqdisc);
 	spin_lock_bh(root_lock);
 
 	/* Prune old scheduler */
