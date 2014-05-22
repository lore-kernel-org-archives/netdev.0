From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] batman: fix a bogus warning from batadv_is_on_batman_iface()
Date: Thu, 22 May 2014 11:57:17 -0700
Message-ID: <1400785037-9963-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jet.chen@intel.com, "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:42100 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaEVS50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 14:57:26 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so2881942pab.34
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 11:57:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

batman tries to search dev->iflink to check if it's a batman interface,
but ->iflink could be 0, which is not a valid ifindex. It should just
avoid iflink == 0 case.

Reported-by: Jet Chen <jet.chen@intel.com>
Tested-by: Jet Chen <jet.chen@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Antonio Quartulli <antonio@open-mesh.com>
Cc: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index b851cc5..fbda6b5 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -83,7 +83,7 @@ static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
 		return true;
 
 	/* no more parents..stop recursion */
-	if (net_dev->iflink == net_dev->ifindex)
+	if (net_dev->iflink == 0 || net_dev->iflink == net_dev->ifindex)
 		return false;
 
 	/* recurse over the parent device */
