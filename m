From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH 1/2] netns: fix NULL-dereference in dev_net()
Date: Thu, 14 Aug 2008 15:27:25 -0400
Message-ID: <48A4871D.1030708@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090305040401090306060302"
Cc: netdev@vger.kernel.org, containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:47979 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753765AbYHNT12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 15:27:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090305040401090306060302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Change dev_net() to handle a NULL argument - return &init_net instead.

-Brian

Signed-off-by: Brian Haley <brian.haley@hp.com>
---


--------------090305040401090306060302
Content-Type: text/x-patch;
 name="dev_net1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dev_net1.patch"

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 488c56e..baf6517 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -781,10 +781,10 @@ static inline
 struct net *dev_net(const struct net_device *dev)
 {
 #ifdef CONFIG_NET_NS
-	return dev->nd_net;
-#else
-	return &init_net;
+	if (dev)
+		return dev->nd_net;
 #endif
+	return &init_net;
 }
 
 static inline


--------------090305040401090306060302--
