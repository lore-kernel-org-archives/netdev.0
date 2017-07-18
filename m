From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH v2 net-next 1/3] liquidio: lowmem: init allocated memory to 0
Date: Mon, 17 Jul 2017 17:50:47 -0700
Message-ID: <20170718005047.GA1558@felix-thinkpad.cavium.com>
References: <20170718004920.GA1541@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0054.outbound.protection.outlook.com ([104.47.32.54]:5760
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751617AbdGRAnF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 20:43:05 -0400
Content-Disposition: inline
In-Reply-To: <20170718004920.GA1541@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Fix GPF in octeon_init_droq(); zero the allocated block 'recv_buf_list'.
This prevents a GPF trying to access an invalid 'recv_buf_list[i]' entry
in octeon_droq_destroy_ring_buffers() if init didn't alloc all entries.

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 2e190de..6456683 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -275,12 +275,12 @@ int octeon_init_droq(struct octeon_device *oct,
 		droq->max_count);
 
 	droq->recv_buf_list = (struct octeon_recv_buffer *)
-			      vmalloc_node(droq->max_count *
+			      vzalloc_node(droq->max_count *
 						OCT_DROQ_RECVBUF_SIZE,
 						numa_node);
 	if (!droq->recv_buf_list)
 		droq->recv_buf_list = (struct octeon_recv_buffer *)
-				      vmalloc(droq->max_count *
+				      vzalloc(droq->max_count *
 						OCT_DROQ_RECVBUF_SIZE);
 	if (!droq->recv_buf_list) {
 		dev_err(&oct->pci_dev->dev, "Output queue recv buf list alloc failed\n");
-- 
2.9.0
