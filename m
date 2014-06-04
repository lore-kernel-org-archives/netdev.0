From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 1/3] bonding: Turn on IFF_UNICAST_FLT on bond devices
Date: Wed,  4 Jun 2014 16:23:36 -0400
Message-ID: <1401913418-31307-2-git-send-email-vyasevic@redhat.com>
References: <1401913418-31307-1-git-send-email-vyasevic@redhat.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	kaber@trash.net, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54895 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbaFDUXr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 16:23:47 -0400
In-Reply-To: <1401913418-31307-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bonding devices manage the unicast filters of the underlying
interfaces, but do not turn on IFF_UNICAST_FLT flag.  Thus
anytime a unicast address is added to the bond, the bond is
places in promiscuous mode.

Turn on IFF_UNICAST_FLT on the bond device so that the bond does
not go into promiscuous mode needlesly.  If an underlying device
does not support unicast filtering, that device will automaticall
enter promiscuous mode already.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 59a12c61..a89bf18 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3945,7 +3945,7 @@ void bond_setup(struct net_device *bond_dev)
 	/* Initialize the device options */
 	bond_dev->tx_queue_len = 0;
 	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
-	bond_dev->priv_flags |= IFF_BONDING;
+	bond_dev->priv_flags |= IFF_BONDING | IFF_UNICAST_FLT;
 	bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
 
 	/* At first, we block adding VLANs. That's the only way to
-- 
1.9.0
