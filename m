From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 6/7] : tehuti Fix possible causing oops of net_rx_action
Date: Wed, 12 Dec 2007 13:01:27 +0900
Message-ID: <002901c83c73$b089b6e0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <baum@tehutinetworks.net>,
	<andy@greyhouse.net>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:40145 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbXLLEBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 23:01:37 -0500
Received: by wa-out-1112.google.com with SMTP id v27so124840wah.23
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 20:01:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NETDEV]: tehuti Fix possible causing oops of net_rx_action

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/tehuti.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 21230c9..955e749 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -305,6 +305,8 @@ static int bdx_poll(struct napi_struct *napi, int budget)
 
 		netif_rx_complete(dev, napi);
 		bdx_enable_interrupts(priv);
+		if (unlikely(work_done == napi->weight))
+			return work_done - 1;
 	}
 	return work_done;
 }
---

