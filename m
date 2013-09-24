From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/2 v2] tun: call skb_get_sw_rxhash
Date: Tue, 24 Sep 2013 13:42:29 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1309241336210.23896@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f201.google.com ([209.85.213.201]:34173 "EHLO
	mail-ye0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951Ab3IXUma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 16:42:30 -0400
Received: by mail-ye0-f201.google.com with SMTP id q3so589996yen.2
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 13:42:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tun calls skb_get_rxhash on both transmit and receive side with the
expectation that the calculation in symmetric. To ensure this
property call skb_get_sw_rxhash instead (ignores hash provided by NIC
on receive).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/tun.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 807815f..0619fdf 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -358,7 +358,7 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
 	rcu_read_lock();
 	numqueues = ACCESS_ONCE(tun->numqueues);
 
-	txq = skb_get_rxhash(skb);
+	txq = skb_get_sw_rxhash(skb);
 	if (txq) {
 		e = tun_flow_find(&tun->flows[tun_hashfn(txq)], txq);
 		if (e)
@@ -1138,7 +1138,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	skb_reset_network_header(skb);
 	skb_probe_transport_header(skb, 0);
 
-	rxhash = skb_get_rxhash(skb);
+	rxhash = skb_get_sw_rxhash(skb);
 	netif_rx_ni(skb);
 
 	tun->dev->stats.rx_packets++;
-- 
1.8.4
