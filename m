From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH] net: ipv4: increase dhcp inter device timeout
Date: Wed, 12 Aug 2015 15:31:43 +0530
Message-ID: <1439373703-31620-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:46182 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092AbbHLKC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 06:02:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a system has multiple ethernet devices and during DHCP
request (for using NFS), the system waits only for HZ/2 which is
500mS before switching to another interface for DHCP.

There are some routers (Ex: Trendnet routers) which responds to
DHCP request at about 560mS. When the system has only one
ethernet interface there is no issue as the timeout is 2S and the
dev xid doesn't changes and only retries.

But when the system has multiple Ethernet like DRA74x with CPSW
in dual EMAC mode, the DHCP response is dropped as the dev xid
changes while shifting to the next device. So changing inter
device timeout to HZ (which is 1S).

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 net/ipv4/ipconfig.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 8e7328c..ed4ef09 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -94,7 +94,7 @@
 /* Define the timeout for waiting for a DHCP/BOOTP/RARP reply */
 #define CONF_OPEN_RETRIES 	2	/* (Re)open devices twice */
 #define CONF_SEND_RETRIES 	6	/* Send six requests per open */
-#define CONF_INTER_TIMEOUT	(HZ/2)	/* Inter-device timeout: 1/2 second */
+#define CONF_INTER_TIMEOUT	(HZ)	/* Inter-device timeout: 1 second */
 #define CONF_BASE_TIMEOUT	(HZ*2)	/* Initial timeout: 2 seconds */
 #define CONF_TIMEOUT_RANDOM	(HZ)	/* Maximum amount of randomization */
 #define CONF_TIMEOUT_MULT	*7/4	/* Rate of timeout growth */
-- 
2.5.0.234.gefc8a62
