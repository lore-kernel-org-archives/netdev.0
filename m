From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [RFC PATCH] net: ipv4: increase dhcp inter device timeout
Date: Fri, 7 Aug 2015 11:59:30 +0530
Message-ID: <1438928970-23908-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:48669 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949AbbHGGaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2015 02:30:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a system has multiple ethernet devices and during DHCP
request (for using NFS), the system waits only for HZ/2 which is
500mS before switching to another interface for DHCP.

There are some routers (Ex: Trendnet routers) which responds to
DHCP request at about 560mS. When the system has only one
ethernet interface there is no issue as the timeout is 2S and the
dev xid doesn't change and only retries.

But when the system has multiple Ethernet like DRA74x with CPSW
in dual EMAC mode, the DHCP response is dropped as the dev xid
changes while shifting to the next device. So changing inter
device timeout to HZ (which is 1S).

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 net/ipv4/ipconfig.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 8e7328c..bdb8cb5 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -94,7 +94,7 @@
 /* Define the timeout for waiting for a DHCP/BOOTP/RARP reply */
 #define CONF_OPEN_RETRIES 	2	/* (Re)open devices twice */
 #define CONF_SEND_RETRIES 	6	/* Send six requests per open */
-#define CONF_INTER_TIMEOUT	(HZ/2)	/* Inter-device timeout: 1/2 second */
+#define CONF_INTER_TIMEOUT	(HZ)	/* Inter-device timeout: 1/2 second */
 #define CONF_BASE_TIMEOUT	(HZ*2)	/* Initial timeout: 2 seconds */
 #define CONF_TIMEOUT_RANDOM	(HZ)	/* Maximum amount of randomization */
 #define CONF_TIMEOUT_MULT	*7/4	/* Rate of timeout growth */
-- 
2.5.0.234.gefc8a62
