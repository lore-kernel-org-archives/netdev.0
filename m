From: Alexander Strakh <strakh@ispras.ru>
Subject: [BUG] znet.c sleeping function called from invalid context
Date: Wed, 7 Oct 2009 18:47:37 +0000
Message-ID: <200910071847.38163.strakh@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernlel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ispras.ru ([83.149.198.201]:43320 "EHLO smtp.ispras.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751774AbZJGOpj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 10:45:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	KERNEL_VERSION: 2.6.31
	DESCRIBE:
Driver drivers/net/znet.c might sleep in atomic context, because it calls 
free_dma under claim_dma_lock:

.drivers/net/znet.c:
 168 static int znet_request_resources (struct net_device *dev)
...
 189        flags = claim_dma_lock();
 190        free_dma (znet->tx_dma);
 191        release_dma_lock (flags);
...

Path to might_sleep macro from znet_request_resources:
1. znet_request_resources calls free_dma at 
arch/blackfin/kernel/bfin_dma_5xx.c:181
2. free_dma calls arch/blackfin/kernel/bfin_dma_5xx.c:195

Found by: Linux Driver Verification

