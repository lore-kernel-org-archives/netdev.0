From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH] net: ipv6: make "ip -6 route get mark xyz" work.
Date: Thu, 15 May 2014 16:38:41 -0700
Message-ID: <1400197121-16033-1-git-send-email-lorenzo@google.com>
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:36549 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbaEOXiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 19:38:50 -0400
Received: by mail-pb0-f50.google.com with SMTP id ma3so1740552pbc.9
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 16:38:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, "ip -6 route get mark xyz" ignores the mark passed in
by userspace. Make it honour the mark, just like IPv4 does.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv6/route.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f0a8ff9..8784d3a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2709,6 +2709,9 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh)
 	if (tb[RTA_OIF])
 		oif = nla_get_u32(tb[RTA_OIF]);
 
+	if (tb[RTA_MARK])
+		fl6.flowi6_mark = nla_get_u32(tb[RTA_MARK]);
+
 	if (iif) {
 		struct net_device *dev;
 		int flags = 0;
-- 
1.9.1.423.g4596e3a
