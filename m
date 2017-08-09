From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: removed check for queue size alignment
Date: Wed, 9 Aug 2017 13:28:04 -0700
Message-ID: <20170809202804.GA1238@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0059.outbound.protection.outlook.com ([104.47.42.59]:5345
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752047AbdHIUZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 16:25:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

There is no restriction on queue size alignment.  Hence removing check for
valid queue size.

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/request_manager.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 7b297f1..770281f 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -77,13 +77,6 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 		return 1;
 	}
 
-	if (num_descs & (num_descs - 1)) {
-		dev_err(&oct->pci_dev->dev,
-			"Number of descriptors for instr queue %d not in power of 2.\n",
-			iq_no);
-		return 1;
-	}
-
 	q_size = (u32)conf->instr_type * num_descs;
 
 	iq = oct->instr_queue[iq_no];
