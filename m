From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] 6LoWPAN: double free in lowpan_fragment_xmit()
Date: Wed, 16 Nov 2011 11:21:38 +0300
Message-ID: <20111116082138.GA10264@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergey Lapin <slapin@ossfans.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:59750 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512Ab1KPIWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 03:22:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_queue_xmit() consumes its own skb, so the call to dev_kfree_skb()
ieee802154/6lowpan.clowpan_fragment_xmits a double free.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 602f318..e4ecc1e 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -980,9 +980,6 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
 
 	ret = dev_queue_xmit(frag);
 
-	if (ret < 0)
-		dev_kfree_skb(frag);
-
 	return ret;
 }
 
