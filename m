From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 12/31] net: pxa168_eth: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:58:00 +0900
Message-ID: <003c01cea53d$80647b60$812d7220$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:8994 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511Ab3H3E6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:58:01 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB006HFV4CTWN0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:58:00 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index db48147..23a3f57 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1517,7 +1517,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	printk(KERN_INFO "%s:Using random mac address\n", DRIVER_NAME);
 	eth_hw_addr_random(dev);
 
-	pep->pd = pdev->dev.platform_data;
+	pep->pd = dev_get_platdata(&pdev->dev);
 	pep->rx_ring_size = NUM_RX_DESCS;
 	if (pep->pd->rx_queue_size)
 		pep->rx_ring_size = pep->pd->rx_queue_size;
-- 
1.7.10.4
