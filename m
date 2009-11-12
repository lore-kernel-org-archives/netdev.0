From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: [PATCH] inet: fix inet_bind_bucket_for_each
Date: Thu, 12 Nov 2009 17:07:26 +0200
Message-ID: <200911121707.26224.lgrijincu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_uSC/KDsxHcq8Zq3"
To: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:7476 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752768AbZKLPHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 10:07:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--Boundary-00=_uSC/KDsxHcq8Zq3
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit


The first "node" is supposed to be the cursor used in the for_each.

The second "node" is ment literally and should not be macro expanded:
it's the name of the hlist_node field from the inet_bind_bucket.

This currently works because when inet_bind_bucket_for_each is called
it's argument is still "node".

Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
---
 include/net/inet_hashtables.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


--Boundary-00=_uSC/KDsxHcq8Zq3
Content-Type: text/plain;
  charset="utf-8";
  name="0001-inet-fix-inet_bind_bucket_for_each.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="0001-inet-fix-inet_bind_bucket_for_each.patch"

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 5b698b3..41cbddd 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -92,8 +92,8 @@ static inline struct net *ib_net(struct inet_bind_bucket *ib)
 	return read_pnet(&ib->ib_net);
 }
 
-#define inet_bind_bucket_for_each(tb, node, head) \
-	hlist_for_each_entry(tb, node, head, node)
+#define inet_bind_bucket_for_each(tb, pos, head) \
+	hlist_for_each_entry(tb, pos, head, node)
 
 struct inet_bind_hashbucket {
 	spinlock_t		lock;

--Boundary-00=_uSC/KDsxHcq8Zq3--


