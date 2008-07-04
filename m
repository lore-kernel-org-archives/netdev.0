From: akpm@linux-foundation.org
Subject: [patch for 2.6.26? 1/2] wan: add missing skb->dev assignment in Frame Relay RX code
Date: Thu, 03 Jul 2008 23:54:54 -0700
Message-ID: <200807040654.m646ssxC018102@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, khc@pm.waw.pl,
	acme@redhat.com, davem@davemloft.net,
	shemminger@linuxfoundation.org, stable@kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56795 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752061AbYGDG4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 02:56:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>

Commit 4c13eb6657fe9ef7b4dc8f1a405c902e9e5234e0 ([ETH]: Make
eth_type_trans set skb->dev like the other *_type_trans) removed skb->dev
assignment from hdlc_fr.c:fr_rx().  Unfortunately it was also needed for
cases other than eth_type_trans().

Add it back.

It's quite serious and may be a security risk as it causes a wrong input
interface indication (the physical hdlcX instead of logical pvcX). 
Probably -stable class fix.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Stephen Hemminger <shemminger@osdl.org>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/wan/hdlc_fr.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/wan/hdlc_fr.c~wan-add-missing-skb-dev-assignment-in-frame-relay-rx-code drivers/net/wan/hdlc_fr.c
--- a/drivers/net/wan/hdlc_fr.c~wan-add-missing-skb-dev-assignment-in-frame-relay-rx-code
+++ a/drivers/net/wan/hdlc_fr.c
@@ -1008,6 +1008,7 @@ static int fr_rx(struct sk_buff *skb)
 		stats->rx_bytes += skb->len;
 		if (pvc->state.becn)
 			stats->rx_compressed++;
+		skb->dev = dev;
 		netif_rx(skb);
 		return NET_RX_SUCCESS;
 	} else {
_
