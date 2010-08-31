From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: add a comment on netdev->last_rx
Date: Tue, 31 Aug 2010 19:40:16 +0200
Message-ID: <1283276416.2550.140.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:65180 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548Ab0HaRkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 13:40:21 -0400
Received: by wwb13 with SMTP id 13so57423wwb.1
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 10:40:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As some driver authors seem to reintroduce dev->last_rx use,
add a comment to strongly discourage this.

Since commit 6cf3f41e6c0 (bonding, net: Move last_rx update into bonding
recv logic), network drivers dont need to update last_rx themselves,
unless they use this field to implement a timeout.

Not updating last_rx helps not dirtying a cache line, improving
performance in SMP.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0cf9448..c82220a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -953,7 +953,14 @@ struct net_device {
 /*
  * Cache line mostly used on receive path (including eth_type_trans())
  */
-	unsigned long		last_rx;	/* Time of last Rx	*/
+	unsigned long		last_rx;	/* Time of last Rx
+						 * This should not be set in
+						 * drivers, unless really needed,
+						 * because network stack (bonding)
+						 * use it if/when necessary, to
+						 * avoid dirtying this cache line.
+						 */
+
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		*dev_addr;	/* hw address, (before bcast
 						   because most packets are


