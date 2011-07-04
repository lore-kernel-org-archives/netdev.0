From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: [PATCH] greth: greth_set_mac_add would corrupt the MAC address.
Date: Mon,  4 Jul 2011 11:08:03 +0200
Message-ID: <1309770483-16026-1-git-send-email-kristoffer@gaisler.com>
Cc: Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail175c2.megamailservers.com ([69.49.111.75]:56648 "EHLO
	mail175c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757099Ab1GDKMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 06:12:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MAC address was set using the signed char sockaddr->sa_addr
field and thus the address could be corrupted through sign extension.

Signed-off-by: Kristoffer Glembo <kristoffer@gaisler.com>
---
 drivers/net/greth.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 82c3767..16ce45c 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1017,11 +1017,10 @@ static int greth_set_mac_add(struct net_device *dev, void *p)
 		return -EINVAL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	GRETH_REGSAVE(regs->esa_msb, dev->dev_addr[0] << 8 | dev->dev_addr[1]);
+	GRETH_REGSAVE(regs->esa_lsb, dev->dev_addr[2] << 24 | dev->dev_addr[3] << 16 |
+		      dev->dev_addr[4] << 8 | dev->dev_addr[5]);
 
-	GRETH_REGSAVE(regs->esa_msb, addr->sa_data[0] << 8 | addr->sa_data[1]);
-	GRETH_REGSAVE(regs->esa_lsb,
-		      addr->sa_data[2] << 24 | addr->
-		      sa_data[3] << 16 | addr->sa_data[4] << 8 | addr->sa_data[5]);
 	return 0;
 }
 
-- 
1.7.0.4

