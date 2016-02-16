From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] vxlan: clear IFF_TX_SKB_SHARING
Date: Tue, 16 Feb 2016 22:16:53 +0100
Message-ID: <ad978a069caa3c84931b9f0eca7a268f9b459963.1455656611.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55855 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522AbcBPVRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 16:17:35 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 758A8C0B2EE1
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 21:17:35 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-84.brq.redhat.com [10.40.204.84])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1GLHY5Q031890
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 16:17:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ether_setup sets IFF_TX_SKB_SHARING but this is not supported by vxlan as it
modifies the skb on xmit.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a31cd954b308..db96f3a16f6c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2537,6 +2537,7 @@ static void vxlan_setup(struct net_device *dev)
 	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
 	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
 	netif_keep_dst(dev);
+	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
 
 	INIT_LIST_HEAD(&vxlan->next);
-- 
1.8.3.1
