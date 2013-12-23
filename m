From: Libin <huawei.libin@huawei.com>
Subject: [PATCH] drivers/net: Fix potential incorrect call for udelay()
Date: Mon, 23 Dec 2013 17:33:44 +0800
Message-ID: <1387791224-29320-1-git-send-email-huawei.libin@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dingtianhong@huawei.com>
To: <davem@davemloft.net>, <hsweeten@visionengravers.com>,
	<gregkh@linuxfoundation.org>, <tedheadster@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Li Bin <huawei.libin@huawei.com>

The variable delay_time as a module parameter can be set a value
exceeding the limit of the udelay function. This patch checks the
delay_time value to select mdelay() or udelay().

Signed-off-by: Li Bin <huawei.libin@huawei.com>
---
 drivers/net/ethernet/8390/pcnet_cs.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/8390/pcnet_cs.c b/drivers/net/ethernet/8390/pcnet_cs.c
index 46c5aad..29fe157 100644
--- a/drivers/net/ethernet/8390/pcnet_cs.c
+++ b/drivers/net/ethernet/8390/pcnet_cs.c
@@ -1284,8 +1284,12 @@ static void dma_block_output(struct net_device *dev, int count,
 	}
 
     outb_p(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
-    if (info->flags & DELAY_OUTPUT)
-	udelay((long)delay_time);
+    if (info->flags & DELAY_OUTPUT) {
+		if (delay_time >= 1000)
+			mdelay((long)delay_time/1000);
+		else
+			udelay(delay_time);
+	}
     ei_status.dmaing &= ~0x01;
 }
 
-- 
1.8.2.2
