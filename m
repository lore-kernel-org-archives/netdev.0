From: Thomas Chou <thomas@wytron.com.tw>
Subject: [PATCH] ethoc: limit the number of buffers to 128
Date: Tue,  6 Oct 2009 21:25:25 +0800
Message-ID: <1254835525-2529-1-git-send-email-thomas@wytron.com.tw>
Cc: thierry.reding@avionic-design.de,
	Nios2 development list <nios2-dev@sopc.et.ntust.edu.tw>,
	linux-kernel@vger.kernel.org, Thomas Chou <thomas@wytron.com.tw>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757311AbZJFNYY@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only 128 buffer descriptors are supported in the core. Limit the
number in case we have more memory.

Signed-off-by: Thomas Chou <thomas@wytron.com.tw>
---
 drivers/net/ethoc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 6d82dc6..34d0c69 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -662,8 +662,8 @@ static int ethoc_open(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	/* calculate the number of TX/RX buffers */
-	num_bd = (dev->mem_end - dev->mem_start + 1) / ETHOC_BUFSIZ;
+	/* calculate the number of TX/RX buffers, maximum 128 supported */
+	num_bd = min(128, (dev->mem_end - dev->mem_start + 1) / ETHOC_BUFSIZ);
 	priv->num_tx = max(min_tx, num_bd / 4);
 	priv->num_rx = num_bd - priv->num_tx;
 	ethoc_write(priv, TX_BD_NUM, priv->num_tx);
-- 
1.6.2.5
