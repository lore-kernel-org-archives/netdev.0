From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: pkt_sched: add DRR scheduler
Date: Fri, 21 Nov 2008 12:19:49 +0000
Message-ID: <20081121121949.GA13892@ff.dom.local>
References: <20081120113557.GA5275@ff.dom.local> <49254D42.10506@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:44694 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568AbYKUMT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 07:19:58 -0500
Received: by ug-out-1314.google.com with SMTP id 39so86986ugf.37
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 04:19:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49254D42.10506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A small oversight:
----------------->
pkt_sched: sch_drr: Fix qlen in drr_drop()

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_drr.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 8d523d9..37e6ab9 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -406,6 +406,7 @@ static unsigned int drr_drop(struct Qdisc *sch)
 		if (cl->qdisc->ops->drop) {
 			len = cl->qdisc->ops->drop(cl->qdisc);
 			if (len > 0) {
+				sch->q.qlen--;
 				if (cl->qdisc->q.qlen == 0)
 					list_del(&cl->alist);
 				return len;
