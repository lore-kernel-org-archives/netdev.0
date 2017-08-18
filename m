From: gfree.wind@vip.163.com
Subject: [PATCH net-next] net: sched: Add the invalid handle check in qdisc_class_find
Date: Fri, 18 Aug 2017 15:23:24 +0800
Message-ID: <1503041004-105572-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m181-177.vip.163.com ([123.58.177.181]:51060 "EHLO
        m181-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdHRHXm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 03:23:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

Add the invalid handle "0" check to avoid unnecessary search, because
the qdisc uses the skb->priority as the handle value to look up, and
it is "0" usually.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 include/net/sch_generic.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 5865db9..107c524 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -393,6 +393,9 @@ static inline unsigned int qdisc_class_hash(u32 id, u32 mask)
 	struct Qdisc_class_common *cl;
 	unsigned int h;
 
+	if (!id)
+		return NULL;
+
 	h = qdisc_class_hash(id, hash->hashmask);
 	hlist_for_each_entry(cl, &hash->hash[h], hnode) {
 		if (cl->classid == id)
-- 
1.9.1
