From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/3] can: ti_hecc: fix invalid error codes
Date: Sat, 26 Jan 2013 17:33:26 +0100
Message-ID: <1359218007-18586-3-git-send-email-mkl@pengutronix.de>
References: <1359218007-18586-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>,
	linux-stable <stable@vger.kernel.org>,
	Anant Gole <anantgole@ti.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1359218007-18586-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olivier Sobrie <olivier@sobrie.be>

Errors in CAN protocol (location) are reported in data[3] of the can
frame instead of data[2].

Cc: linux-stable <stable@vger.kernel.org>
Cc: Anant Gole <anantgole@ti.com>
Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/ti_hecc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index f898c63..300581b 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -746,12 +746,12 @@ static int ti_hecc_error(struct net_device *ndev, int int_status,
 		}
 		if (err_status & HECC_CANES_CRCE) {
 			hecc_set_bit(priv, HECC_CANES, HECC_CANES_CRCE);
-			cf->data[2] |= CAN_ERR_PROT_LOC_CRC_SEQ |
+			cf->data[3] |= CAN_ERR_PROT_LOC_CRC_SEQ |
 					CAN_ERR_PROT_LOC_CRC_DEL;
 		}
 		if (err_status & HECC_CANES_ACKE) {
 			hecc_set_bit(priv, HECC_CANES, HECC_CANES_ACKE);
-			cf->data[2] |= CAN_ERR_PROT_LOC_ACK |
+			cf->data[3] |= CAN_ERR_PROT_LOC_ACK |
 					CAN_ERR_PROT_LOC_ACK_DEL;
 		}
 	}
-- 
1.7.10.4
