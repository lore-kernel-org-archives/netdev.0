From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 7/7] smsc75xx: enable mac to detect speed/duplex from phy
Date: Mon, 30 Apr 2012 18:56:56 +0100
Message-ID: <1335808616-22513-8-git-send-email-steve.glendinning@shawell.net>
References: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Cc: David Miller <davem@davemloft.net>,
	Stephane Fillod <fillods@users.sf.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:49413 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520Ab2D3R5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:57:16 -0400
In-Reply-To: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets the automatic speed and duplex detection bits
in MAC_CR to enable the mac to determine its speed automatically
from the phy.

Note this must be done BEFORE the receiver or transmitter is
enabled.

Signed-off-by: Stephane Fillod <fillods@users.sf.net>
Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index ae23d85..00103a8 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -951,6 +951,14 @@ static int smsc75xx_reset(struct usbnet *dev)
 	ret = smsc75xx_write_reg(dev, INT_EP_CTL, buf);
 	check_warn_return(ret, "Failed to write INT_EP_CTL: %d", ret);
 
+	/* allow mac to detect speed and duplex from phy */
+	ret = smsc75xx_read_reg(dev, MAC_CR, &buf);
+	check_warn_return(ret, "Failed to read MAC_CR: %d", ret);
+
+	buf |= (MAC_CR_ADD | MAC_CR_ASD);
+	ret = smsc75xx_write_reg(dev, MAC_CR, buf);
+	check_warn_return(ret, "Failed to write MAC_CR: %d", ret);
+
 	ret = smsc75xx_read_reg(dev, MAC_TX, &buf);
 	check_warn_return(ret, "Failed to read MAC_TX: %d", ret);
 
-- 
1.7.9.5
