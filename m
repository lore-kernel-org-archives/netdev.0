From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: [PATCH 02/13] net: dsa: lan9303: Do not disable/enable switch fabric
 port 0 at startup
Date: Wed, 7 Jun 2017 13:57:58 +0200
Message-ID: <673381d6306e4c13912d3d29917d1de6@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <egil.hjelmeland@zenitel.com>
To: <corbet@lwn.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.bemta5.messagelabs.com ([195.245.231.142]:17934 "EHLO
        mail1.bemta5.messagelabs.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753123AbdGXPl6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 11:41:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some mysterious reason enable switch fabric port 0 TX fails to
work, when the TX has previous been disabled. Resolved by not
disable/enable switch fabric port 0 at startup. Port 1 and 2 are
still disabled in early init.

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
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


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
