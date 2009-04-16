From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH 2.6.30] Network Drop Monitor: Make use of consume_skb() in
 af_can.c
Date: Thu, 16 Apr 2009 21:58:29 +0200
Message-ID: <49E78DE5.10104@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030803080008010800060906"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:52796 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756609AbZDPT6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 15:58:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030803080008010800060906
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Since commit ead2ceb0ec9f85cff19c43b5cdb2f8a054484431 so called end-of-line
points for skb's should use consume_skb() to free the socket buffer.

In opposite to consume_skb() the function kfree_skb() is intended to be used
for unexpected skb drops e.g. in error conditions that now can trigger the
network drop monitor if enabled.

This patch moves the skb end-of-line point in af_can.c to use consume_skb().

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

---



--------------030803080008010800060906
Content-Type: text/x-patch;
 name="can_consume_skb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can_consume_skb.patch"

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 547bafc..10f0528 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -674,8 +674,8 @@ static int can_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	rcu_read_unlock();
 
-	/* free the skbuff allocated by the netdevice driver */
-	kfree_skb(skb);
+	/* consume the skbuff allocated by the netdevice driver */
+	consume_skb(skb);
 
 	if (matches > 0) {
 		can_stats.matches++;

--------------030803080008010800060906--
