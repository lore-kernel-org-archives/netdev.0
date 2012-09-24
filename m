From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-net] net: loopback: set default mtu to 64K
Date: Mon, 24 Sep 2012 10:28:59 +0200
Message-ID: <1348475339.26828.188.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64579 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213Ab2IXI3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 04:29:04 -0400
Received: by eaac11 with SMTP id c11so1700871eaa.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 01:29:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

loopback current mtu of 16436 bytes allows no more than 3 MSS TCP
segments per frame, or 48 Kbytes. Changing mtu to 64K allows TCP
stack to build large frames and significantly reduces stack overhead.

Performance boost on bulk TCP transferts can be up to 30 %, partly
because we now have one ACK message for two 64KB segments, and a lower
probability of hitting /proc/sys/net/ipv4/tcp_reordering default limit.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/loopback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 4a075ba..81f8f9e 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -157,7 +157,7 @@ static const struct net_device_ops loopback_ops = {
  */
 static void loopback_setup(struct net_device *dev)
 {
-	dev->mtu		= (16 * 1024) + 20 + 20 + 12;
+	dev->mtu		= 64 * 1024;
 	dev->hard_header_len	= ETH_HLEN;	/* 14	*/
 	dev->addr_len		= ETH_ALEN;	/* 6	*/
 	dev->tx_queue_len	= 0;
