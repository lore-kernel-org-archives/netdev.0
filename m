From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] netlink: fix netlink_ack with large messages
Date: Thu,  7 Nov 2013 19:57:45 +0100
Message-ID: <9333f540a9b87adbdd15e274d12a9d60994fdb34.1383850578.git.jbenc@redhat.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752249Ab3KGTAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 14:00:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c05cdb1b864f ("netlink: allow large data transfers from user-space")
does not handle cases where netlink_ack is used to report an error. In such
case, the original message is copied to the ack message, which needs to be
large enough.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/netlink/af_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8df7f64..090f624 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1809,7 +1809,7 @@ out_put:
 	sock_put(sk);
 out:
 #endif
-	return alloc_skb(size, gfp_mask);
+	return netlink_alloc_large_skb(size, gfp_mask);
 }
 EXPORT_SYMBOL_GPL(netlink_alloc_skb);
 
-- 
1.7.6.5
