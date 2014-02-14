From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v2 02/10] ieee802154: default to AACK in at86rf230
Date: Fri, 14 Feb 2014 23:49:24 +0100
Message-ID: <1392418172-5305-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1392418172-5305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:43989 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbaBNW63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:58:29 -0500
In-Reply-To: <1392418172-5305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current IEEE802.15.4 stack assumes that a radio will never deliver
packets with a bad CRC into the stack, as required by the standard.
at86rf230 driven radios violates this assumption because of another
incompatibility: devices are required to send ACKs if requested by a
sender, but RF2xx will only send ACKs from a special receive mode that
is currently not used by the driver.

Enable this receive mode to fix both bugs. Frames with bad CRCs will not
be received at all, and ACKs will be sent if so requested.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 drivers/net/ieee802154/at86rf230.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 2df5d80..230258f 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -567,7 +567,7 @@ at86rf230_start(struct ieee802154_dev *dev)
 	if (rc)
 		return rc;
 
-	return at86rf230_state(dev, STATE_RX_ON);
+	return at86rf230_state(dev, STATE_RX_AACK_ON);
 }
 
 static void
-- 
1.8.5.4
