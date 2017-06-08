From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 3/3] LiquidIO: lowmem: init allocated memory to 0
Date: Wed, 7 Jun 2017 20:53:22 -0700
Message-ID: <20170608035322.GA1658@felix-thinkpad.cavium.com>
References: <20170608035045.GA1608@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0078.outbound.protection.outlook.com ([104.47.34.78]:41315
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751502AbdFHDxa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 23:53:30 -0400
Content-Disposition: inline
In-Reply-To: <20170608035045.GA1608@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

For defensive programming, zero the allocated block 'oct->droq[0]' in
octeon_setup_output_queues() and 'oct->instr_queue[0]' in
octeon_setup_instr_queues().

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_device.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 3b7cc93..087820b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -880,11 +880,11 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 
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
@@ -927,9 +927,9 @@ int octeon_setup_output_queues(struct octeon_device *oct)
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
1.8.3.1
