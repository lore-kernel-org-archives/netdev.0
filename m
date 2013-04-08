From: Antonio Quartulli <antonio@open-mesh.com>
Subject: [PATCH 1/3] if.h: add IFF_BRIDGE_RESTRICTED flag
Date: Mon, 8 Apr 2013 19:41:01 +0200
Message-ID: <1365442863-32394-2-git-send-email-antonio@open-mesh.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	Antonio Quartulli <antonio@open-mesh.com>
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht1.myhostedexchange.com ([69.50.2.37]:59980 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934859Ab3DHRsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 13:48:22 -0400
In-Reply-To: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new flag tells whether a network device has to be
considered as restricted in the new bridge forwarding logic.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
---
 include/uapi/linux/if.h | 1 +
 net/core/dev.c          | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 1ec407b..5c3a9bd 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -83,6 +83,7 @@
 #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
 #define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware address
 					 * change when it's running */
+#define IFF_BRIDGE_RESTRICTED 0x200000	/* device is bridge-restricted */
 
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/core/dev.c b/net/core/dev.c
index 3655ff9..49eafc8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4627,7 +4627,7 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 
 	dev->flags = (flags & (IFF_DEBUG | IFF_NOTRAILERS | IFF_NOARP |
 			       IFF_DYNAMIC | IFF_MULTICAST | IFF_PORTSEL |
-			       IFF_AUTOMEDIA)) |
+			       IFF_AUTOMEDIA | IFF_BRIDGE_RESTRICTED)) |
 		     (dev->flags & (IFF_UP | IFF_VOLATILE | IFF_PROMISC |
 				    IFF_ALLMULTI));
 
-- 
1.8.1.5
