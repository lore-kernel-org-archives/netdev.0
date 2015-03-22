From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next v2 1/3] net core: Add IFF_PROTO_DOWN support.
Date: Sat, 21 Mar 2015 21:06:56 -0700
Message-ID: <1426997218-27313-2-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35771 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbbCVEHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 00:07:07 -0400
Received: by pdbop1 with SMTP id op1so150090462pdb.2
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2015 21:07:06 -0700 (PDT)
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
 net/core/dev.c          |    2 +-
 2 files changed, 5 insertions(+), 1 deletion(-)

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
diff --git a/net/core/dev.c b/net/core/dev.c
index 39fe369..bcefa17 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5684,7 +5684,7 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 
 	dev->flags = (flags & (IFF_DEBUG | IFF_NOTRAILERS | IFF_NOARP |
 			       IFF_DYNAMIC | IFF_MULTICAST | IFF_PORTSEL |
-			       IFF_AUTOMEDIA)) |
+			       IFF_AUTOMEDIA | IFF_PROTO_DOWN)) |
 		     (dev->flags & (IFF_UP | IFF_VOLATILE | IFF_PROMISC |
 				    IFF_ALLMULTI));
 
-- 
1.7.10.4
