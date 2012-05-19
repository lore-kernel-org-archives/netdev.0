From: <rajan.gupta@freescale.com>
Subject: [PATCH] net : fix for dst_gc_task not getting scheduled if __dst_free() is called consistently
Date: Sat, 19 May 2012 04:39:54 -0500
Message-ID: <1337420394-28115-1-git-send-email-rajan.gupta@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rajan Gupta <rajan.gupta@freescale.com>
To: <"netdev@vger.kernel.org.kuznet"@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:46380
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752847Ab2ESJkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 05:40:16 -0400
Received: from mail103-ch1 (localhost [127.0.0.1])	by
 mail103-ch1-R.bigfish.com (Postfix) with ESMTP id 9328F4C015D	for
 <netdev@vger.kernel.org>; Sat, 19 May 2012 09:40:04 +0000 (UTC)
Received: from CH1EHSMHS002.bigfish.com (snatpool2.int.messaging.microsoft.com
 [10.43.68.235])	by mail103-ch1.bigfish.com (Postfix) with ESMTP id
 A055A14006C	for <netdev@vger.kernel.org>; Sat, 19 May 2012 09:40:02 +0000
 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajan Gupta <rajan.gupta@freescale.com>

dst_gc_work is cancelled and again rescheduled in __ds_free(). In case
__dsf_free() is consistently called dst_gc_work will never get called resulting in
memory not getting freed at all until one stops calling __dst_free
Signed-off-by: Rajan Gupta <rajan.gupta@freescale.com>
---
 net/core/dst.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 8246d47..6820206 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -215,7 +215,6 @@ void __dst_free(struct dst_entry *dst)
 	if (dst_garbage.timer_inc > DST_GC_INC) {
 		dst_garbage.timer_inc = DST_GC_INC;
 		dst_garbage.timer_expires = DST_GC_MIN;
-		cancel_delayed_work(&dst_gc_work);
 		schedule_delayed_work(&dst_gc_work, dst_garbage.timer_expires);
 	}
 	spin_unlock_bh(&dst_garbage.lock);
-- 
1.7.9.5
