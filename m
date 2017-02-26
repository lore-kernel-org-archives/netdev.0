From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipv4: mask tos for input route
Date: Sun, 26 Feb 2017 17:14:35 +0200
Message-ID: <1488122075-23952-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51739 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752258AbdBZPRv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 26 Feb 2017 10:17:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restore the lost masking of TOS in input route code to
allow ip rules to match it properly.

Problem [1] noticed by Shmulik Ladkani <shmulik.ladkani@gmail.com>

[1] http://marc.info/?t=137331755300040&r=1&w=2

Fixes: 89aef8921bfb ("ipv4: Delete routing cache.")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/route.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 584ed66..8471dd1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2009,6 +2009,7 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 {
 	int res;
 
+	tos &= IPTOS_RT_MASK;
 	rcu_read_lock();
 
 	/* Multicast recognition logic is moved from route cache to here.
-- 
1.9.3
