From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 5/7] : e100 Fix possible causing oops of net_rx_action
Date: Wed, 12 Dec 2007 13:01:27 +0900
Message-ID: <002a01c83c73$b1a7d110$9c94fea9@jason>
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
	with ESMTP id S1753121AbXLLEBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 23:01:38 -0500
Received: by wa-out-1112.google.com with SMTP id v27so124841wah.23
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 20:01:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NETDEV]: e100 Fix possible causing oops of net_rx_action

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/e100.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index e1c8a0d..7cb4ed0 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2000,6 +2000,8 @@ static int e100_poll(struct napi_struct *napi, int budget)
 	if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
 		netif_rx_complete(netdev, napi);
 		e100_enable_irq(nic);
+		if (unlikely(work_done == napi->weight))
+			return work_done - 1;
 	}
 
 	return work_done;
---

