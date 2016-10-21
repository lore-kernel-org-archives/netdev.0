From: <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 4/7] qed*: Reduce the memory footprint for Rx path
Date: Fri, 21 Oct 2016 04:43:42 -0400
Message-ID: <1477039425-31341-5-git-send-email-sudarsana.kalluru@cavium.com>
References: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@cavium.com>,
        <Yuval.Mintz@cavium.com>, <manish.chopra@cavium.com>,
        Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49039 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933919AbcJUJaB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 05:30:01 -0400
In-Reply-To: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>

With the current default values for Rx path i.e., 8 queues of 8Kb entries
each with 4Kb size, interface will consume 256Mb for Rx. The default values
causing the driver probe to fail when the system memory is low. Based on
the perforamnce results, rx-ring count value of 1Kb gives the comparable
performance with Rx coalesce timeout of 12 seconds. Updating the default
values.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 1 +
 drivers/net/ethernet/qlogic/qede/qede.h    | 2 +-
 include/linux/qed/qed_if.h                 | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 8dc3f46..c418360 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -878,6 +878,7 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 		}
 	}
 
+	cdev->rx_coalesce_usecs = QED_DEFAULT_RX_USECS;
 	rc = qed_nic_setup(cdev);
 	if (rc)
 		goto err;
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index d6a4a9a5..974689a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -354,7 +354,7 @@ void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq, struct qede_dev *edev,
 #define RX_RING_SIZE		((u16)BIT(RX_RING_SIZE_POW))
 #define NUM_RX_BDS_MAX		(RX_RING_SIZE - 1)
 #define NUM_RX_BDS_MIN		128
-#define NUM_RX_BDS_DEF		NUM_RX_BDS_MAX
+#define NUM_RX_BDS_DEF		((u16)BIT(10) - 1)
 
 #define TX_RING_SIZE_POW	13
 #define TX_RING_SIZE		((u16)BIT(TX_RING_SIZE_POW))
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index f9ae903..8978a60 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -146,6 +146,7 @@ enum qed_led_mode {
 #define DIRECT_REG_RD(reg_addr) readl((void __iomem *)(reg_addr))
 
 #define QED_COALESCE_MAX 0xFF
+#define QED_DEFAULT_RX_USECS 12
 
 /* forward */
 struct qed_dev;
-- 
1.8.3.1
