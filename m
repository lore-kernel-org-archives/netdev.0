From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 8/8] netpoll header cleanup
Date: Thu, 26 Oct 2006 15:46:56 -0700
Message-ID: <20061026225646.715591031@osdl.org>
References: <20061026225535.443288276@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15803 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423692AbWJZXBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:01:05 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netpoll-header.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As Steve left netpoll beast, hopefully not to return soon.
He noticed that the header was messy. He straightened it
up and polished it a little, then waved goodbye.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 include/linux/netpoll.h |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

--- linux-2.6.orig/include/linux/netpoll.h
+++ linux-2.6/include/linux/netpoll.h
@@ -12,16 +12,15 @@
 #include <linux/rcupdate.h>
 #include <linux/list.h>
 
-struct netpoll;
-
 struct netpoll {
 	struct net_device *dev;
-	char dev_name[16], *name;
+	char dev_name[IFNAMSIZ];
+	const char *name;
 	void (*rx_hook)(struct netpoll *, int, char *, int);
 
 	u32 local_ip, remote_ip;
 	u16 local_port, remote_port;
-	unsigned char local_mac[6], remote_mac[6];
+ 	u8 local_mac[ETH_ALEN], remote_mac[ETH_ALEN];
 };
 
 struct netpoll_info {

--
Stephen Hemminger <shemminger@osdl.org>

