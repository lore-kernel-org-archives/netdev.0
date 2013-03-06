From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] netlabel: correctly list all the static label mappings
Date: Wed, 06 Mar 2013 16:45:24 -0500
Message-ID: <20130306214524.4965.59796.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51117 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754591Ab3CFVp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 16:45:26 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r26LjPAX025798
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 6 Mar 2013 16:45:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we have a large number of static label mappings that spill across
the netlink message boundary we fail to properly save our state in the
netlink_callback struct which causes us to repeat the same listings.
This patch fixes this problem by saving the state correctly between
calls to the NetLabel static label netlink "dumpit" routines.

Signed-off-by: Paul Moore <pmoore@redhat.com>
Cc: stable@vger.kernel.org
---
 net/netlabel/netlabel_unlabeled.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 847d495..85742b7 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1250,10 +1250,10 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 
 unlabel_staticlist_return:
 	rcu_read_unlock();
-	cb->args[0] = skip_bkt;
-	cb->args[1] = skip_chain;
-	cb->args[2] = skip_addr4;
-	cb->args[3] = skip_addr6;
+	cb->args[0] = iter_bkt;
+	cb->args[1] = iter_chain;
+	cb->args[2] = iter_addr4;
+	cb->args[3] = iter_addr6;
 	return skb->len;
 }
 
@@ -1320,8 +1320,8 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 
 unlabel_staticlistdef_return:
 	rcu_read_unlock();
-	cb->args[0] = skip_addr4;
-	cb->args[1] = skip_addr6;
+	cb->args[0] = iter_addr4;
+	cb->args[1] = iter_addr6;
 	return skb->len;
 }
 
