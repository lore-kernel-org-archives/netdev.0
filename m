From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/3][BNX2]: Fix minor loopback problem.
Date: Wed, 13 Dec 2006 18:31:19 -0800
Message-ID: <1166063479.30522.7.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2702 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbWLNBs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 20:48:26 -0500
To: davem@davemloft.net, agospoda@redhat.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix minor loopback problem.

Use the configured MAC address instead of the permanent MAC address
for loopback frames.

Update version to 1.5.2.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4fa7cef..ada5e9b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.5.1"
-#define DRV_MODULE_RELDATE	"November 15, 2006"
+#define DRV_MODULE_VERSION	"1.5.2"
+#define DRV_MODULE_RELDATE	"December 13, 2006"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -4005,7 +4005,7 @@ bnx2_run_loopback(struct bnx2 *bp, int l
 	if (!skb)
 		return -ENOMEM;
 	packet = skb_put(skb, pkt_size);
-	memcpy(packet, bp->mac_addr, 6);
+	memcpy(packet, bp->dev->dev_addr, 6);
 	memset(packet + 6, 0x0, 8);
 	for (i = 14; i < pkt_size; i++)
 		packet[i] = (unsigned char) (i & 0xff);


