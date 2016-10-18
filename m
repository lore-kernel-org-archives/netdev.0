From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v3 net-next 3/8] net: qualcomm: move qcaspi_tx_cmd to qca_spi.c
Date: Tue, 18 Oct 2016 13:27:29 +0200
Message-ID: <1476790054-27174-4-git-send-email-stefan.wahren@i2se.com>
References: <1476790054-27174-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476790054-27174-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function qcaspi_tx_cmd() is only called from qca_spi.c. So we better
move it there.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_7k.c  | 24 ------------------------
 drivers/net/ethernet/qualcomm/qca_7k.h  |  1 -
 drivers/net/ethernet/qualcomm/qca_spi.c | 24 ++++++++++++++++++++++++
 3 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_7k.c b/drivers/net/ethernet/qualcomm/qca_7k.c
index 557d53c..aa90a1d 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k.c
+++ b/drivers/net/ethernet/qualcomm/qca_7k.c
@@ -119,27 +119,3 @@ qcaspi_write_register(struct qcaspi *qca, u16 reg, u16 value)
 
 	return ret;
 }
-
-int
-qcaspi_tx_cmd(struct qcaspi *qca, u16 cmd)
-{
-	__be16 tx_data;
-	struct spi_message *msg = &qca->spi_msg1;
-	struct spi_transfer *transfer = &qca->spi_xfer1;
-	int ret;
-
-	tx_data = cpu_to_be16(cmd);
-	transfer->len = sizeof(tx_data);
-	transfer->tx_buf = &tx_data;
-	transfer->rx_buf = NULL;
-
-	ret = spi_sync(qca->spi_dev, msg);
-
-	if (!ret)
-		ret = msg->status;
-
-	if (ret)
-		qcaspi_spi_error(qca);
-
-	return ret;
-}
diff --git a/drivers/net/ethernet/qualcomm/qca_7k.h b/drivers/net/ethernet/qualcomm/qca_7k.h
index 1cad851..b390b1f 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k.h
+++ b/drivers/net/ethernet/qualcomm/qca_7k.h
@@ -67,6 +67,5 @@
 void qcaspi_spi_error(struct qcaspi *qca);
 int qcaspi_read_register(struct qcaspi *qca, u16 reg, u16 *result);
 int qcaspi_write_register(struct qcaspi *qca, u16 reg, u16 value);
-int qcaspi_tx_cmd(struct qcaspi *qca, u16 cmd);
 
 #endif /* _QCA_7K_H */
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 6e2add9..5bcac62 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -192,6 +192,30 @@ qcaspi_read_legacy(struct qcaspi *qca, u8 *dst, u32 len)
 	return len;
 }
 
+int
+qcaspi_tx_cmd(struct qcaspi *qca, u16 cmd)
+{
+	__be16 tx_data;
+	struct spi_message *msg = &qca->spi_msg1;
+	struct spi_transfer *transfer = &qca->spi_xfer1;
+	int ret;
+
+	tx_data = cpu_to_be16(cmd);
+	transfer->len = sizeof(tx_data);
+	transfer->tx_buf = &tx_data;
+	transfer->rx_buf = NULL;
+
+	ret = spi_sync(qca->spi_dev, msg);
+
+	if (!ret)
+		ret = msg->status;
+
+	if (ret)
+		qcaspi_spi_error(qca);
+
+	return ret;
+}
+
 static int
 qcaspi_tx_frame(struct qcaspi *qca, struct sk_buff *skb)
 {
-- 
2.1.4
