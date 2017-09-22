From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 3/5] net: af_packet: use setup_timer() helper.
Date: Fri, 22 Sep 2017 16:28:20 +0530
Message-ID: <1506077902-1796-4-git-send-email-allen.lkml@gmail.com>
References: <1506077902-1796-1-git-send-email-allen.lkml@gmail.com>
Cc: davem@davemloft.net, sameo@linux.intel.com,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36727 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751903AbdIVK6i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 06:58:38 -0400
Received: by mail-pg0-f68.google.com with SMTP id d8so438668pgt.3
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 03:58:38 -0700 (PDT)
In-Reply-To: <1506077902-1796-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Use setup_timer function instead of initializing timer with the
   function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 net/packet/af_packet.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c261729..1d3e3ce 100644
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
