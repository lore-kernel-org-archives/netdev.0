From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 03/13] s390/qeth: warning for OSA3 RX/TX checksum offloading
Date: Wed, 11 Jan 2017 12:55:50 +0100
Message-ID: <20170111115600.4524-4-ubraun@linux.vnet.ibm.com>
References: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

When RX/TX checksum offloading is turned on and the adapter is
an OSA 3 card in layer 3 mode, the checksum offloading is only
performed when both peers use different adapters. If both peers
share an OSA 3 card, communication is a memory copy and
checksum offloading is not performed.

This patch adds a warning to inform the administrator.

OSA 3 in layer 2 mode does not offer the RX/TX checksum
offload feature.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 49b813f..ca8309f 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -6116,6 +6116,11 @@ static int qeth_send_checksum_on(struct qeth_card *card, int cstype)
 		if ((required_features & chksum_cb.supported) !=
 		    required_features)
 			rc = -EIO;
+		else if (!(QETH_IPA_CHECKSUM_LP2LP & chksum_cb.supported) &&
+			 cstype == IPA_INBOUND_CHECKSUM)
+			dev_warn(&card->gdev->dev,
+				 "Hardware checksumming is performed only if %s and its peer use different OSA Express 3 ports\n",
+				 QETH_CARD_IFNAME(card));
 	}
 	if (rc) {
 		qeth_send_simple_setassparms(card, cstype, IPA_CMD_ASS_STOP, 0);
-- 
2.8.4
