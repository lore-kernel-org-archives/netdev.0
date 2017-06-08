From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 2/3] LiquidIO: lowmem: do not dereference NULL ptr
Date: Wed, 7 Jun 2017 20:52:52 -0700
Message-ID: <20170608035252.GA1645@felix-thinkpad.cavium.com>
References: <20170608035045.GA1608@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0079.outbound.protection.outlook.com ([104.47.33.79]:32568
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751502AbdFHDxB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 23:53:01 -0400
Content-Disposition: inline
In-Reply-To: <20170608035045.GA1608@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Don't dereference a NULL ptr in octeon_droq_destroy_ring_buffers().

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 07c764d..d868252 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -145,6 +145,8 @@ static void octeon_droq_reset_indices(struct octeon_droq *droq)
 
 	for (i = 0; i < droq->max_count; i++) {
 		pg_info = &droq->recv_buf_list[i].pg_info;
+		if (!pg_info)
+			continue;
 
 		if (pg_info->dma)
 			lio_unmap_ring(oct->pci_dev,
-- 
1.8.3.1
