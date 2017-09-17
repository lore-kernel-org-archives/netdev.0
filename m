From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [PATCH net-next v2 4/7] net: korina: use GRO
Date: Sun, 17 Sep 2017 20:24:50 +0300
Message-ID: <20170917172450.32478-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36420 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751730AbdIQRYx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2017 13:24:53 -0400
Received: by mail-lf0-f67.google.com with SMTP id l196so3439689lfl.3
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 10:24:53 -0700 (PDT)
Received: from ubrain.corp.ubnt.com ([2a02:16d8:105:4000:76d4:35ff:fe88:7631])
        by smtp.googlemail.com with ESMTPSA id i12sm1402725ljb.20.2017.09.17.10.24.51
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 10:24:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Performance gain when receiving locally is 55->95Mbps and 50->65Mbps for NAT.

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index c210add9b654..5f36e1703378 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -406,7 +406,7 @@ static int korina_rx(struct net_device *dev, int limit)
 		skb->protocol = eth_type_trans(skb, dev);
 
 		/* Pass the packet to upper layers */
-		netif_receive_skb(skb);
+		napi_gro_receive(&lp->napi, skb);
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += pkt_len;
 
-- 
2.11.0
