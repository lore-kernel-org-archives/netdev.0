From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/6] can: peak_usb: fix missing ctrlmode_ init for every dev
Date: Mon,  9 Mar 2015 10:36:17 +0100
Message-ID: <1425893781-10867-3-git-send-email-mkl@pengutronix.de>
References: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50322 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbbCIJgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 05:36:40 -0400
In-Reply-To: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Grosjean <s.grosjean@peak-system.com>

Fixes a missing initialization of ctrlmode and ctrlmode_supported fields,
for all other CAN devices than the first one. This fix only concerns
the PCAN-USB Pro FD dual-channels CAN-FD device made by PEAK-System.

Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
index 962c3f027383..0bac0f14edc3 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
@@ -879,6 +879,10 @@ static int pcan_usb_fd_init(struct peak_usb_device *dev)
 
 		pdev->usb_if = ppdev->usb_if;
 		pdev->cmd_buffer_addr = ppdev->cmd_buffer_addr;
+
+		/* do a copy of the ctrlmode[_supported] too */
+		dev->can.ctrlmode = ppdev->dev.can.ctrlmode;
+		dev->can.ctrlmode_supported = ppdev->dev.can.ctrlmode_supported;
 	}
 
 	pdev->usb_if->dev[dev->ctrl_idx] = dev;
-- 
2.1.4
