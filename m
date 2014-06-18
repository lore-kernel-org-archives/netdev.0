From: <ganesanr@broadcom.com>
Subject: [PATCH 1/3] Staging: Fix compilation error
Date: Wed, 18 Jun 2014 18:43:56 +0530
Message-ID: <21dec378b0ed417152176d2cc1600ce7c61ad486.1403096668.git.ganesanr@broadcom.com>
References: <cover.1403096668.git.ganesanr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ganesan Ramalingam <ganesanr@broadcom.com>,
	<jchandra@broadcom.com>, <linux-mips@linux-mips.org>,
	<ralf@linux-mips.org>, <netdev@vger.kernel.org>
To: <kristina.martsenko@gmail.com>, <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:47504 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966138AbaFRMfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 08:35:36 -0400
In-Reply-To: <cover.1403096668.git.ganesanr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesan Ramalingam <ganesanr@broadcom.com>

Cop2 save and restore function names are changed, added that change

Signed-off-by: Ganesan Ramalingam <ganesanr@broadcom.com>
---
 drivers/staging/netlogic/xlr_net.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/netlogic/xlr_net.c b/drivers/staging/netlogic/xlr_net.c
index 75d7c63..69ae8b6 100644
--- a/drivers/staging/netlogic/xlr_net.c
+++ b/drivers/staging/netlogic/xlr_net.c
@@ -125,9 +125,9 @@ static int send_to_rfr_fifo(struct xlr_net_priv *priv, void *addr)
 	msg.msg3 = 0;
 	stnid = priv->nd->rfr_station;
 	do {
-		mflags = nlm_cop2_enable();
+		mflags = nlm_cop2_enable_irqsave();
 		ret = nlm_fmn_send(1, 0, stnid, &msg);
-		nlm_cop2_restore(mflags);
+		nlm_cop2_disable_irqrestore(mflags);
 		if (ret == 0)
 			return 0;
 	} while (++num_try < 10000);
@@ -299,9 +299,9 @@ static netdev_tx_t xlr_net_start_xmit(struct sk_buff *skb,
 	u32 flags;
 
 	xlr_make_tx_desc(&msg, virt_to_phys(skb->data), skb);
-	flags = nlm_cop2_enable();
+	flags = nlm_cop2_enable_irqsave();
 	ret = nlm_fmn_send(2, 0, priv->nd->tx_stnid, &msg);
-	nlm_cop2_restore(flags);
+	nlm_cop2_disable_irqrestore(flags);
 	if (ret)
 		dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
-- 
1.7.9.5
