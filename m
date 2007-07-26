From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/6] [NET] loopback: Panic if registration fails
Date: Thu, 26 Jul 2007 17:09:33 +0800
Message-ID: <E1IDzLh-0000AB-00@gondolin.me.apana.org.au>
References: <20070726090725.GA510@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1313 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756880AbXGZJJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 05:09:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET] loopback: Panic if registration fails

Because IPv4 and IPv6 both depend on the presence of the loopback device
to function, failure in registration the loopback device should be fatal.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/loopback.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 6ba6ed2..5106c23 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -229,7 +229,12 @@ struct net_device loopback_dev = {
 /* Setup and register the loopback device. */
 static int __init loopback_init(void)
 {
-	return register_netdev(&loopback_dev);
+	int err = register_netdev(&loopback_dev);
+
+	if (err)
+		panic("loopback: Failed to register netdevice: %d\n", err);
+
+	return err;
 };
 
 module_init(loopback_init);
