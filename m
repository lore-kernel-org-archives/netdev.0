From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 07/11] fs_enet: enable transmit time stamping.
Date: Sun, 19 Jun 2011 19:57:00 +0200
Message-ID: <1c233b9a8692a4727537f8fcff3e91214e950d96.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58291 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754479Ab1FSR5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 13:57:22 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so546578fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 10:57:21 -0700 (PDT)
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping.
Compile tested only.

Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>
Cc: Vitaly Bordug <vbordug@ru.mvista.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/fs_enet/fs_enet-main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 21abb5c..329ef23 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -697,6 +697,8 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		sc |= BD_ENET_TX_PAD;
 	CBDS_SC(bdp, sc);
 
+	skb_tx_timestamp(skb);
+
 	(*fep->ops->tx_kickstart)(dev);
 
 	spin_unlock_irqrestore(&fep->tx_lock, flags);
-- 
1.7.0.4

