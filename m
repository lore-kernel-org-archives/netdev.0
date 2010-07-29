From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Allow multicast snooping to be disabled before ifup
Date: Thu, 29 Jul 2010 18:45:30 +0800
Message-ID: <20100729104529.GA29678@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:52981 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756839Ab0G2Kpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 06:45:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

bridge: Allow multicast snooping to be disabled before ifup

Currently you cannot disable multicast snooping while a device is
down.  There is no good reason for this restriction and this patch
removes it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 27ae946..585ce6e 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1728,13 +1728,9 @@ unlock:
 int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 {
 	struct net_bridge_port *port;
-	int err = -ENOENT;
+	int err = 0;
 
 	spin_lock(&br->multicast_lock);
-	if (!netif_running(br->dev))
-		goto unlock;
-
-	err = 0;
 	if (br->multicast_disabled == !val)
 		goto unlock;
 
@@ -1742,6 +1738,9 @@ int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 	if (br->multicast_disabled)
 		goto unlock;
 
+	if (!netif_running(br->dev))
+		goto unlock;
+
 	if (br->mdb) {
 		if (br->mdb->old) {
 			err = -EEXIST;

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
