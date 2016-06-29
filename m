From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 1/1] qlcnic: add wmb() call in transmit data path.
Date: Wed, 29 Jun 2016 17:51:34 -0400
Message-ID: <1467237094-23088-2-git-send-email-sony.chacko@qlogic.com>
References: <1467237094-23088-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:12491 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751483AbcF2XEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 19:04:43 -0400
In-Reply-To: <1467237094-23088-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call wmb() to ensure writes are complete before
hardware fetches updated Tx descriptors.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 607bb7d..87c642d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -772,6 +772,8 @@ netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	tx_ring->tx_stats.tx_bytes += skb->len;
 	tx_ring->tx_stats.xmit_called++;
 
+	/* Ensure writes are complete before HW fetches Tx descriptors */
+	wmb();
 	qlcnic_update_cmd_producer(tx_ring);
 
 	return NETDEV_TX_OK;
-- 
1.7.1
