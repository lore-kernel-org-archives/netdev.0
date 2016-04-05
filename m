From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v2 3/3] net: bcmgenet: cleanup for dmadesc_set()
Date: Tue,  5 Apr 2016 13:05:11 -0700
Message-ID: <1459886711-72949-3-git-send-email-pgynther@google.com>
References: <1459886711-72949-1-git-send-email-pgynther@google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, opendmb@gmail.com,
	jaedon.shin@gmail.com, Petri Gynther <pgynther@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33948 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759851AbcDEUFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 16:05:36 -0400
Received: by mail-pa0-f42.google.com with SMTP id fe3so17096768pab.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 13:05:36 -0700 (PDT)
In-Reply-To: <1459886711-72949-1-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dmadesc_set() is used for setting the Tx buffer DMA address, length,
and status bits on a Tx ring descriptor when a frame is being Tx'ed.

Always set the Tx buffer DMA address first, before updating the length
and status bits, i.e. giving the Tx descriptor to the hardware.

The reason this is a cleanup rather than a fix is that the hardware
won't transmit anything from a Tx ring until the TDMA producer index
has been incremented. As long as the dmadesc_set() writes complete
before the TDMA producer index write, life is good.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index d77cd6d..f7b42b9 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -104,8 +104,8 @@ static inline void dmadesc_set_addr(struct bcmgenet_priv *priv,
 static inline void dmadesc_set(struct bcmgenet_priv *priv,
 			       void __iomem *d, dma_addr_t addr, u32 val)
 {
-	dmadesc_set_length_status(priv, d, val);
 	dmadesc_set_addr(priv, d, addr);
+	dmadesc_set_length_status(priv, d, val);
 }
 
 static inline dma_addr_t dmadesc_get_addr(struct bcmgenet_priv *priv,
-- 
2.8.0.rc3.226.g39d4020
