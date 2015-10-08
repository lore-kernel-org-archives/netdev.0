From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: gre: setup default multicast routes over PtP links
Date: Thu,  8 Oct 2015 18:19:39 +0200
Message-ID: <1444321179-26425-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julien Muchembled <jm@jmuchemb.eu>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dumazet <ndumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:38684 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934131AbbJHQTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 12:19:48 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 75D7220798
	for <netdev@vger.kernel.org>; Thu,  8 Oct 2015 12:19:47 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE point-to-point interfaces should also support ipv6 multicast. Setting
up default multicast routes on interface creation was forgotten. Add it.

Bugzilla: <https://bugzilla.kernel.org/show_bug.cgi?id=103231>
Cc: Julien Muchembled <jm@jmuchemb.eu>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Nicolas Dumazet <ndumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c8380f1..3aed22f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3119,6 +3119,8 @@ static void addrconf_gre_config(struct net_device *dev)
 	}
 
 	addrconf_addr_gen(idev, true);
+	if (dev->flags & IFF_POINTOPOINT)
+		addrconf_add_mroute(dev);
 }
 #endif
 
-- 
2.5.0
