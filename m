From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 14/16] [WIRELESS]: Convert notifications to use rtnl_notify()
Date: Mon, 14 Aug 2006 00:00:14 +0200
Message-ID: <20060814214343.438760867@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:25550 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964991AbWHNVp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:45:27 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_convert_wireless
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/core/wireless.c
===================================================================
--- net-2.6.19.git.orig/net/core/wireless.c
+++ net-2.6.19.git/net/core/wireless.c
@@ -85,6 +85,7 @@
 
 #include <linux/wireless.h>		/* Pretty obvious */
 #include <net/iw_handler.h>		/* New driver API */
+#include <net/netlink.h>
 
 #include <asm/uaccess.h>		/* copy_to_user() */
 
@@ -1849,7 +1850,7 @@ static void wireless_nlevent_process(uns
 	struct sk_buff *skb;
 
 	while ((skb = skb_dequeue(&wireless_nlevent_queue)))
-		netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK, GFP_ATOMIC);
+		rtnl_notify(skb, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
 }
 
 static DECLARE_TASKLET(wireless_nlevent_tasklet, wireless_nlevent_process, 0);

