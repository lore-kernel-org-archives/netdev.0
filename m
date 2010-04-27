From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] bridge: use is_multicast_ether_addr
Date: Tue, 27 Apr 2010 10:13:06 -0700
Message-ID: <20100427101306.3a49104f@nehalam>
References: <20100228054012.GA7583@gondor.apana.org.au>
 <E1NlbuW-00021d-8E@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43817 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754863Ab0D0RN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 13:13:28 -0400
In-Reply-To: <E1NlbuW-00021d-8E@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use existing inline function.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_device.c	2010-04-27 09:49:30.059258391 -0700
+++ b/net/bridge/br_device.c	2010-04-27 09:50:21.439878721 -0700
@@ -36,7 +36,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
-	if (dest[0] & 1) {
+	if (is_multicast_ether_addr(dest)) {
 		if (br_multicast_rcv(br, NULL, skb))
 			goto out;
 
