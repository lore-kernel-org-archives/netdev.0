From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] vxlan: allow live mac address change
Date: Mon, 31 Dec 2012 14:00:21 -0800
Message-ID: <20121231140021.5ec82f3a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32950 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751885Ab2LaWBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 17:01:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VXLAN pseudo-device doesn't care if the mac address changes
when device is up.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/vxlan.c	2012-12-27 22:30:53.630796042 -0800
+++ b/drivers/net/vxlan.c	2012-12-31 10:46:25.435321912 -0800
@@ -1191,6 +1191,7 @@ static void vxlan_setup(struct net_devic
 
 	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 
 	spin_lock_init(&vxlan->hash_lock);
 
