From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: [PATCH 2/3] net: arc_emac: reset txbd_curr and txbd_dirty pointers to zero
Date: Tue,  9 Feb 2016 18:20:39 +0300
Message-ID: <1455031240-29385-3-git-send-email-al.kochet@gmail.com>
References: <1455031240-29385-1-git-send-email-al.kochet@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"'David S. Miller'" <davem@davemloft.net>,
	Alexander Kochetkov <al.kochet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:36425 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756619AbcBIPVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 10:21:10 -0500
In-Reply-To: <1455031240-29385-1-git-send-email-al.kochet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EMAC reset internal tx ring pointer to zero at statup.
txbd_curr and txbd_dirty can be different from zero.
That cause ethernet transfer hang (no packets transmitted).

In order to reproduce, run on device:
    ifconfig eth0 down
    ifconfig eth0 up

Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>

---
CC: stable@vger.kernel.org # 3.18.x-
---
 drivers/net/ethernet/arc/emac_main.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 63a63e3..4f6e5be 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -447,6 +447,9 @@ static int arc_emac_open(struct net_device *ndev)
 		*last_rx_bd = (*last_rx_bd + 1) % RX_BD_NUM;
 	}
 
+	priv->txbd_curr = 0;
+	priv->txbd_dirty = 0;
+
 	/* Clean Tx BD's */
 	memset(priv->txbd, 0, TX_RING_SZ);
 
-- 
1.7.9.5
