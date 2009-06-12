From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH] ipv4: update ARPD help text
Date: Fri, 12 Jun 2009 08:38:02 +0300
Message-ID: <1244785082-7883-1-git-send-email-timo.teras@iki.fi>
References: <20090611.205906.215886308.davem@davemloft.net>
Cc: Timo Teras <timo.teras@iki.fi>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:43394 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656AbZFLFiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 01:38:01 -0400
Received: by ewy6 with SMTP id 6so2669290ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 22:38:01 -0700 (PDT)
In-Reply-To: <20090611.205906.215886308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed the statements about ARP cache size as this config option does
not affect it. The cache size is controlled by neigh_table gc thresholds.

Remove also expiremental and obsolete markings as the API originally
intended for arp caching is useful for implementing ARP-like protocols
(e.g. NHRP) in user space and has been there for a long enough time.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/ipv4/Kconfig |   35 +++++++++++++----------------------
 1 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 5b919f7..70491d9 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -273,29 +273,20 @@ config IP_PIMSM_V2
 	  you want to play with it.
 
 config ARPD
-	bool "IP: ARP daemon support (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
+	bool "IP: ARP daemon support"
 	---help---
-	  Normally, the kernel maintains an internal cache which maps IP
-	  addresses to hardware addresses on the local network, so that
-	  Ethernet/Token Ring/ etc. frames are sent to the proper address on
-	  the physical networking layer. For small networks having a few
-	  hundred directly connected hosts or less, keeping this address
-	  resolution (ARP) cache inside the kernel works well. However,
-	  maintaining an internal ARP cache does not work well for very large
-	  switched networks, and will use a lot of kernel memory if TCP/IP
-	  connections are made to many machines on the network.
-
-	  If you say Y here, the kernel's internal ARP cache will never grow
-	  to more than 256 entries (the oldest entries are expired in a LIFO
-	  manner) and communication will be attempted with the user space ARP
-	  daemon arpd. Arpd then answers the address resolution request either
-	  from its own cache or by asking the net.
-
-	  This code is experimental and also obsolete. If you want to use it,
-	  you need to find a version of the daemon arpd on the net somewhere,
-	  and you should also say Y to "Kernel/User network link driver",
-	  below. If unsure, say N.
+	  The kernel maintains an internal cache which maps IP addresses to
+	  hardware addresses on the local network, so that Ethernet/Token Ring/
+	  etc. frames are sent to the proper address on the physical networking
+	  layer. Normally, kernel uses the ARP protocol to resolve these
+	  mappings.
+
+	  Saying Y here adds support to have an user space daemon to do this
+	  resolution instead. This is useful for implementing an alternate
+	  address resolution protocol (e.g. NHRP on mGRE tunnels) and also for
+	  testing purposes.
+
+	  If unsure, say N.
 
 config SYN_COOKIES
 	bool "IP: TCP syncookie support (disabled per default)"
-- 
1.6.0.4

