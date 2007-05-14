From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/6] sky2: keep track of receive alloc failures
Date: Mon, 14 May 2007 12:38:12 -0700
Message-ID: <20070514193945.686777738@linux-foundation.org>
References: <20070514193809.867470364@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:43518 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754130AbXENTmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 15:42:45 -0400
Content-Disposition: inline; filename=sky2-rx_dropped
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When driver can't allocate receive buffer it drops incoming
packet. Keep a counter.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- 2.6.21-rc1.orig/drivers/net/sky2.c	2007-05-14 12:10:13.000000000 -0700
+++ 2.6.21-rc1/drivers/net/sky2.c	2007-05-14 12:10:16.000000000 -0700
@@ -2141,8 +2141,10 @@ static int sky2_status_intr(struct sky2_
 		switch (le->opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
 			skb = sky2_receive(dev, length, status);
-			if (!skb)
+			if (unlikely(!skb)) {
+				sky2->net_stats.rx_dropped++;
 				goto force_update;
+			}
 
 			skb->protocol = eth_type_trans(skb, dev);
 			sky2->net_stats.rx_packets++;

--
Stephen Hemminger <shemminger@linux-foundation.org>

