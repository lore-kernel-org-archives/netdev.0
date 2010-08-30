From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH] net/sched/sch_hfsc.c: initialize parent's cl_cfmin
 properly in init_vf()
Date: Mon, 30 Aug 2010 23:34:10 +0200
Message-ID: <8100ed4475ac7a301a3d69611e97d510ea498c5d.1283197803.git.soltys@ziu.info>
References: <cover.1283197803.git.soltys@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.ppgk.com.pl ([80.53.243.36]:9552 "EHLO relay.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754714Ab0H3Vm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 17:42:27 -0400
Content-Disposition: inline
In-Reply-To: <cover.1283197803.git.soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes init_vf() function, so on each new backlog period parent's
cl_cfmin is properly updated (including further propgation towards the root),
even if the activated leaf has no upperlimit curve defined.

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index abd904b..4749609 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -761,8 +761,8 @@ init_vf(struct hfsc_class *cl, unsigned int len)
 		if (f != cl->cl_f) {
 			cl->cl_f = f;
 			cftree_update(cl);
-			update_cfmin(cl->cl_parent);
 		}
+		update_cfmin(cl->cl_parent);
 	}
 }
 
-- 
1.7.2.1

