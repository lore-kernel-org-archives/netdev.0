From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] ipv4: fib: fix a comment.
Date: Fri, 11 Jan 2013 21:59:20 +0200
Message-ID: <1357934360-17986-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:39968 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826Ab3AKUAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 15:00:37 -0500
Received: by mail-ee0-f52.google.com with SMTP id b15so605598eek.25
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2013 12:00:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In fib_frontend.c, there is a confusing comment; NETLINK_CB(skb).portid does not 
refer to a pid of sending process, but rather to a netlink portid.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/ipv4/fib_frontend.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 5cd75e2..99f00d3 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -974,7 +974,7 @@ static void nl_fib_input(struct sk_buff *skb)
 
 	nl_fib_lookup(frn, tb);
 
-	portid = NETLINK_CB(skb).portid;      /* pid of sending process */
+	portid = NETLINK_CB(skb).portid;      /* netlink portid */
 	NETLINK_CB(skb).portid = 0;        /* from kernel */
 	NETLINK_CB(skb).dst_group = 0;  /* unicast */
 	netlink_unicast(net->ipv4.fibnl, skb, portid, MSG_DONTWAIT);
-- 
1.7.11.7
