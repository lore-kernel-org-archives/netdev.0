From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 1/3] LiquidIO: lowmem: init allocated memory to 0
Date: Wed, 7 Jun 2017 20:52:23 -0700
Message-ID: <20170608035223.GA1632@felix-thinkpad.cavium.com>
References: <20170608035045.GA1608@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0066.outbound.protection.outlook.com ([104.47.41.66]:48209
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751502AbdFHDwe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 23:52:34 -0400
Content-Disposition: inline
In-Reply-To: <20170608035045.GA1608@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Fix GPF in octeon_init_droq(); zero the allocated block 'recv_buf_list'.
This prevents a GPF trying to access an invalid 'recv_buf_list[i]' entry
in octeon_droq_destroy_ring_buffers() if init didn't alloc all entries.

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 286be55..07c764d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -289,12 +289,12 @@ int octeon_init_droq(struct octeon_device *oct,
 	}
 
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
1.8.3.1
