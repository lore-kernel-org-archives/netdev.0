From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 12/15] sis900: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:43 -0400
Message-ID: <1473689026-6983-13-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, Daniele Venzano <venza@brownhat.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/sis/sis900.c | 4 ++--
 drivers/net/ethernet/sis/sis900.h | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 95001ee408ab..6f85276376e8 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1426,7 +1426,7 @@ static void sis900_set_mode(struct sis900_private *sp, int speed, int duplex)
 		rx_flags |= RxATX;
 	}
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
 	/* Can accept Jumbo packet */
 	rx_flags |= RxAJAB;
 #endif
@@ -1750,7 +1750,7 @@ static int sis900_rx(struct net_device *net_dev)
 		data_size = rx_status & DSIZE;
 		rx_size = data_size - CRC_SIZE;
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
 		/* ``TOOLONG'' flag means jumbo packet received. */
 		if ((rx_status & TOOLONG) && data_size <= MAX_FRAME_SIZE)
 			rx_status &= (~ ((unsigned int)TOOLONG));
diff --git a/drivers/net/ethernet/sis/sis900.h b/drivers/net/ethernet/sis/sis900.h
index 7d430d322931..f0da3dc52c01 100644
--- a/drivers/net/ethernet/sis/sis900.h
+++ b/drivers/net/ethernet/sis/sis900.h
@@ -310,7 +310,7 @@ enum sis630_revision_id {
 #define CRC_SIZE                4
 #define MAC_HEADER_SIZE         14
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
 #define MAX_FRAME_SIZE  (1518 + 4)
 #else
 #define MAX_FRAME_SIZE  1518
-- 
2.7.4
