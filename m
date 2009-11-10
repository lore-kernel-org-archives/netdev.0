From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/10] CAN: use dev_get_by_index_rcu
Date: Tue, 10 Nov 2009 09:54:56 -0800
Message-ID: <20091110175647.824581805@vyatta.com>
References: <20091110175446.280423729@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lothar Wassmann <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49507 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752456AbZKJSJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:09:39 -0500
Content-Disposition: inline; filename=bcm-dev-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use new function to avoid doing read_lock().

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/can/bcm.c	2009-11-10 09:45:16.301376272 -0800
+++ b/net/can/bcm.c	2009-11-10 09:46:30.125005956 -0800
@@ -139,13 +139,13 @@ static char *bcm_proc_getifname(char *re
 	if (!ifindex)
 		return "any";
 
-	read_lock(&dev_base_lock);
-	dev = __dev_get_by_index(&init_net, ifindex);
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(&init_net, ifindex);
 	if (dev)
 		strcpy(result, dev->name);
 	else
 		strcpy(result, "???");
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 
 	return result;
 }

-- 

