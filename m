From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 12/13] at86rf230: add sleep cycle timing
Date: Sat, 28 Jun 2014 20:33:50 +0200
Message-ID: <1403980431-6201-13-git-send-email-alex.aring@gmail.com>
References: <1403980431-6201-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, werner@almesberger.net,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:49958 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259AbaF1Ses (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 14:34:48 -0400
Received: by mail-we0-f175.google.com with SMTP id k48so6589950wev.20
        for <netdev@vger.kernel.org>; Sat, 28 Jun 2014 11:34:47 -0700 (PDT)
In-Reply-To: <1403980431-6201-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 548b69d..a46ef43 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -44,6 +44,7 @@ struct at86rf230_local;
  * All timings are in us.
  */
 struct at86rf2xx_chip_data {
+	u16 t_sleep_cycle;
 	u16 t_channel_switch;
 	u16 t_reset_to_off;
 	u16 t_off_to_aack;
@@ -1252,6 +1253,7 @@ static struct ieee802154_ops at86rf230_ops = {
 };
 
 static struct at86rf2xx_chip_data at86rf233_data = {
+	.t_sleep_cycle = 330,
 	.t_channel_switch = 11,
 	.t_reset_to_off = 26,
 	.t_off_to_aack = 80,
@@ -1267,6 +1269,7 @@ static struct at86rf2xx_chip_data at86rf233_data = {
 };
 
 static struct at86rf2xx_chip_data at86rf231_data = {
+	.t_sleep_cycle = 330,
 	.t_channel_switch = 24,
 	.t_reset_to_off = 37,
 	.t_off_to_aack = 110,
@@ -1282,6 +1285,7 @@ static struct at86rf2xx_chip_data at86rf231_data = {
 };
 
 static struct at86rf2xx_chip_data at86rf212_data = {
+	.t_sleep_cycle = 330,
 	.t_channel_switch = 11,
 	.t_reset_to_off = 26,
 	.t_off_to_aack = 200,
@@ -1340,7 +1344,8 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	if (rc)
 		return rc;
 	/* Wait the next SLEEP cycle */
-	msleep(100);
+	usleep_range(lp->data->t_sleep_cycle,
+		     lp->data->t_sleep_cycle + 100);
 
 	rc = at86rf230_read_subreg(lp, SR_DVDD_OK, &dvdd);
 	if (rc)
-- 
2.0.1
