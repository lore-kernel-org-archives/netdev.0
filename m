From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: [PATCH] neigh: print nud_state in neigh timer handler.
Date: Mon, 31 Oct 2011 23:10:48 +0200
Message-ID: <1320095448-5228-1-git-send-email-dbaluta@ixiacom.com>
Cc: eric.dumazet@gmail.com, gregory.v.rose@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	Daniel Baluta <daniel.baluta@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44483 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab1JaVL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2011 17:11:27 -0400
Received: by bkbzt4 with SMTP id zt4so2503884bkb.19
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2011 14:11:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <daniel.baluta@gmail.com>

For debugging purposes it is useful to know the exact state of a
non NUD_IN_TIMER neighbour entry whose timer handler just expired.

Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
---
 net/core/neighbour.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 909ecb3..6a8a311 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -874,7 +874,7 @@ static void neigh_timer_handler(unsigned long arg)
 
 	if (!(state & NUD_IN_TIMER)) {
 #ifndef CONFIG_SMP
-		printk(KERN_WARNING "neigh: timer & !nud_in_timer\n");
+		printk(KERN_WARNING "neigh: timer & !nud_in_timer, state:0x%x\n", state);
 #endif
 		goto out;
 	}
-- 
1.7.1
