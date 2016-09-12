From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 14/15] hamradio: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:45 -0400
Message-ID: <1473689026-6983-15-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org
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

 drivers/net/hamradio/bpqether.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index d95a50ae996d..622ab3ab9e93 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -484,7 +484,7 @@ static void bpq_setup(struct net_device *dev)
 	dev->flags      = 0;
 	dev->features	= NETIF_F_LLTX;	/* Allow recursion */
 
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
+#if IS_ENABLED(CONFIG_AX25)
 	dev->header_ops      = &ax25_header_ops;
 #endif
 
-- 
2.7.4
