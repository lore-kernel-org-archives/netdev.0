From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 27/34]bnx2x: Block nvram access when the device is
 inactive
Date: Wed, 14 Jan 2009 18:44:07 +0200
Message-ID: <1231951447.11301.148.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Paul Larson" <pl@linux.vnet.ibm.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764123AbZANQpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:45:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't dump eeprom when bnx2x adapter is down.  Running ethtool -e causes an eeh
without it when the device is down

Signed-off-by: Paul Larson <pl@linux.vnet.ibm.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 678bc5d..0a18af0 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8142,6 +8142,9 @@ static int bnx2x_get_eeprom(struct net_device *dev,
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




