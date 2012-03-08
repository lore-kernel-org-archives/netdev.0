From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: peak_usb: PCAN-USB specific part: fix little endian usage
Date: Thu,  8 Mar 2012 10:50:30 +0100
Message-ID: <1331200230-1118-2-git-send-email-mkl@pengutronix.de>
References: <1331200230-1118-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45154 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756065Ab2CHJum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 04:50:42 -0500
In-Reply-To: <1331200230-1118-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Grosjean <s.grosjean@peak-system.com>

That patch fixes some bad usage of two little-endian variables, which lead to
some warning/error when building the peak_usb driver.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_usb.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb.c b/drivers/net/can/usb/peak_usb/pcan_usb.c
index 8a7982e..86f26a1 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb.c
@@ -741,16 +741,14 @@ static int pcan_usb_encode_msg(struct peak_usb_device *dev, struct sk_buff *skb,
 
 	/* can id */
 	if (cf->can_id & CAN_EFF_FLAG) {
-		__le32 tmp32 = cpu_to_le32(cf->can_id & CAN_ERR_MASK);
+		__le32 tmp32 = cpu_to_le32((cf->can_id & CAN_ERR_MASK) << 3);
 
-		tmp32 <<= 3;
 		*pc |= PCAN_USB_STATUSLEN_EXT_ID;
 		memcpy(++pc, &tmp32, 4);
 		pc += 4;
 	} else {
-		__le16 tmp16 = cpu_to_le32(cf->can_id & CAN_ERR_MASK);
+		__le16 tmp16 = cpu_to_le16((cf->can_id & CAN_ERR_MASK) << 5);
 
-		tmp16 <<= 5;
 		memcpy(++pc, &tmp16, 2);
 		pc += 2;
 	}
-- 
1.7.4.1
