From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH] net: rtnetlink: ignore NETDEV_PRE_TYPE_CHANGE in rtnetlink_event()
Date: Fri, 19 Mar 2010 15:42:24 +0100
Message-ID: <4BA38D50.4090909@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050902030907010302060507"
Cc: jpirko@redhat.com, Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39250 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab0CSOm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 10:42:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050902030907010302060507
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit



--------------050902030907010302060507
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

Ignore the new NETDEV_PRE_TYPE_CHANGE event in rtnetlink_event() since
there have been no changes userspace needs to be notified of.

Also add a comment to the netdev notifier event definitions to remind
people to update the exclusion list when adding new event types.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/notifier.h |    5 ++++-
 net/core/rtnetlink.c     |    1 +
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index f3635fc..9c5d3fa 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -182,7 +182,10 @@ static inline int notifier_to_errno(int ret)
  *	VC switch chains (for loadable kernel svgalib VC switch helpers) etc...
  */
  
-/* netdevice notifier chain */
+/* netdevice notifier chain. Please remember to update the rtnetlink
+ * notification exclusion list in rtnetlink_event() when adding new
+ * types.
+ */
 #define NETDEV_UP	0x0001	/* For now you can't veto a device up/down */
 #define NETDEV_DOWN	0x0002
 #define NETDEV_REBOOT	0x0003	/* Tell a protocol stack a network interface
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e1121f0..ffc6cf3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1513,6 +1513,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_POST_INIT:
 	case NETDEV_REGISTER:
 	case NETDEV_CHANGE:
+	case NETDEV_PRE_TYPE_CHANGE:
 	case NETDEV_GOING_DOWN:
 	case NETDEV_UNREGISTER:
 	case NETDEV_UNREGISTER_BATCH:
-- 
1.6.5.7


--------------050902030907010302060507--
