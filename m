From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 10/12] qed: Support Multicast on Tx-switching
Date: Sun, 1 Jan 2017 13:57:09 +0200
Message-ID: <1483271831-25890-11-git-send-email-Yuval.Mintz@cavium.com>
References: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53891 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932205AbdAAL63 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:58:29 -0500
In-Reply-To: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently multicast traffic wouldn't be routed internally to
listener; Instead it would only be sent to network via the
physical carrier.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index a35db69..c92a850 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -2210,11 +2210,14 @@ static int qed_configure_filter_rx_mode(struct qed_dev *cdev,
 					QED_ACCEPT_MCAST_MATCHED |
 					QED_ACCEPT_BCAST;
 
-	if (type == QED_FILTER_RX_MODE_TYPE_PROMISC)
+	if (type == QED_FILTER_RX_MODE_TYPE_PROMISC) {
 		accept_flags.rx_accept_filter |= QED_ACCEPT_UCAST_UNMATCHED |
 						 QED_ACCEPT_MCAST_UNMATCHED;
-	else if (type == QED_FILTER_RX_MODE_TYPE_MULTI_PROMISC)
+		accept_flags.tx_accept_filter |= QED_ACCEPT_MCAST_UNMATCHED;
+	} else if (type == QED_FILTER_RX_MODE_TYPE_MULTI_PROMISC) {
 		accept_flags.rx_accept_filter |= QED_ACCEPT_MCAST_UNMATCHED;
+		accept_flags.tx_accept_filter |= QED_ACCEPT_MCAST_UNMATCHED;
+	}
 
 	return qed_filter_accept_cmd(cdev, 0, accept_flags, false, false,
 				     QED_SPQ_MODE_CB, NULL);
-- 
1.9.3
