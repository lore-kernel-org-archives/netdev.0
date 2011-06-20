From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netxen: fix race in skb->len access
Date: Mon, 20 Jun 2011 08:26:15 +0200
Message-ID: <1308551175.3539.133.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49862 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203Ab1FTGdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 02:33:35 -0400
Received: by wyb38 with SMTP id 38so1418392wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 23:33:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As soon as skb is given to hardware, TX completion can free skb under
us.
Therefore, we should update dev stats before kicking the device.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b644383..c0788a3 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1965,11 +1965,11 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	netxen_tso_check(netdev, tx_ring, first_desc, skb);
 
-	netxen_nic_update_cmd_producer(adapter, tx_ring);
-
 	adapter->stats.txbytes += skb->len;
 	adapter->stats.xmitcalled++;
 
+	netxen_nic_update_cmd_producer(adapter, tx_ring);
+
 	return NETDEV_TX_OK;
 
 drop_packet:


