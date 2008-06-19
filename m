From: WANG Cong <wcong@critical-links.com>
Subject: [Patch] net/sched/sch_generic.c: fix an error pointer
Date: Thu, 19 Jun 2008 15:37:14 +0100
Message-ID: <20080619153714.5614d5be@hack>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.critical-links.com ([62.28.57.164]:57544 "EHLO
	gate.critical-links.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757092AbYFSOwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 10:52:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ERR_PTR() ususally encodes an negative errno, not positive.

Note, in the following patch, 'err' is initialized as:

int err = -ENOBUFS;

Signed-off-by: WANG Cong <wcong@critical-links.com>
Cc: David Miller <davem@davemloft.net>
Cc:  Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

---
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index d355e5e..13afa72 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -468,7 +468,7 @@ struct Qdisc *qdisc_alloc(struct net_device *dev,
struct Qdisc_ops *ops) 
 	return sch;
 errout:
-	return ERR_PTR(-err);
+	return ERR_PTR(err);
 }
 
 struct Qdisc * qdisc_create_dflt(struct net_device *dev, struct
Qdisc_ops *ops,
