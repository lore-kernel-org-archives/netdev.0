From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] net: fec: Adjust ENET MDIO timeouts
Date: Tue, 27 Dec 2011 12:46:38 -0200
Message-ID: <1324997198-2241-1-git-send-email-festevam@gmail.com>
Cc: davem@davemloft.net, shawn.guo@freescale.com,
	kernel@pengutronix.de,
	Rogerio Pimentel <rogerio.pimentel@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51783 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754427Ab1L0Oq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 09:46:58 -0500
Received: by yenm11 with SMTP id m11so6765613yen.19
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2011 06:46:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On extensive NFS boots on a mx6qsabrelite board it was noted that "FEC: MDIO read timeout" were occuring,
which caused failure on loading the FEC driver.

The original FEC_MII_TIMEOUT was set to 1 ms, which is too low when passed to the usecs_to_jiffies macro.

On ARM one jiffy is 10ms, so use msecs_to_jiffies instead and use a timeout of 30ms, which corresponds to 3 jiffies.

After running extensive NFS boots, the MDIO timeouts do not occur anymore with this change.

Signed-off-by: Rogerio Pimentel <rogerio.pimentel@freescale.com>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index c136230..170a015 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -255,7 +255,7 @@ struct fec_enet_private {
 #define FEC_MMFR_TA		(2 << 16)
 #define FEC_MMFR_DATA(v)	(v & 0xffff)
 
-#define FEC_MII_TIMEOUT		1000 /* us */
+#define FEC_MII_TIMEOUT		30 /* ms */
 
 /* Transmitter timeout */
 #define TX_TIMEOUT (2 * HZ)
@@ -902,7 +902,7 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 
 	/* wait for end of transfer */
 	time_left = wait_for_completion_timeout(&fep->mdio_done,
-			usecs_to_jiffies(FEC_MII_TIMEOUT));
+			msecs_to_jiffies(FEC_MII_TIMEOUT));
 	if (time_left == 0) {
 		fep->mii_timeout = 1;
 		printk(KERN_ERR "FEC: MDIO read timeout\n");
@@ -930,7 +930,7 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 
 	/* wait for end of transfer */
 	time_left = wait_for_completion_timeout(&fep->mdio_done,
-			usecs_to_jiffies(FEC_MII_TIMEOUT));
+			msecs_to_jiffies(FEC_MII_TIMEOUT));
 	if (time_left == 0) {
 		fep->mii_timeout = 1;
 		printk(KERN_ERR "FEC: MDIO write timeout\n");
-- 
1.7.1
