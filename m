From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25] Cleanup IN_DEV_MFORWARD macro
Date: Fri, 07 Dec 2007 19:19:38 +0300
Message-ID: <4759729A.4030403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41633 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752334AbXLGQUC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 11:20:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is essentially IN_DEV_ANDCONF with proper arguments.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index dd093ea..962a062 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -78,9 +78,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 	(max(IPV4_DEVCONF_ALL(attr), IN_DEV_CONF_GET((in_dev), attr)))
 
 #define IN_DEV_FORWARD(in_dev)		IN_DEV_CONF_GET((in_dev), FORWARDING)
-#define IN_DEV_MFORWARD(in_dev)		(IPV4_DEVCONF_ALL(MC_FORWARDING) && \
-					 IPV4_DEVCONF((in_dev)->cnf, \
-						      MC_FORWARDING))
+#define IN_DEV_MFORWARD(in_dev)		IN_DEV_ANDCONF((in_dev), MC_FORWARDING)
 #define IN_DEV_RPFILTER(in_dev)		IN_DEV_ANDCONF((in_dev), RP_FILTER)
 #define IN_DEV_SOURCE_ROUTE(in_dev)	IN_DEV_ANDCONF((in_dev), \
 						       ACCEPT_SOURCE_ROUTE)
-- 
1.5.3.4

