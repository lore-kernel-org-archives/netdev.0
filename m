From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v6 net-next 06/17] net: qualcomm: Improve readability of length defines
Date: Tue, 23 May 2017 15:12:42 +0200
Message-ID: <1495545173-22150-7-git-send-email-stefan.wahren@i2se.com>
References: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:63388 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967543AbdEWNOx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 09:14:53 -0400
In-Reply-To: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to avoid mixing things up, make the MTU and frame length
defines easier to read.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_framing.c |  2 +-
 drivers/net/ethernet/qualcomm/qca_framing.h |  8 ++++----
 drivers/net/ethernet/qualcomm/qca_spi.c     | 12 ++++++------
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_framing.c b/drivers/net/ethernet/qualcomm/qca_framing.c
index faa924c..2341f2b 100644
--- a/drivers/net/ethernet/qualcomm/qca_framing.c
+++ b/drivers/net/ethernet/qualcomm/qca_framing.c
@@ -117,7 +117,7 @@ qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_by
 		break;
 	case QCAFRM_WAIT_RSVD_BYTE2:
 		len = handle->offset;
-		if (len > buf_len || len < QCAFRM_ETHMINLEN) {
+		if (len > buf_len || len < QCAFRM_MIN_LEN) {
 			ret = QCAFRM_INVLEN;
 			handle->state = QCAFRM_HW_LEN0;
 		} else {
diff --git a/drivers/net/ethernet/qualcomm/qca_framing.h b/drivers/net/ethernet/qualcomm/qca_framing.h
index 8b385e6..5df7c65 100644
--- a/drivers/net/ethernet/qualcomm/qca_framing.h
+++ b/drivers/net/ethernet/qualcomm/qca_framing.h
@@ -44,12 +44,12 @@
 #define QCAFRM_INVFRAME (QCAFRM_ERR_BASE - 4)
 
 /* Min/Max Ethernet MTU: 46/1500 */
-#define QCAFRM_ETHMINMTU (ETH_ZLEN - ETH_HLEN)
-#define QCAFRM_ETHMAXMTU ETH_DATA_LEN
+#define QCAFRM_MIN_MTU (ETH_ZLEN - ETH_HLEN)
+#define QCAFRM_MAX_MTU ETH_DATA_LEN
 
 /* Min/Max frame lengths */
-#define QCAFRM_ETHMINLEN (QCAFRM_ETHMINMTU + ETH_HLEN)
-#define QCAFRM_ETHMAXLEN (QCAFRM_ETHMAXMTU + VLAN_ETH_HLEN)
+#define QCAFRM_MIN_LEN (QCAFRM_MIN_MTU + ETH_HLEN)
+#define QCAFRM_MAX_LEN (QCAFRM_MAX_MTU + VLAN_ETH_HLEN)
 
 /* QCA7K header len */
 #define QCAFRM_HEADER_LEN 8
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 7e039e3..f155548 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -69,7 +69,7 @@ static int qcaspi_pluggable = QCASPI_PLUGGABLE_MIN;
 module_param(qcaspi_pluggable, int, 0);
 MODULE_PARM_DESC(qcaspi_pluggable, "Pluggable SPI connection (yes/no).");
 
-#define QCASPI_MTU QCAFRM_ETHMAXMTU
+#define QCASPI_MTU QCAFRM_MAX_MTU
 #define QCASPI_TX_TIMEOUT (1 * HZ)
 #define QCASPI_QCA7K_REBOOT_TIME_MS 1000
 
@@ -403,7 +403,7 @@ qcaspi_tx_ring_has_space(struct tx_ring *txr)
 	if (txr->skb[txr->tail])
 		return 0;
 
-	return (txr->size + QCAFRM_ETHMAXLEN < QCASPI_HW_BUF_LEN) ? 1 : 0;
+	return (txr->size + QCAFRM_MAX_LEN < QCASPI_HW_BUF_LEN) ? 1 : 0;
 }
 
 /*   Flush the tx ring. This function is only safe to
@@ -667,8 +667,8 @@ qcaspi_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct sk_buff *tskb;
 	u8 pad_len = 0;
 
-	if (skb->len < QCAFRM_ETHMINLEN)
-		pad_len = QCAFRM_ETHMINLEN - skb->len;
+	if (skb->len < QCAFRM_MIN_LEN)
+		pad_len = QCAFRM_MIN_LEN - skb->len;
 
 	if (qca->txr.skb[qca->txr.tail]) {
 		netdev_warn(qca->net_dev, "queue was unexpectedly full!\n");
@@ -805,8 +805,8 @@ qcaspi_netdev_setup(struct net_device *dev)
 	dev->tx_queue_len = 100;
 
 	/* MTU range: 46 - 1500 */
-	dev->min_mtu = QCAFRM_ETHMINMTU;
-	dev->max_mtu = QCAFRM_ETHMAXMTU;
+	dev->min_mtu = QCAFRM_MIN_MTU;
+	dev->max_mtu = QCAFRM_MAX_MTU;
 
 	qca = netdev_priv(dev);
 	memset(qca, 0, sizeof(struct qcaspi));
-- 
2.1.4
