From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 41/47] stmmac: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:43 +0200
Message-ID: <1311173689-17419-42-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	peppe.cavallaro@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340Ab1GTO4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:12 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- kill priv->vlgrp and stmmac_vlan_rx_register (used for nothing :))

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/stmmac/stmmac.h      |    3 ---
 drivers/net/stmmac/stmmac_main.c |   17 -----------------
 2 files changed, 0 insertions(+), 20 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 2b076b3..4d8995d 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -79,9 +79,6 @@ struct stmmac_priv {
 #ifdef CONFIG_STMMAC_TIMER
 	struct stmmac_timer *tm;
 #endif
-#ifdef STMMAC_VLAN_TAG_USED
-	struct vlan_group *vlgrp;
-#endif
 	struct plat_stmmacenet_data *plat;
 };
 
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index d4adc80..9ad99e2 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1414,20 +1414,6 @@ static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return ret;
 }
 
-#ifdef STMMAC_VLAN_TAG_USED
-static void stmmac_vlan_rx_register(struct net_device *dev,
-				    struct vlan_group *grp)
-{
-	struct stmmac_priv *priv = netdev_priv(dev);
-
-	DBG(probe, INFO, "%s: Setting vlgrp to %p\n", dev->name, grp);
-
-	spin_lock(&priv->lock);
-	priv->vlgrp = grp;
-	spin_unlock(&priv->lock);
-}
-#endif
-
 static const struct net_device_ops stmmac_netdev_ops = {
 	.ndo_open = stmmac_open,
 	.ndo_start_xmit = stmmac_xmit,
@@ -1438,9 +1424,6 @@ static const struct net_device_ops stmmac_netdev_ops = {
 	.ndo_tx_timeout = stmmac_tx_timeout,
 	.ndo_do_ioctl = stmmac_ioctl,
 	.ndo_set_config = stmmac_config,
-#ifdef STMMAC_VLAN_TAG_USED
-	.ndo_vlan_rx_register = stmmac_vlan_rx_register,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = stmmac_poll_controller,
 #endif
-- 
1.7.6

