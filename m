From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 07/11] igbvf: Call dev_kfree_skby_any instead of dev_kfree_skb.
Date: Mon, 10 Mar 2014 20:22:03 -0700
Message-ID: <8738ippgh0.fsf_-_@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<871ty9qvaf.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42622 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784AbaCKDWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:22:10 -0400
In-Reply-To: <871ty9qvaf.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 10 Mar 2014 20:16:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index e2c6d8059b74..a1b480368aee 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -212,7 +212,7 @@ static void igbvf_alloc_rx_buffers(struct igbvf_ring *rx_ring,
 			                                  bufsz,
 							  DMA_FROM_DEVICE);
 			if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
-				dev_kfree_skb(buffer_info->skb);
+				dev_kfree_skb_any(buffer_info->skb);
 				buffer_info->skb = NULL;
 				dev_err(&pdev->dev, "RX DMA map failed\n");
 				goto no_buffers;
-- 
1.7.5.4
