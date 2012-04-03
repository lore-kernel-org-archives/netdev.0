From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: lpc_eth: no need to reserve 8 extra bytes in rx skb
Date: Wed, 04 Apr 2012 00:02:11 +0200
Message-ID: <1333490531.18626.336.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Roland Stigge <stigge@antcom.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:44646 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755408Ab2DCWCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 18:02:18 -0400
Received: by wibhj6 with SMTP id hj6so4074096wib.1
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 15:02:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Probably a leftover from ancient code...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Roland Stigge <stigge@antcom.de>
---
This was mentioned in one of my review but ignored/lost.

 drivers/net/ethernet/nxp/lpc_eth.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 6dfc26d..d3469d8 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -990,10 +990,10 @@ static int __lpc_handle_recv(struct net_device *ndev, int budget)
 			ndev->stats.rx_errors++;
 		} else {
 			/* Packet is good */
-			skb = dev_alloc_skb(len + 8);
-			if (!skb)
+			skb = dev_alloc_skb(len);
+			if (!skb) {
 				ndev->stats.rx_dropped++;
-			else {
+			} else {
 				prdbuf = skb_put(skb, len);
 
 				/* Copy packet from buffer */
