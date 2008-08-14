From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix unlocking in tc_ctl_tfilter()
Date: Fri, 15 Aug 2008 01:27:09 +0200
Message-ID: <20080814232708.GB2517@ami.dom.local>
References: <20080814224129.GA2517@ami.dom.local> <200808150156.49541.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:52103 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbYHNX1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 19:27:14 -0400
Received: by ug-out-1314.google.com with SMTP id m2so69645uge.1
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 16:27:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808150156.49541.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2008 at 01:56:49AM +0300, Denys Fedoryshchenko wrote:
> Aug 15 01:54:49 194.146.153.146 [   57.428359]
> Aug 15 01:54:49 194.146.153.146 [   57.428449] 
> =============================================
> Aug 15 01:54:49 194.146.153.146 [   57.428692] [ INFO: possible recursive 
> locking detected ]
> Aug 15 01:54:49 194.146.153.146 [   57.429018] 2.6.27-rc3-git2-build-0030 #7
...

I hope this is it... otherwise I'll be back "tomorrow".

Thanks again,
Jarek P.
------------------->

pkt_sched: Fix unlocking in tc_ctl_tfilter()

Fix a bug with spin_lock_bh() inserted instead of spin_unlock_bh() by
some recent patch. 


Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/cls_api.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index d2b6f54..5cafdd4 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -280,7 +280,7 @@ replay:
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
 			spin_lock_bh(root_lock);
 			*back = tp->next;
-			spin_lock_bh(root_lock);
+			spin_unlock_bh(root_lock);
 
 			tfilter_notify(skb, n, tp, fh, RTM_DELTFILTER);
 			tcf_destroy(tp);
