From: Thomas Hisch <t.hisch@gmail.com>
Subject: [PATCH] ipv4: remove a call to skb_queue_len() in inet_diag.c
Date: Sun, 4 Feb 2007 16:34:54 +0100
Message-ID: <20070204153454.GA6098@unknown-00-0d-60-79-ca-00.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:4510 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbXBDPfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Feb 2007 10:35:03 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1106265uga
        for <netdev@vger.kernel.org>; Sun, 04 Feb 2007 07:35:01 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


remove unneeded call to skb_queue_len (skb_dequeue already checks queuelen) and
replace a sizeof() by a Netlink Macro

Signed-off-by: Thomas Hisch <t.hisch@gmail.com>
---

sorry, my previous version of this patch didn't conform to the Codingstyle document.
now everything should be fine.

 net/ipv4/inet_diag.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 77761ac..9cf27c7 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -846,7 +846,7 @@ static inline void inet_diag_rcv_skb(struct sk_buff *skb)
 		int err;
 		struct nlmsghdr *nlh = (struct nlmsghdr *)skb->data;
 
-		if (nlh->nlmsg_len < sizeof(*nlh) ||
+		if (nlh->nlmsg_len < NLMSG_HDRLEN ||
 		    skb->len < nlh->nlmsg_len)
 			return;
 		err = inet_diag_rcv_msg(skb, nlh);
@@ -858,9 +858,8 @@ static inline void inet_diag_rcv_skb(struct sk_buff *skb)
 static void inet_diag_rcv(struct sock *sk, int len)
 {
 	struct sk_buff *skb;
-	unsigned int qlen = skb_queue_len(&sk->sk_receive_queue);
 
-	while (qlen-- && (skb = skb_dequeue(&sk->sk_receive_queue))) {
+	while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
 		inet_diag_rcv_skb(skb);
 		kfree_skb(skb);
 	}
-- 
1.5.0.rc3.22.g5057
