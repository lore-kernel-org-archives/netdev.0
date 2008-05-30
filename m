From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH] sc92031: remove bogus unlikely()
Date: Thu, 29 May 2008 21:58:36 -0300
Message-ID: <483F513C.5010303@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-01.mandic.com.br ([200.225.81.132]:34331 "EHLO
	smtp-01.mandic.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbYE3BFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 21:05:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5a0a92e67b5009a71e011658da04fb92dad8961f mentions len < ETH_ZLEN
is true for ARP packets. This obviously is not unlikely.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 drivers/net/sc92031.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index b4b6380..61955f8 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -972,7 +972,7 @@ static int sc92031_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_copy_and_csum_dev(skb, priv->tx_bufs + entry * TX_BUF_SIZE);
 
 	len = skb->len;
-	if (unlikely(len < ETH_ZLEN)) {
+	if (len < ETH_ZLEN) {
 		memset(priv->tx_bufs + entry * TX_BUF_SIZE + len,
 				0, ETH_ZLEN - len);
 		len = ETH_ZLEN;
-- 
1.5.5.1

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com
