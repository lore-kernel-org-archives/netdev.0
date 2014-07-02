From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH v3 net-next 12/13] at86rf230: add sleep cycle timing
Date: Thu,  3 Jul 2014 00:20:54 +0200
Message-ID: <1404339655-8456-13-git-send-email-alex.aring@gmail.com>
References: <1404339655-8456-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, stilwellt@openlabs.co,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:64892 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757912AbaGBWVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 18:21:44 -0400
Received: by mail-wg0-f42.google.com with SMTP id z12so11570703wgg.1
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 15:21:43 -0700 (PDT)
In-Reply-To: <1404339655-8456-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index dbf85b8..79ec843 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -42,6 +42,7 @@ struct at86rf230_local;
  * All timings are in us.
  */
 struct at86rf2xx_chip_data {
+	u16 t_sleep_cycle;
 	u16 t_channel_switch;
 	u16 t_reset_to_off;
 	u16 t_off_to_aack;
@@ -1250,6 +1251,7 @@ static struct ieee802154_ops at86rf230_ops = {
 };
 
 static struct at86rf2xx_chip_data at86rf233_data = {
+	.t_sleep_cycle = 330,
 	.t_channel_switch = 11,
 	.t_reset_to_off = 26,
 	.t_off_to_aack = 80,
@@ -1265,6 +1267,7 @@ static struct at86rf2xx_chip_data at86rf233_data = {
 };
 
 static struct at86rf2xx_chip_data at86rf231_data = {
+	.t_sleep_cycle = 330,
 	.t_channel_switch = 24,
 	.t_reset_to_off = 37,
 	.t_off_to_aack = 110,
@@ -1280,6 +1283,7 @@ static struct at86rf2xx_chip_data at86rf231_data = {
 };
 
 static struct at86rf2xx_chip_data at86rf212_data = {
+	.t_sleep_cycle = 330,
 	.t_channel_switch = 11,
 	.t_reset_to_off = 26,
 	.t_off_to_aack = 200,
@@ -1338,7 +1342,8 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
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
