From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/8] can: m_can: tag current CAN FD controllers as non-ISO
Date: Thu, 15 Jan 2015 17:11:18 +0100
Message-ID: <1421338283-12417-4-git-send-email-mkl@pengutronix.de>
References: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>

During the CAN FD standardization process within the ISO it turned out that
the failure detection capability has to be improved.

The CAN in Automation organization (CiA) defined the already implemented CAN
FD controllers as 'non-ISO' and the upcoming improved CAN FD controllers as
'ISO' compliant. See at http://www.can-cia.com/index.php?id=1937

Finally there will be three types of CAN FD controllers in the future:

1. ISO compliant (fixed)
2. non-ISO compliant (fixed, like the M_CAN IP v3.0.1 in m_can.c)
3. ISO/non-ISO CAN FD controllers (switchable, like the PEAK USB FD)

So the current M_CAN driver for the M_CAN IP v3.0.1 has to expose its non-ISO
implementation by setting the CAN_CTRLMODE_FD_NON_ISO ctrlmode at startup.
As this bit cannot be switched at configuration time CAN_CTRLMODE_FD_NON_ISO
must not be set in ctrlmode_supported of the current M_CAN driver.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/m_can/m_can.c    | 5 +++++
 include/uapi/linux/can/netlink.h | 1 +
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index d7bc462aafdc..244529881be9 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -955,6 +955,11 @@ static struct net_device *alloc_m_can_dev(void)
 	priv->can.data_bittiming_const = &m_can_data_bittiming_const;
 	priv->can.do_set_mode = m_can_set_mode;
 	priv->can.do_get_berr_counter = m_can_get_berr_counter;
+
+	/* CAN_CTRLMODE_FD_NON_ISO is fixed with M_CAN IP v3.0.1 */
+	priv->can.ctrlmode = CAN_CTRLMODE_FD_NON_ISO;
+
+	/* CAN_CTRLMODE_FD_NON_ISO can not be changed with M_CAN IP v3.0.1 */
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_LOOPBACK |
 					CAN_CTRLMODE_LISTENONLY |
 					CAN_CTRLMODE_BERR_REPORTING |
diff --git a/include/uapi/linux/can/netlink.h b/include/uapi/linux/can/netlink.h
index 3e4323a3918d..94ffe0c83ce7 100644
--- a/include/uapi/linux/can/netlink.h
+++ b/include/uapi/linux/can/netlink.h
@@ -98,6 +98,7 @@ struct can_ctrlmode {
 #define CAN_CTRLMODE_BERR_REPORTING	0x10	/* Bus-error reporting */
 #define CAN_CTRLMODE_FD			0x20	/* CAN FD mode */
 #define CAN_CTRLMODE_PRESUME_ACK	0x40	/* Ignore missing CAN ACKs */
+#define CAN_CTRLMODE_FD_NON_ISO		0x80	/* CAN FD in non-ISO mode */
 
 /*
  * CAN device statistics
-- 
2.1.4

