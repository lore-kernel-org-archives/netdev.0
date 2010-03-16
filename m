From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6] bridge br_multicast: Fix handling of Max Response Code in IGMPv3 message.
Date: Tue, 16 Mar 2010 14:27:00 +0900
Message-ID: <201003160527.o2G5R0nS010812@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36770 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587Ab0CPF1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 01:27:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/bridge/br_multicast.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 4095192..bbbd996 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -851,8 +851,8 @@ static int br_multicast_query(struct net_bridge *br,
 		if (ih3->nsrcs)
 			goto out;
 
-		max_delay = ih3->code ? 1 :
-			    IGMPV3_MRC(ih3->code) * (HZ / IGMP_TIMER_SCALE);
+		max_delay = ih3->code ?
+			    IGMPV3_MRC(ih3->code) * (HZ / IGMP_TIMER_SCALE) : 1;
 	}
 
 	if (!group)
-- 
1.5.6.5

