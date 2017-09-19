From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 11/12] net: dsa: bcm_sf2: Use SF2_NUM_EGRESS_QUEUES for CFP
Date: Tue, 19 Sep 2017 10:46:53 -0700
Message-ID: <20170919174654.2122-12-f.fainelli@gmail.com>
References: <20170919174654.2122-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33549 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbdISRrb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:47:31 -0400
Received: by mail-wm0-f67.google.com with SMTP id m127so325989wmm.0
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 10:47:30 -0700 (PDT)
In-Reply-To: <20170919174654.2122-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The magic number 8 in 3 locations in bcm_sf2_cfp.c actually designates
the number of switch port egress queues, so use that define instead of
open-coding it.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2_cfp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2_cfp.c b/drivers/net/dsa/bcm_sf2_cfp.c
index 8a1da7e67707..94649e1481ec 100644
--- a/drivers/net/dsa/bcm_sf2_cfp.c
+++ b/drivers/net/dsa/bcm_sf2_cfp.c
@@ -144,7 +144,7 @@ static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 	 * destination port is enabled and that we are within the
 	 * number of ports supported by the switch
 	 */
-	port_num = fs->ring_cookie / 8;
+	port_num = fs->ring_cookie / SF2_NUM_EGRESS_QUEUES;
 
 	if (fs->ring_cookie == RX_CLS_FLOW_DISC ||
 	    !(BIT(port_num) & ds->enabled_port_mask) ||
@@ -280,7 +280,7 @@ static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 	 * We have a small oddity where Port 6 just does not have a
 	 * valid bit here (so we subtract by one).
 	 */
-	queue_num = fs->ring_cookie % 8;
+	queue_num = fs->ring_cookie % SF2_NUM_EGRESS_QUEUES;
 	if (port_num >= 7)
 		port_num -= 1;
 
@@ -401,7 +401,7 @@ static int bcm_sf2_cfp_rule_get(struct bcm_sf2_priv *priv, int port,
 	/* There is no Port 6, so we compensate for that here */
 	if (nfc->fs.ring_cookie >= 6)
 		nfc->fs.ring_cookie++;
-	nfc->fs.ring_cookie *= 8;
+	nfc->fs.ring_cookie *= SF2_NUM_EGRESS_QUEUES;
 
 	/* Extract the destination queue */
 	queue_num = (reg >> NEW_TC_SHIFT) & NEW_TC_MASK;
-- 
2.9.3
