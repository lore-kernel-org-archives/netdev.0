From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 2/2] net: can: comparison of unsigned variable
Date: Tue, 18 Nov 2014 19:17:07 +0530
Message-ID: <1416318427-28676-2-git-send-email-sudipm.mukherjee@gmail.com>
References: <1416318427-28676-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Michal Simek <michal.simek@xilinx.com>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:46029 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754561AbaKRNrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 08:47:21 -0500
In-Reply-To: <1416318427-28676-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

err was of the type u32. it was being compared with < 0, and being
an unsigned variable the comparison would have been always false.

moreover, err was getting the return value from set_reset_mode()
and xcan_set_bittiming(), and both are returning int.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/can/xilinx_can.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 72fe96f..67c2dd4 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -300,7 +300,8 @@ static int xcan_set_bittiming(struct net_device *ndev)
 static int xcan_chip_start(struct net_device *ndev)
 {
 	struct xcan_priv *priv = netdev_priv(ndev);
-	u32 err, reg_msr, reg_sr_mask;
+	u32 reg_msr, reg_sr_mask;
+	int err;
 	unsigned long timeout;
 
 	/* Check if it is in reset mode */
-- 
1.8.1.2
