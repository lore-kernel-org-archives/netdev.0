From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH v2 net-next 3/3] liquidio: lowmem: init allocated memory to 0
Date: Mon, 17 Jul 2017 17:51:37 -0700
Message-ID: <20170718005137.GA1579@felix-thinkpad.cavium.com>
References: <20170718004920.GA1541@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0053.outbound.protection.outlook.com ([104.47.42.53]:59648
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751617AbdGRAny (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 20:43:54 -0400
Content-Disposition: inline
In-Reply-To: <20170718004920.GA1541@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

For defensive programming, zero the allocated block 'oct->droq[0]' in
octeon_setup_output_queues() and 'oct->instr_queue[0]' in
octeon_setup_instr_queues().

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_device.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 623e28c..f10014f7 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -876,11 +876,11 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 
 	oct->num_iqs = 0;
 
-	oct->instr_queue[0] = vmalloc_node(sizeof(*oct->instr_queue[0]),
+	oct->instr_queue[0] = vzalloc_node(sizeof(*oct->instr_queue[0]),
 				numa_node);
 	if (!oct->instr_queue[0])
 		oct->instr_queue[0] =
-			vmalloc(sizeof(struct octeon_instr_queue));
+			vzalloc(sizeof(struct octeon_instr_queue));
 	if (!oct->instr_queue[0])
 		return 1;
 	memset(oct->instr_queue[0], 0, sizeof(struct octeon_instr_queue));
@@ -923,9 +923,9 @@ int octeon_setup_output_queues(struct octeon_device *oct)
 		desc_size = CFG_GET_DEF_RX_BUF_SIZE(CHIP_CONF(oct, cn23xx_vf));
 	}
 	oct->num_oqs = 0;
-	oct->droq[0] = vmalloc_node(sizeof(*oct->droq[0]), numa_node);
+	oct->droq[0] = vzalloc_node(sizeof(*oct->droq[0]), numa_node);
 	if (!oct->droq[0])
-		oct->droq[0] = vmalloc(sizeof(*oct->droq[0]));
+		oct->droq[0] = vzalloc(sizeof(*oct->droq[0]));
 	if (!oct->droq[0])
 		return 1;
 
-- 
2.9.0
