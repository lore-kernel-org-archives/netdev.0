From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next v2 02/10] net: dsa: lan9303: Do not disable/enable switch fabric port 0 at startup
Date: Tue, 25 Jul 2017 18:15:45 +0200
Message-ID: <20170725161553.30147-3-privat@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: corbet@lwn.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170725161553.30147-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For some mysterious reason enable switch fabric port 0 TX fails to
work, when the TX has previous been disabled. Resolved by not
disable/enable switch fabric port 0 at startup. Port 1 and 2 are
still disabled in early init.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index e622db586c3d..c2b53659f58f 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -557,9 +557,6 @@ static int lan9303_disable_processing(struct lan9303 *chip)
 {
 	int ret;
 
-	ret = lan9303_disable_packet_processing(chip, LAN9303_PORT_0_OFFSET);
-	if (ret)
-		return ret;
 	ret = lan9303_disable_packet_processing(chip, LAN9303_PORT_1_OFFSET);
 	if (ret)
 		return ret;
@@ -633,10 +630,6 @@ static int lan9303_setup(struct dsa_switch *ds)
 	if (ret)
 		dev_err(chip->dev, "failed to separate ports %d\n", ret);
 
-	ret = lan9303_enable_packet_processing(chip, LAN9303_PORT_0_OFFSET);
-	if (ret)
-		dev_err(chip->dev, "failed to re-enable switching %d\n", ret);
-
 	return 0;
 }
 
-- 
2.11.0
