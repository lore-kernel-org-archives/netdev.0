From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH] bnx2x: Prevent eeprom set when driver is down
Date: Thu, 08 Jan 2009 17:40:12 +0200
Message-ID: <1231429212.11301.13.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>,
	"Paul Larson" <pl@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2751 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758409AbZAHPkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 10:40:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 600210d..425cbae 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8246,6 +8246,9 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 	int rc;
 
+	if (!netif_running(dev))
+		return -EAGAIN;
+
 	DP(BNX2X_MSG_NVM, "ethtool_eeprom: cmd %d\n"
 	   DP_LEVEL "  magic 0x%x  offset 0x%x (%d)  len 0x%x (%d)\n",
 	   eeprom->cmd, eeprom->magic, eeprom->offset, eeprom->offset,
-- 
1.5.4.3




