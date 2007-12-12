From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 2/7] : e1000e Fix possible causing oops of net_rx_action
Date: Wed, 12 Dec 2007 13:01:27 +0900
Message-ID: <002d01c83c73$b5807760$9c94fea9@jason>
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
	with ESMTP id S1754086AbXLLEBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 23:01:45 -0500
Received: by wa-out-1112.google.com with SMTP id v27so124841wah.23
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 20:01:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NETDEV]: e1000e Fix possible causing oops of net_rx_action

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/e1000e/netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4fd2e23..8e4861a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1412,6 +1412,8 @@ quit_polling:
 			e1000_set_itr(adapter);
 		netif_rx_complete(poll_dev, napi);
 		e1000_irq_enable(adapter);
+		if (unlikely(work_done == napi->weight))
+			return work_done - 1;
 	}
 
 	return work_done;
---

