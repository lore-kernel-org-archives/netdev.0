From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 1/7] : e1000 Fix possible causing oops of net_rx_action
Date: Wed, 12 Dec 2007 13:01:27 +0900
Message-ID: <002e01c83c73$b6f934b0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Kok, Auke'" <auke-jan.h.kok@intel.com>,
	<jesse.brandeburg@intel.com>, <jgarzik@pobox.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:40145 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754875AbXLLEBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 23:01:48 -0500
Received: by wa-out-1112.google.com with SMTP id v27so124840wah.23
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 20:01:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NETDEV]: e1000 Fix possible causing oops of net_rx_action
returning work_done == weight as true after calling netif_rx_complete will cause oops in net_rx_action.

Thanks
Joonwoo

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/e1000/e1000_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4f37506..4dd61e3 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3949,6 +3949,8 @@ quit_polling:
 			e1000_set_itr(adapter);
 		netif_rx_complete(poll_dev, napi);
 		e1000_irq_enable(adapter);
+		if (unlikely(work_done == napi->weight))
+			return work_done - 1;
 	}
 
 	return work_done;
---

