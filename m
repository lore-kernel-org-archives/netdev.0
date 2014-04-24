From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next 2/4] Altera TSE: Set the Pause Quanta value to the IEEE default value
Date: Thu, 24 Apr 2014 16:58:09 -0500
Message-ID: <1398376691-15265-3-git-send-email-vbridgers2013@gmail.com>
References: <1398376691-15265-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com, Vince Bridgers <vbridger@altera.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33663 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319AbaDXWCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:02:38 -0400
Received: by mail-pa0-f52.google.com with SMTP id kx10so2394906pab.25
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 15:02:37 -0700 (PDT)
In-Reply-To: <1398376691-15265-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridger@altera.com>

This patch initializes the pause quanta set for transmitted pause frames
to the IEEE specified default of 0xffff.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/ethernet/altera/altera_tse.h      |    2 ++
 drivers/net/ethernet/altera/altera_tse_main.c |    2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/altera/altera_tse.h b/drivers/net/ethernet/altera/altera_tse.h
index 6059a09..465c4aa 100644
--- a/drivers/net/ethernet/altera/altera_tse.h
+++ b/drivers/net/ethernet/altera/altera_tse.h
@@ -58,6 +58,8 @@
 /* MAC function configuration default settings */
 #define ALTERA_TSE_TX_IPG_LENGTH	12
 
+#define ALTERA_TSE_PAUSE_QUANTA		0xffff
+
 #define GET_BIT_VALUE(v, bit)		(((v) >> (bit)) & 0x1)
 
 /* MAC Command_Config Register Bit Definitions
diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index dabba5e..6371283 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -891,6 +891,8 @@ static int init_mac(struct altera_tse_private *priv)
 
 	iowrite32(cmd, &mac->command_config);
 
+	iowrite32(ALTERA_TSE_PAUSE_QUANTA, &mac->pause_quanta);
+
 	if (netif_msg_hw(priv))
 		dev_dbg(priv->device,
 			"MAC post-initialization: CMD_CONFIG = 0x%08x\n", cmd);
-- 
1.7.9.5
