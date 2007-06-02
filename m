From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/4] [IPV4]: Only panic if inetdev_init fails for loopback
Date: Sat, 2 Jun 2007 20:02:11 +1000
Message-ID: <20070602100210.GA9247@gondor.apana.org.au>
References: <20070602100132.GA9129@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4456 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754077AbXFBKCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 06:02:12 -0400
Content-Disposition: inline
In-Reply-To: <20070602100132.GA9129@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV4]: Only panic if inetdev_init fails for loopback

When I made the inetdev_init call work on all devices I incorrectly
left in the panic call as well.  It is obviously undesirable to
panic on an allocation failure for a normal network device.  This
patch moves the panic call under the loopback if clause.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1057,9 +1057,10 @@ static int inetdev_event(struct notifier
 	if (!in_dev) {
 		if (event == NETDEV_REGISTER) {
 			in_dev = inetdev_init(dev);
-			if (!in_dev)
-				panic("devinet: Failed to create loopback\n");
 			if (dev == &loopback_dev) {
+				if (!in_dev)
+					panic("devinet: "
+					      "Failed to create loopback\n");
 				in_dev->cnf.no_xfrm = 1;
 				in_dev->cnf.no_policy = 1;
 			}
