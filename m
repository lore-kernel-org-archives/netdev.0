From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: systemport: wait for packet in umac_enable_set()
Date: Thu, 15 May 2014 14:33:53 -0700
Message-ID: <1400189633-7602-3-git-send-email-f.fainelli@gmail.com>
References: <1400189633-7602-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:37786 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739AbaEOVe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 17:34:27 -0400
Received: by mail-ie0-f182.google.com with SMTP id tp5so1644155ieb.41
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 14:34:27 -0700 (PDT)
In-Reply-To: <1400189633-7602-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When umac_enable_set() is used to disable the UniMAC receiver or
transmitter, we need to make sure that we wait for a full-sized packet
to be processed because the UniMAC hardware stops on a packet boundary,
not immediately.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 26030d67518b..d40c5b969e9e 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1244,6 +1244,12 @@ static inline void umac_enable_set(struct bcm_sysport_priv *priv,
 	else
 		reg &= ~(CMD_RX_EN | CMD_TX_EN);
 	umac_writel(priv, reg, UMAC_CMD);
+
+	/* UniMAC stops on a packet boundary, wait for a full-sized packet
+	 * to be processed (1 msec).
+	 */
+	if (enable == 0)
+		usleep_range(1000, 2000);
 }
 
 static inline int umac_reset(struct bcm_sysport_priv *priv)
-- 
1.9.1
