From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 05/15] sundance: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:36 -0400
Message-ID: <1473689026-6983-6-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Denis Kirjanov <kda@linux-powerpc.org>, netdev@vger.kernel.org
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

 drivers/net/ethernet/dlink/sundance.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 58c6338a839e..79d80090eac8 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -867,7 +867,7 @@ static int netdev_open(struct net_device *dev)
 
 	/* Initialize other registers. */
 	__set_mac_addr(dev);
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
 	iowrite16(dev->mtu + 18, ioaddr + MaxFrameSize);
 #else
 	iowrite16(dev->mtu + 14, ioaddr + MaxFrameSize);
-- 
2.7.4
