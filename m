From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] netlink: no need to crash if table does not exist.
Date: Wed, 21 Mar 2007 13:44:56 +0300
Message-ID: <20070321104456.GA2637@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56643 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751970AbXCUKpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 06:45:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We would already do that on init.
Some things become very confused, when nl_table is not used to store
netlink sockets.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

23ebdcf1f439cde050a63f33897d5b099fe08c95
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 9b69d9b..071e4d7 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1330,8 +1330,6 @@ netlink_kernel_create(int unit, unsigned int groups,
 	struct netlink_sock *nlk;
 	unsigned long *listeners = NULL;
 
-	BUG_ON(!nl_table);
-
 	if (unit<0 || unit>=MAX_LINKS)
 		return NULL;
 

-- 
	Evgeniy Polyakov
