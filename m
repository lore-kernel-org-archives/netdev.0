From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH net-next-2.6] can: use correct NET_RX_ return values
Date: Sat, 29 Aug 2009 18:45:09 +0200
Message-ID: <4A995B15.4020303@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010505040601090507000902"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:32837 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbZH2QpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 12:45:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010505040601090507000902
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Dropped skb's should be documented by an appropriate return value.
Use the correct NET_RX_DROP and NET_RX_SUCCESS values for that reason.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

---

--------------010505040601090507000902
Content-Type: text/x-patch;
 name="can_use_correct_NET_RX_return_values.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can_use_correct_NET_RX_return_values.patch"

diff --git a/net/can/af_can.c b/net/can/af_can.c
index f9c027b..ef1c43a 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -686,11 +686,11 @@ static int can_rcv(struct sk_buff *skb, struct net_device *dev,
 		can_stats.matches_delta++;
 	}
 
-	return 0;
+	return NET_RX_SUCCESS;
 
 drop:
 	kfree_skb(skb);
-	return 0;
+	return NET_RX_DROP;
 }
 
 /*

--------------010505040601090507000902--
