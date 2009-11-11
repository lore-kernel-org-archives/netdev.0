From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] [next-next-2.6] net: configurable device name hash
Date: Wed, 11 Nov 2009 21:16:14 +0200
Message-ID: <200911112116.14103.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:4482 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758125AbZKKTTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 14:19:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 0addd45..8a129d5 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -29,8 +29,7 @@ struct net_generic;
 struct sock;
 
 
-#define NETDEV_HASHBITS    8
-#define NETDEV_HASHENTRIES (1 << NETDEV_HASHBITS)
+#define NETDEV_HASHENTRIES (1 << CONFIG_NETDEV_HASHBITS)
 
 struct net {
 	atomic_t		count;		/* To decided when the network
diff --git a/net/Kconfig b/net/Kconfig
index 041c35e..f5db7b2 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -45,6 +45,13 @@ config COMPAT_NETLINK_MESSAGES
 
 menu "Networking options"
 
+config NETDEV_HASHBITS
+	int "Network device hash size"
+	range 8 20
+	default 8
+	help
+	  Select network device hash size as a power of 2.
+
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"

