From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 01/15] 3c59x: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:32 -0400
Message-ID: <1473689026-6983-2-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org,
        Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
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

 drivers/net/ethernet/3com/3c59x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 25c55ab05c7d..9133e7926da5 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -3089,7 +3089,7 @@ static void set_rx_mode(struct net_device *dev)
 	iowrite16(new_mode, ioaddr + EL3_CMD);
 }
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
 /* Setup the card so that it can receive frames with an 802.1q VLAN tag.
    Note that this must be done after each RxReset due to some backwards
    compatibility logic in the Cyclone and Tornado ASICs */
-- 
2.7.4
