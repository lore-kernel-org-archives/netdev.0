From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/1] drivers: net: davinci_cpdma: remove CRC bytes from skb added by CPDMA
Date: Thu, 30 May 2013 11:52:01 +0530
Message-ID: <1369894922-27116-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:33996 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967549Ab3E3GU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 02:20:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Additional 4 bytes found in the skb is the CRC calculated by the
CPDMA hardware, check the CRC bit in CPDMA status field of
Descriptor and remove the CRC length from the skb. This extra
4 byte can be seen when capturing packets using tcpdump.
This has been tested in TI816x platform.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 49dfd59..a377bc7 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -64,6 +64,7 @@
 #define CPDMA_DESC_TO_PORT_EN	BIT(20)
 #define CPDMA_TO_PORT_SHIFT	16
 #define CPDMA_DESC_PORT_MASK	(BIT(18) | BIT(17) | BIT(16))
+#define CPDMA_DESC_CRC_LEN	4
 
 #define CPDMA_TEARDOWN_VALUE	0xfffffffc
 
@@ -798,6 +799,10 @@ static int __cpdma_chan_process(struct cpdma_chan *chan)
 		status = -EBUSY;
 		goto unlock_ret;
 	}
+
+	if (status & CPDMA_DESC_PASS_CRC)
+		outlen -= CPDMA_DESC_CRC_LEN;
+
 	status	= status & (CPDMA_DESC_EOQ | CPDMA_DESC_TD_COMPLETE |
 			    CPDMA_DESC_PORT_MASK);
 
-- 
1.7.9.5
