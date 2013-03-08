From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 04/11] firewire net: Check dev->broadcast_state inside
 fwnet_broadcast_start().
Date: Fri, 08 Mar 2013 10:43:14 +0900
Message-ID: <51394232.6010704@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39223 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932256Ab3CHBnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:43:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index fbd07eb..9a2634a 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1156,6 +1156,9 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	unsigned long offset;
 	unsigned u;
 
+	if (dev->broadcast_state != FWNET_BROADCAST_ERROR)
+		return 0;
+
 	max_receive = 1U << (dev->card->max_receive + 1);
 	num_packets = (FWNET_ISO_PAGE_COUNT * PAGE_SIZE) / max_receive;
 
@@ -1258,11 +1261,10 @@ static int fwnet_open(struct net_device *net)
 	if (ret)
 		return ret;
 
-	if (dev->broadcast_state == FWNET_BROADCAST_ERROR) {
-		ret = fwnet_broadcast_start(dev);
-		if (ret)
-			goto out;
-	}
+	ret = fwnet_broadcast_start(dev);
+	if (ret)
+		goto out;
+
 	netif_start_queue(net);
 
 	spin_lock_irq(&dev->lock);
-- 
1.7.9.5
