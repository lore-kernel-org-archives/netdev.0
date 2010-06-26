From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 1/2] ipv6: Clamp reported valid_lft to a minimum of 0
Date: Sat, 26 Jun 2010 22:37:47 +0100
Message-ID: <1277588267.26161.300.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, 514644@bugs.debian.org,
	Piotr Lewandowski <piotr.lewandowski@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57622 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753669Ab0FZViI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jun 2010 17:38:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since addresses are only revalidated every 2 minutes, the reported
valid_lft can underflow shortly before the address is deleted.
Clamp it to a minimum of 0, as for prefered_lft.

Reported-by: Piotr Lewandowski <piotr.lewandowski@gmail.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This is compile-tested only.  I don't claim any familiarity with this
code.

Ben.

 net/ipv6/addrconf.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b97bb1f..1459eed 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3492,8 +3492,12 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 				preferred -= tval;
 			else
 				preferred = 0;
-			if (valid != INFINITY_LIFE_TIME)
-				valid -= tval;
+			if (valid != INFINITY_LIFE_TIME) {
+				if (valid > tval)
+					valid -= tval;
+				else
+					valid = 0;
+			}
 		}
 	} else {
 		preferred = INFINITY_LIFE_TIME;
-- 
1.7.1



