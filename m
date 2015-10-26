From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: recreate ipv6 link-local addresses when increasing MTU over IPV6_MIN_MTU
Date: Mon, 26 Oct 2015 15:36:45 +0100
Message-ID: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:56543 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753924AbbJZOg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 10:36:56 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id A5F8A20A4A
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 10:36:55 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take into consideration that the interface might be disabled for IPv6,
thus switch event type.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d0c685c..c2dcebe 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3149,6 +3149,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 
 	case NETDEV_UP:
 	case NETDEV_CHANGE:
+netdev_change:
 		if (dev->flags & IFF_SLAVE)
 			break;
 
@@ -3244,8 +3245,10 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 
 		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
 			idev = ipv6_add_dev(dev);
-			if (!IS_ERR(idev))
-				break;
+			if (!IS_ERR(idev)) {
+				event = NETDEV_UP;
+				goto netdev_change;
+			}
 		}
 
 		/*
-- 
2.5.0
