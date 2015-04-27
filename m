From: anuradhak@cumulusnetworks.com
Subject: [RFC PATCH net-next v3 1/4] net core: Add IFF_PROTO_DOWN support.
Date: Mon, 27 Apr 2015 10:38:21 -0700
Message-ID: <1430156304-13187-2-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34982 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbbD0Rid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:38:33 -0400
Received: by pabtp1 with SMTP id tp1so136351998pab.2
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 10:38:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

This patch introduces an IFF_PROTO_DOWN flag that can be used by
user space applications to notify drivers that errors have been
detected on the device.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 include/uapi/linux/if.h |    4 ++++
 net/8021q/vlan_dev.c    |    3 ++-
 net/core/dev.c          |    2 +-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 9cf2394..e263bd2 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -66,6 +66,8 @@
  * @IFF_LOWER_UP: driver signals L1 up. Volatile.
  * @IFF_DORMANT: driver signals dormant. Volatile.
  * @IFF_ECHO: echo sent packets. Volatile.
+ * @IFF_PROTO_DOWN: protocol is down on the interface. Can be toggled
+ *	through sysfs.
  */
 enum net_device_flags {
 	IFF_UP				= 1<<0,  /* sysfs */
@@ -87,6 +89,7 @@ enum net_device_flags {
 	IFF_LOWER_UP			= 1<<16, /* volatile */
 	IFF_DORMANT			= 1<<17, /* volatile */
 	IFF_ECHO			= 1<<18, /* volatile */
+	IFF_PROTO_DOWN			= 1<<19, /* sysfs */
 };
 
 #define IFF_UP				IFF_UP
@@ -108,6 +111,7 @@ enum net_device_flags {
 #define IFF_LOWER_UP			IFF_LOWER_UP
 #define IFF_DORMANT			IFF_DORMANT
 #define IFF_ECHO			IFF_ECHO
+#define IFF_PROTO_DOWN			IFF_PROTO_DOWN
 
 #define IFF_VOLATILE	(IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|IFF_ECHO|\
 		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT)
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 01d7ba8..7073ee1 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -537,7 +537,8 @@ static int vlan_dev_init(struct net_device *dev)
 
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
 	dev->flags  = real_dev->flags & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI |
-					  IFF_MASTER | IFF_SLAVE);
+					  IFF_MASTER | IFF_SLAVE |
+					  IFF_PROTO_DOWN);
 	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
diff --git a/net/core/dev.c b/net/core/dev.c
index af4a1b0..e9600fa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5725,7 +5725,7 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 
 	dev->flags = (flags & (IFF_DEBUG | IFF_NOTRAILERS | IFF_NOARP |
 			       IFF_DYNAMIC | IFF_MULTICAST | IFF_PORTSEL |
-			       IFF_AUTOMEDIA)) |
+			       IFF_AUTOMEDIA | IFF_PROTO_DOWN)) |
 		     (dev->flags & (IFF_UP | IFF_VOLATILE | IFF_PROMISC |
 				    IFF_ALLMULTI));
 
-- 
1.7.10.4
