From: Sergey Matyukevich <geomatsi@gmail.com>
Subject: [PATCH v2] ucc_geth: fix for RX skb buffers recycling
Date: Mon, 14 Jun 2010 20:35:20 +0400
Message-ID: <20100614203520.23a02c25@realm>
References: <1275935894-30483-1-git-send-email-geomatsi@gmail.com>
	<1275935894-30483-2-git-send-email-geomatsi@gmail.com>
	<20100609.180240.59675642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leoli@freescale.com,
	avorontsov@ru.mvista.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62513 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756214Ab0FNQjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 12:39:46 -0400
Received: by bwz7 with SMTP id 7so2199702bwz.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 09:39:44 -0700 (PDT)
In-Reply-To: <20100609.180240.59675642.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

Could you please consider the second, simplified, version of the patch
for ucc_geth driver regarding proper RX error skb buffer recycling.


This patch implements a proper modification of RX skb buffers before
recycling. Adjusting only skb->data is not enough because after that
skb->tail and skb->len become incorrect.

Signed-off-by: Sergey Matyukevich <geomatsi@gmail.com>
---
 drivers/net/ucc_geth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 4a34833..807470e 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3215,6 +3215,8 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 					   __func__, __LINE__, (u32) skb);
 			if (skb) {
 				skb->data = skb->head + NET_SKB_PAD;
+				skb->len = 0;
+				skb_reset_tail_pointer(skb);
 				__skb_queue_head(&ugeth->rx_recycle, skb);
 			}
 
-- 
1.6.2.5

