From: Louis Rilling <louis.rilling@kerlabs.com>
Subject: [PATCH] tg3: Fix tg3_poll_controller() passing wrong pointer to tg3_interrupt()
Date: Tue,  9 Mar 2010 17:14:41 +0100
Message-ID: <1268151281-15012-1-git-send-email-louis.rilling@kerlabs.com>
Cc: Louis Rilling <louis.rilling@kerlabs.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	stable@kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bohort.kerlabs.com ([62.160.40.57]:34836 "EHLO
	bohort.kerlabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418Ab0CIQPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 11:15:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resending without buggy address for stable. Sorry.]

Commit 09943a1819a240ff4a72f924d0038818fcdd0a90
	Author: Matt Carlson <mcarlson@broadcom.com>
	Date:   Fri Aug 28 14:01:57 2009 +0000

	tg3: Convert ISR parameter to tnapi

forgot to update tg3_poll_controller(), leading to intermittent crashes with
netpoll.

Fix this.

Signed-off-by: Louis Rilling <louis.rilling@kerlabs.com>
Cc: stable@kernel.org
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0fa7688..c3b4fe7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5279,7 +5279,7 @@ static void tg3_poll_controller(struct net_device *dev)
 	struct tg3 *tp = netdev_priv(dev);
 
 	for (i = 0; i < tp->irq_cnt; i++)
-		tg3_interrupt(tp->napi[i].irq_vec, dev);
+		tg3_interrupt(tp->napi[i].irq_vec, &tp->napi[i]);
 }
 #endif
 
-- 
1.5.6.5

