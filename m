From: <b15745@freescale.com>
Subject: [PATCH] net : fix for dst_gc_task not getting scheduled if __dst_free() is called consistently
Date: Sat, 19 May 2012 04:44:14 -0500
Message-ID: <1337420654-28200-1-git-send-email-b15745@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rajan Gupta <b15745@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:51239
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753077Ab2ESJoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 05:44:23 -0400
Received: from mail87-db3 (localhost [127.0.0.1])	by mail87-db3-R.bigfish.com
 (Postfix) with ESMTP id 9382A460293	for <netdev@vger.kernel.org>; Sat, 19 May
 2012 09:44:11 +0000 (UTC)
Received: from DB3EHSMHS002.bigfish.com (unknown [10.3.81.252])	by
 mail87-db3.bigfish.com (Postfix) with ESMTP id 936882004D	for
 <netdev@vger.kernel.org>; Sat, 19 May 2012 09:44:09 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajan Gupta <b15745@freescale.com>

dst_gc_work is cancelled and again rescheduled in __ds_free(). In case
__dsf_free() is consistently called dst_gc_work will never get called resulting in
memory not getting freed at all until one stops calling __dst_free
Signed-off-by: Rajan Gupta <b15745@freescale.com>
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
