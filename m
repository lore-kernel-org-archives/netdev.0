From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] net: reduce RECURSION_LIMIT to 8
Date: Thu,  7 Jan 2016 18:40:53 +0100
Message-ID: <1452188453-5523-1-git-send-email-hannes@stressinduktion.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:48859 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751220AbcAGRlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 12:41:01 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id BFFA221658
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2016 12:41:00 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When RECURSION_LIMIT was first introduced, Eric proposed a limit of 3.
This limit was later raised to 10 by DaveM. Nowadays it is observed that
configuraion errors in openvswitch cause the STACK_END_MAGIC to be
overwritten shortly after 9 recursion.

This patch tries to be conservative and reduces the limit to 8 without
further measurements. It seems ovs uses the stack more than other parts
of the networking stack - I couldn't bring the system down with a non-ovs
tunneling setup.

Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
I don't do crazy run-time estimation of the stack size for one recursion
and try automatically to come up with a limit per arch or kconfig
settings, as I assume that all systems should behave the same regarding
the recursion maximum. All configurations should run on all kinds of
systems. I consider 8 recursions to be plenty enough for the time being.

 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ae00b894e67555..d93da7df84325d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2941,7 +2941,7 @@ static void skb_update_prio(struct sk_buff *skb)
 DEFINE_PER_CPU(int, xmit_recursion);
 EXPORT_SYMBOL(xmit_recursion);
 
-#define RECURSION_LIMIT 10
+#define RECURSION_LIMIT 8
 
 /**
  *	dev_loopback_xmit - loop back @skb
-- 
2.5.0
