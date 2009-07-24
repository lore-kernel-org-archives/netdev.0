From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ip: fix logic of reverse path filter sysctl
Date: Fri, 24 Jul 2009 12:30:05 -0700
Message-ID: <20090724123005.35450325@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52241 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750979AbZGXTaL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2009 15:30:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even though reverse path filter was changed from simple boolean to trinary control,
the loose mode only works if both all and device are configured because of
this logic error.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/inetdevice.h	2009-07-24 12:24:54.537399657 -0700
+++ b/include/linux/inetdevice.h	2009-07-24 12:25:11.457119906 -0700
@@ -82,7 +82,7 @@ static inline void ipv4_devconf_setall(s
 
 #define IN_DEV_FORWARD(in_dev)		IN_DEV_CONF_GET((in_dev), FORWARDING)
 #define IN_DEV_MFORWARD(in_dev)		IN_DEV_ANDCONF((in_dev), MC_FORWARDING)
-#define IN_DEV_RPFILTER(in_dev)		IN_DEV_ANDCONF((in_dev), RP_FILTER)
+#define IN_DEV_RPFILTER(in_dev)		IN_DEV_MAXCONF((in_dev), RP_FILTER)
 #define IN_DEV_SOURCE_ROUTE(in_dev)	IN_DEV_ANDCONF((in_dev), \
 						       ACCEPT_SOURCE_ROUTE)
 #define IN_DEV_BOOTP_RELAY(in_dev)	IN_DEV_ANDCONF((in_dev), BOOTP_RELAY)
