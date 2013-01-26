From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/3] can: c_can: fix invalid error codes
Date: Sat, 26 Jan 2013 17:33:25 +0100
Message-ID: <1359218007-18586-2-git-send-email-mkl@pengutronix.de>
References: <1359218007-18586-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>,
	linux-stable <stable@vger.kernel.org>,
	Bhupesh Sharma <bhupesh.sharma@st.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56853 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab3AZQde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2013 11:33:34 -0500
In-Reply-To: <1359218007-18586-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olivier Sobrie <olivier@sobrie.be>

Errors in CAN protocol (location) are reported in data[3] of the can
frame instead of data[2].

Cc: linux-stable <stable@vger.kernel.org>
Cc: Bhupesh Sharma <bhupesh.sharma@st.com>
Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 5233b8f..58607f1 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -960,7 +960,7 @@ static int c_can_handle_bus_err(struct net_device *dev,
 		break;
 	case LEC_ACK_ERROR:
 		netdev_dbg(dev, "ack error\n");
-		cf->data[2] |= (CAN_ERR_PROT_LOC_ACK |
+		cf->data[3] |= (CAN_ERR_PROT_LOC_ACK |
 				CAN_ERR_PROT_LOC_ACK_DEL);
 		break;
 	case LEC_BIT1_ERROR:
@@ -973,7 +973,7 @@ static int c_can_handle_bus_err(struct net_device *dev,
 		break;
 	case LEC_CRC_ERROR:
 		netdev_dbg(dev, "CRC error\n");
-		cf->data[2] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
+		cf->data[3] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
 				CAN_ERR_PROT_LOC_CRC_DEL);
 		break;
 	default:
-- 
1.7.10.4
