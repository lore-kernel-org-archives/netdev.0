From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] netxen: build fix for INET=n
Date: Fri, 11 Sep 2009 15:41:04 -0700
Message-ID: <20090911154104.1804a82f.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Dhananjay Phadke <dhananjay@netxen.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:58707 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435AbZIKWlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 18:41:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

When CONFIG_INET is disabled, netxen has a build failure:

netxen_nic_main.c:(.text+0x118fd1): undefined reference to `netxen_config_indev_addr'

so make that function just an empty stub when CONFIG_INET=n.
(not "inline" since that conflicts with other declarations of it)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/netxen/netxen_nic_main.c |    4 ++++
 1 file changed, 4 insertions(+)

--- linux-next-20090911.orig/drivers/net/netxen/netxen_nic_main.c
+++ linux-next-20090911/drivers/net/netxen/netxen_nic_main.c
@@ -2450,6 +2450,10 @@ static struct notifier_block	netxen_netd
 static struct notifier_block netxen_inetaddr_cb = {
 	.notifier_call = netxen_inetaddr_event,
 };
+#else
+static void
+netxen_config_indev_addr(struct net_device *dev, unsigned long event)
+{ }
 #endif
 
 static struct pci_driver netxen_driver = {




---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
