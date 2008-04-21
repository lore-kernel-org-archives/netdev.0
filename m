From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NETNS]: Remove empty ->init callback.
Date: Mon, 21 Apr 2008 19:04:00 +0400
Message-ID: <480CACE0.4070109@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57478 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752640AbYDUPFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 11:05:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netns start-stop engine can happily live with any of
init or exit callbacks set to NULL.

Isn't it too late to merge this one?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8a0fd40..e591e09 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4338,12 +4338,6 @@ int unregister_inet6addr_notifier(struct notifier_block *nb)
 
 EXPORT_SYMBOL(unregister_inet6addr_notifier);
 
-
-static int addrconf_net_init(struct net *net)
-{
-	return 0;
-}
-
 static void addrconf_net_exit(struct net *net)
 {
 	struct net_device *dev;
@@ -4360,7 +4354,6 @@ static void addrconf_net_exit(struct net *net)
 }
 
 static struct pernet_operations addrconf_net_ops = {
-	.init = addrconf_net_init,
 	.exit = addrconf_net_exit,
 };
 
