From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v4 6/9] bgmac: increase rx ring size from 511 to 512
Date: Mon, 13 Apr 2015 15:52:39 +0200
Message-ID: <1428933162-26763-6-git-send-email-nbd@openwrt.org>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:51321
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753304AbbDMNwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 09:52:47 -0400
In-Reply-To: <1428933162-26763-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Limiting it to 511 looks like a failed attempt at leaving one descriptor
empty to allow the hardware to stop processing a buffer that has not
been prepared yet. However, this doesn't work because this affects the
total ring size as well

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 3db0d52..e45e303 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -356,7 +356,7 @@
 #define BGMAC_MAX_RX_RINGS			1
 
 #define BGMAC_TX_RING_SLOTS			128
-#define BGMAC_RX_RING_SLOTS			512 - 1		/* Why -1? Well, Broadcom does that... */
+#define BGMAC_RX_RING_SLOTS			512
 
 #define BGMAC_RX_HEADER_LEN			28		/* Last 24 bytes are unused. Well... */
 #define BGMAC_RX_FRAME_OFFSET			30		/* There are 2 unused bytes between header and real data */
-- 
2.2.2
