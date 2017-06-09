From: <netanel@amazon.com>
Subject: [PATCH net-next 3/8] net: ena: add missing return when ena_com_get_io_handlers() fails
Date: Fri, 9 Jun 2017 09:55:19 +0300
Message-ID: <1496991325-551-4-git-send-email-netanel@amazon.com>
References: <1496991325-551-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:34599 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751625AbdFIG4R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 02:56:17 -0400
In-Reply-To: <1496991325-551-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 0e3c60c7..1e71e89 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -1543,6 +1543,7 @@ static int ena_create_io_tx_queue(struct ena_adapter *adapter, int qid)
 			  "Failed to get TX queue handlers. TX queue num %d rc: %d\n",
 			  qid, rc);
 		ena_com_destroy_io_queue(ena_dev, ena_qid);
+		return rc;
 	}
 
 	ena_com_update_numa_node(tx_ring->ena_com_io_cq, ctx.numa_node);
@@ -1607,6 +1608,7 @@ static int ena_create_io_rx_queue(struct ena_adapter *adapter, int qid)
 			  "Failed to get RX queue handlers. RX queue num %d rc: %d\n",
 			  qid, rc);
 		ena_com_destroy_io_queue(ena_dev, ena_qid);
+		return rc;
 	}
 
 	ena_com_update_numa_node(rx_ring->ena_com_io_cq, ctx.numa_node);
-- 
2.7.4
