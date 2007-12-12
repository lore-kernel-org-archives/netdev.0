From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 4/7] : ixgbe Fix possible causing oops of net_rx_action
Date: Wed, 12 Dec 2007 13:01:27 +0900
Message-ID: <002b01c83c73$b2bebf50$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Kok, Auke'" <auke-jan.h.kok@intel.com>,
	<jesse.brandeburg@intel.com>, <jgarzik@pobox.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:40455 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbXLLEBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 23:01:40 -0500
Received: by wa-out-1112.google.com with SMTP id v27so124841wah.23
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 20:01:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NETDEV]: ixgbe Fix possible causing oops of net_rx_action

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 00bc525..0b3ae8f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -583,6 +583,8 @@ quit_polling:
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS,
 					rxr->eims_value);
+		if (unlikely(work_done == napi->weight))
+			return work_done - 1;
 	}
 
 	return work_done;
@@ -1485,6 +1487,8 @@ static int ixgbe_clean(struct napi_struct *napi, int budget)
 quit_polling:
 		netif_rx_complete(netdev, napi);
 		ixgbe_irq_enable(adapter);
+		if (unlikely(work_done == napi->weight))
+			return work_done - 1;
 	}
 
 	return work_done;
---

