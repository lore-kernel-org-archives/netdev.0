From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/2] sfc: Add workspace for GMAC bug workaround to MCDI
	MAC_STATS buffer
Date: Mon, 25 Jan 2010 19:28:00 +0000
Message-ID: <1264447680.2793.0.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47702 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833Ab0AYT2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 14:28:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guido Barzini <gbarzini@solarflare.com>

Due to a hardware bug in the SFC9000 family, the firmware must
transfer raw GMAC statistics to host memory before aggregating them
into the cooked (speed-independent) MAC statistics.  Extend the stats
buffer to support this.

The length of the buffer is explicit in the MAC_STATS command, so this
change is backward-compatible on both sides.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi_pcol.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/mcdi_pcol.h b/drivers/net/sfc/mcdi_pcol.h
index 2a85360..73e71f4 100644
--- a/drivers/net/sfc/mcdi_pcol.h
+++ b/drivers/net/sfc/mcdi_pcol.h
@@ -1090,8 +1090,10 @@
 #define MC_CMD_MAC_RX_LANES01_DISP_ERR 57
 #define MC_CMD_MAC_RX_LANES23_DISP_ERR 58
 #define MC_CMD_MAC_RX_MATCH_FAULT 59
+#define MC_CMD_GMAC_DMABUF_START 64
+#define MC_CMD_GMAC_DMABUF_END   95
 /* Insert new members here. */
-#define MC_CMD_MAC_GENERATION_END 60
+#define MC_CMD_MAC_GENERATION_END 96
 #define MC_CMD_MAC_NSTATS (MC_CMD_MAC_GENERATION_END+1)
 
 /* MC_CMD_MAC_STATS:
-- 
1.5.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

