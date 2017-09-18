From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 11/12] net: dsa: bcm_sf2: Use SF2_NUM_EGRESS_QUEUES for CFP
Date: Mon, 18 Sep 2017 14:41:27 -0700
Message-ID: <20170918214128.27896-12-f.fainelli@gmail.com>
References: <20170918214128.27896-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:38633 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751575AbdIRVmM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:42:12 -0400
Received: by mail-wr0-f193.google.com with SMTP id p37so1129996wrb.5
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 14:42:11 -0700 (PDT)
In-Reply-To: <20170918214128.27896-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The magic number 8 in 3 locations in bcm_sf2_cfp.c actually designates the
number of switch port egress queues, so use that define instead of open-coding
it.

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
