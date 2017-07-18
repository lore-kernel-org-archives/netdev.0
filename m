From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH v2 net-next 2/3] liquidio: lowmem: do not dereference null ptr
Date: Mon, 17 Jul 2017 17:51:10 -0700
Message-ID: <20170718005110.GA1567@felix-thinkpad.cavium.com>
References: <20170718004920.GA1541@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0054.outbound.protection.outlook.com ([104.47.32.54]:27523
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751617AbdGRAn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 20:43:28 -0400
Content-Disposition: inline
In-Reply-To: <20170718004920.GA1541@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Don't dereference a NULL ptr in octeon_droq_destroy_ring_buffers().

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 6456683..f7b5d68 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -145,6 +145,8 @@ octeon_droq_destroy_ring_buffers(struct octeon_device *oct,
 
 	for (i = 0; i < droq->max_count; i++) {
 		pg_info = &droq->recv_buf_list[i].pg_info;
+		if (!pg_info)
+			continue;
 
 		if (pg_info->dma)
 			lio_unmap_ring(oct->pci_dev,
-- 
2.9.0
