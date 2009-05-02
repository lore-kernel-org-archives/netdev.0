From: Robert Love <robert.w.love@intel.com>
Subject: [PATCH] net: Only store high 16 bits of kernel generated filter
	priorities
Date: Sat, 02 May 2009 13:43:20 -0700
Message-ID: <20090502204320.6332.39868.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, robert.w.love@intel.com,
	jeffrey.t.kirsher@intel.com
To: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50222 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751527AbZEBUnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2009 16:43:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel should only be using the high 16 bits of a kernel
generated priority. Filter priorities in all other cases only
use the upper 16 bits of the u32 'prio' field of 'struct tcf_proto',
but when the kernel generates the priority of a filter is saves all
32 bits which can result in incorrect lookup failures when a filter
needs to be deleted or modified.

Signed-off-by: Robert Love <robert.w.love@intel.com>
---

 net/sched/cls_api.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 173fcc4..0759f32 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -254,7 +254,7 @@ replay:
 		}
 		tp->ops = tp_ops;
 		tp->protocol = protocol;
-		tp->prio = nprio ? : tcf_auto_prio(*back);
+		tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(*back));
 		tp->q = q;
 		tp->classify = tp_ops->classify;
 		tp->classid = parent;

