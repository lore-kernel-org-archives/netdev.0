From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/2] tun: call skb_get_sw_rxhash
Date: Tue, 24 Sep 2013 09:21:13 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1309240915390.24704@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:40876 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574Ab3IXQnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:43:03 -0400
Received: by mail-qa0-f73.google.com with SMTP id cm18so457701qab.0
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 09:43:02 -0700 (PDT)
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
