From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 03/17] sky2: keep track of receive alloc failures
Date: Tue, 08 May 2007 20:49:52 -0700
Message-ID: <20070509035028.318945585@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:40736 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1032763AbXEIEDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:03:46 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=sky2-rx_dropped
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When driver can't allocate receive buffer it drops incoming
packet, so update counter.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 10:28:50.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 10:28:54.000000000 -0700
@@ -2132,8 +2132,10 @@ static int sky2_status_intr(struct sky2_
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

