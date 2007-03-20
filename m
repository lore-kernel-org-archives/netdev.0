From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 03/31] [NETLINK]: Remove NLMSG_{NEW_ANSWER,CANCEL,END}
Date: Tue, 20 Mar 2007 19:54:13 -0300
Message-ID: <20070320225413.GP17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:25953 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbXCTWy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 18:54:26 -0400
Received: by wx-out-0506.google.com with SMTP id h31so60697wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 15:54:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not used anywhere and defined inside __KERNEL__, Thomas acked this on irc.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/netlink.h |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 36629ff..0d11f6a 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -229,18 +229,6 @@ __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 #define NLMSG_PUT(skb, pid, seq, type, len) \
 	NLMSG_NEW(skb, pid, seq, type, len, 0)
 
-#define NLMSG_NEW_ANSWER(skb, cb, type, len, flags) \
-	NLMSG_NEW(skb, NETLINK_CB((cb)->skb).pid, \
-		  (cb)->nlh->nlmsg_seq, type, len, flags)
-
-#define NLMSG_END(skb, nlh) \
-({	(nlh)->nlmsg_len = skb_tail_pointer(skb) - (unsigned char *)(nlh); \
-	(skb)->len; })

-#define NLMSG_CANCEL(skb, nlh) \
-({	skb_trim(skb, (unsigned char *) (nlh) - (skb)->data); \
-	-1; })
-
 extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 			      struct nlmsghdr *nlh,
 			      int (*dump)(struct sk_buff *skb, struct netlink_callback*),
-- 
1.5.0.3

