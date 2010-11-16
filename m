From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH net-next 2/4] inet: Define IPV4_DEVCONF_MAX
Date: Tue, 16 Nov 2010 09:31:20 -0500
Message-ID: <20101116143120.GB26669@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:46857 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933047Ab0KPObU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 09:31:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define IPV4_DEVCONF_MAX to get rid of MAX - 1 notation.

Signed-off-by: Thomas Graf <tgraf@infradead.org>

Index: net-next-2.6/include/linux/inetdevice.h
===================================================================
--- net-next-2.6.orig/include/linux/inetdevice.h
+++ net-next-2.6/include/linux/inetdevice.h
@@ -41,10 +41,12 @@ enum
 	__IPV4_DEVCONF_MAX
 };
 
+#define IPV4_DEVCONF_MAX (__IPV4_DEVCONF_MAX - 1)
+
 struct ipv4_devconf {
 	void	*sysctl;
-	int	data[__IPV4_DEVCONF_MAX - 1];
-	DECLARE_BITMAP(state, __IPV4_DEVCONF_MAX - 1);
+	int	data[IPV4_DEVCONF_MAX];
+	DECLARE_BITMAP(state, IPV4_DEVCONF_MAX);
 };
 
 struct in_device {
@@ -90,7 +92,7 @@ static inline void ipv4_devconf_set(stru
 
 static inline void ipv4_devconf_setall(struct in_device *in_dev)
 {
-	bitmap_fill(in_dev->cnf.state, __IPV4_DEVCONF_MAX - 1);
+	bitmap_fill(in_dev->cnf.state, IPV4_DEVCONF_MAX);
 }
 
 #define IN_DEV_CONF_GET(in_dev, attr) \
