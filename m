From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] ipmr: remove useless checks from ipmr_device_event
Date: Wed, 17 Feb 2010 14:19:32 +0300
Message-ID: <4B7BD0C4.3090304@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7028 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752747Ab0BQLku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 06:40:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The net being checked there is dev_net(dev) and thus this if
is always false.

Fits both net and net-next trees.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 54596f7..8582e12 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1163,9 +1163,6 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 	int ct;
 	LIST_HEAD(list);
 
-	if (!net_eq(dev_net(dev), net))
-		return NOTIFY_DONE;
-
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
 	v = &net->ipv4.vif_table[0];
