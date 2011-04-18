From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/42] econet: Fix set-but-unused variable.
Date: Sun, 17 Apr 2011 17:32:54 -0700 (PDT)
Message-ID: <20110417.173254.39184498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40542
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752429Ab1DRAd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:28 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3A2A124C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:32:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


#if 0'd out code for IP handling in aun_data_available() has
been commented out since the beginning, which makes the variable
"ip" set but not used.

Kill it off as well as the stub code.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/econet/af_econet.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 116d3fd..a1d9f37 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -935,7 +935,6 @@ static void aun_data_available(struct sock *sk, int slen)
 	struct sk_buff *skb;
 	unsigned char *data;
 	struct aunhdr *ah;
-	struct iphdr *ip;
 	size_t len;
 
 	while ((skb = skb_recv_datagram(sk, 0, 1, &err)) == NULL) {
@@ -949,7 +948,6 @@ static void aun_data_available(struct sock *sk, int slen)
 	data = skb_transport_header(skb) + sizeof(struct udphdr);
 	ah = (struct aunhdr *)data;
 	len = skb->len - sizeof(struct udphdr);
-	ip = ip_hdr(skb);
 
 	switch (ah->code)
 	{
@@ -962,12 +960,6 @@ static void aun_data_available(struct sock *sk, int slen)
 	case 4:
 		aun_tx_ack(ah->handle, ECTYPE_TRANSMIT_NOT_LISTENING);
 		break;
-#if 0
-		/* This isn't quite right yet. */
-	case 5:
-		aun_send_response(ip->saddr, ah->handle, 6, ah->cb);
-		break;
-#endif
 	default:
 		printk(KERN_DEBUG "unknown AUN packet (type %d)\n", data[0]);
 	}
-- 
1.7.4.3

