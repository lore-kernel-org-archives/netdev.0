From: Patrick McHardy <kaber@trash.net>
Subject: pppoe: fix compiler warning
Date: Tue, 24 Jun 2008 18:00:06 +0200
Message-ID: <48611A06.9070607@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070202080701070802080708"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57175 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbYFXQAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 12:00:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070202080701070802080708
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------070202080701070802080708
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

pppoe: fix compiler warning

Fix warning introduced by 392fdb0 (net pppoe: Check packet length on all receive paths):

drivers/net/pppoe.c: In function 'pppoe_recvmsg':
drivers/net/pppoe.c:945: warning: comparison of distinct pointer types lacks a cast

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index bafb69b..fc6f4b8 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -942,7 +942,7 @@ static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
 	m->msg_namelen = 0;
 
 	if (skb) {
-		total_len = min(total_len, skb->len);
+		total_len = min_t(size_t, total_len, skb->len);
 		error = skb_copy_datagram_iovec(skb, 0, m->msg_iov, total_len);
 		if (error == 0)
 			error = total_len;

--------------070202080701070802080708--
