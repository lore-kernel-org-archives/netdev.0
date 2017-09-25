From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH v2 1/4] net: af_packet: use setup_timer() helper.
Date: Mon, 25 Sep 2017 13:00:02 +0530
Message-ID: <1506324605-10160-1-git-send-email-allen.lkml@gmail.com>
Cc: davem@davemloft.net, sameo@linux.intel.com,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33133 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932135AbdIYHaO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 03:30:14 -0400
Received: by mail-pg0-f68.google.com with SMTP id i130so4445068pgc.0
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 00:30:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use setup_timer function instead of initializing timer with the
function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
v2: rebased to latest net-next.

 net/packet/af_packet.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d288f52..b0f2218 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -544,9 +544,7 @@ static void prb_init_blk_timer(struct packet_sock *po,
 		struct tpacket_kbdq_core *pkc,
 		void (*func) (unsigned long))
 {
-	init_timer(&pkc->retire_blk_timer);
-	pkc->retire_blk_timer.data = (long)po;
-	pkc->retire_blk_timer.function = func;
+	setup_timer(&pkc->retire_blk_timer, func, (long)po);
 	pkc->retire_blk_timer.expires = jiffies;
 }
 
-- 
2.7.4
