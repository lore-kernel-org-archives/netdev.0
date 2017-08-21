From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] mt7601u: check memory allocation failure
Date: Mon, 21 Aug 2017 22:59:56 +0200
Message-ID: <20170821205956.20859-1-christophe.jaillet@wanadoo.fr>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: kubakici@wp.pl, kvalo@codeaurora.org, matthias.bgg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp04.smtpout.orange.fr ([80.12.242.126]:48425 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753971AbdHUVAG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 17:00:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check memory allocation failure and return -ENOMEM in such a case, as
already done a few lines below

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/wireless/mediatek/mt7601u/dma.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/mediatek/mt7601u/dma.c b/drivers/net/wireless/mediatek/mt7601u/dma.c
index 660267b359e4..fa0173579d32 100644
--- a/drivers/net/wireless/mediatek/mt7601u/dma.c
+++ b/drivers/net/wireless/mediatek/mt7601u/dma.c
@@ -484,6 +484,8 @@ static int mt7601u_alloc_tx(struct mt7601u_dev *dev)
 
 	dev->tx_q = devm_kcalloc(dev->dev, __MT_EP_OUT_MAX,
 				 sizeof(*dev->tx_q), GFP_KERNEL);
+	if (!dev->tx_q)
+		return -ENOMEM;
 
 	for (i = 0; i < __MT_EP_OUT_MAX; i++)
 		if (mt7601u_alloc_tx_queue(dev, &dev->tx_q[i]))
-- 
2.11.0
