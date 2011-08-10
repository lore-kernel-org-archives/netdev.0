From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH] slcan: ldisc generated skbs are received in softirq context
Date: Wed, 10 Aug 2011 17:18:59 +0200
Message-ID: <4E42A163.5030208@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Matvejchikov Ilya <matvejchikov@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:21683 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273Ab1HJPTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 11:19:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As this discussion pointed out

http://marc.info/?l=linux-netdev&m=131257225602375

netdevices that are based on serial line disciplines should use netif_rx_ni()
when pushing received socketbuffers into the netdev rx queue.

Following commit 614851601c121b1320a35757ab88292d6272f906 ("slip: fix NOHZ
local_softirq_pending 08 warning") this patch updates the slcan driver
accordingly.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
CC: Matvejchikov Ilya <matvejchikov@gmail.com>
CC: Alan Cox <alan@lxorguk.ukuu.org.uk>

---

diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index f523f1c..4b70b7e 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -197,7 +197,7 @@ static void slc_bump(struct slcan *sl)
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	memcpy(skb_put(skb, sizeof(struct can_frame)),
 	       &cf, sizeof(struct can_frame));
-	netif_rx(skb);
+	netif_rx_ni(skb);

 	sl->dev->stats.rx_packets++;
 	sl->dev->stats.rx_bytes += cf.can_dlc;

