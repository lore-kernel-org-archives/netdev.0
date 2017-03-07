From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: add support for XPS
Date: Tue, 7 Mar 2017 11:40:41 -0800
Message-ID: <20170307194041.GA13791@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0071.outbound.protection.outlook.com ([104.47.42.71]:13766
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755292AbdCGTmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 14:42:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Add support for XPS.

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index be9c0e3..dffed43 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2553,6 +2553,15 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 				__func__);
 			return 1;
 		}
+
+		if (octeon_dev->ioq_vector) {
+			struct octeon_ioq_vector *ioq_vector;
+
+			ioq_vector = &octeon_dev->ioq_vector[q];
+			netif_set_xps_queue(netdev,
+					    &ioq_vector->affinity_mask,
+					    ioq_vector->iq_index);
+		}
 	}
 
 	return 0;
