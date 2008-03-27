From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/2 net-2.6.26] [NETNS]: Do no include NET related headers if CONFIG_NET is not set.
Date: Thu, 27 Mar 2008 13:29:57 +0300
Message-ID: <1206613797-32045-2-git-send-email-den@openvz.org>
References: <20080327.022206.100283150.davem@davemloft.net>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	yoshfuji@linux-ipv6.org, --cc@sw.ru,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:59097 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756791AbYC0K30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 06:29:26 -0400
In-Reply-To: <20080327.022206.100283150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fix broken compilation for 'allnoconfig'. This was introduced by
Introduced by commit 1218854afa6f659be90b748cf1bc7badee954a35 ("[NET]
NETNS: Omit seq_net_private->net without CONFIG_NET_NS.")

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 lib/kobject_uevent.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 5a402e2..0d56dad 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -15,12 +15,16 @@
  */
 
 #include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/kobject.h>
+#include <linux/module.h>
+
+#ifdef CONFIG_NET
 #include <linux/socket.h>
 #include <linux/skbuff.h>
 #include <linux/netlink.h>
-#include <linux/string.h>
-#include <linux/kobject.h>
 #include <net/sock.h>
+#endif
 
 
 u64 uevent_seqnum;
-- 
1.5.3.rc5

