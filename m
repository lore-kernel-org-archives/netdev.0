From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH v2] net: fec: Adjust ENET MDIO timeouts
Date: Tue, 27 Dec 2011 16:53:41 -0200
Message-ID: <1325012021-3134-1-git-send-email-festevam@gmail.com>
References: <1324997198-2241-1-git-send-email-festevam@gmail.com>
Cc: davem@davemloft.net, shawn.guo@freescale.com,
	kernel@pengutronix.de,
	Rogerio Pimentel <rogerio.pimentel@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:39689 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714Ab1L0Sxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 13:53:54 -0500
Received: by yhr47 with SMTP id 47so7563214yhr.19
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2011 10:53:53 -0800 (PST)
In-Reply-To: <1324997198-2241-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On extensive NFS boots on a mx6qsabrelite board it was noted that "FEC: MDIO read timeout" were occuring,
which caused failure on loading the FEC driver.

The original FEC_MII_TIMEOUT was set to 1 ms, which is too low when passed to the usecs_to_jiffies macro.

On ARM one jiffy is 10ms, so use a timeout of 30ms, which corresponds to 3 jiffies.

After running extensive NFS boots, the MDIO timeouts do not occur anymore with this change.

Signed-off-by: Rogerio Pimentel <rogerio.pimentel@freescale.com>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v1:
- Keep the timeout unit in us.

 drivers/net/ethernet/freescale/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index c136230..c54cc62 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -255,7 +255,7 @@ struct fec_enet_private {
 #define FEC_MMFR_TA		(2 << 16)
 #define FEC_MMFR_DATA(v)	(v & 0xffff)
 
-#define FEC_MII_TIMEOUT		1000 /* us */
+#define FEC_MII_TIMEOUT		30000 /* us */
 
 /* Transmitter timeout */
 #define TX_TIMEOUT (2 * HZ)
-- 
1.7.1
