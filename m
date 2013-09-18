From: Josselin Costanzi <josselin.costanzi@mobile-devices.fr>
Subject: [PATCH] net/lapb: re-send packets on timeout
Date: Wed, 18 Sep 2013 12:00:35 +0200
Message-ID: <1379498435-28860-1-git-send-email-josselin.costanzi@mobile-devices.fr>
Cc: Josselin Costanzi <josselin.costanzi@mobile-devices.fr>,
	Maxime Jayat <maxime.jayat@mobile-devices.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:42932 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab3IRKA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 06:00:57 -0400
Received: by mail-wg0-f44.google.com with SMTP id b13so6206299wgh.23
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 03:00:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually re-send packets when the T1 timer runs out. This fixes a bug
where packets are waiting on the write queue until disconnection when
no other traffic is outstanding.

Signed-off-by: Josselin Costanzi <josselin.costanzi@mobile-devices.fr>
Signed-off-by: Maxime Jayat <maxime.jayat@mobile-devices.fr>
---
 net/lapb/lapb_timer.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/lapb/lapb_timer.c b/net/lapb/lapb_timer.c
index 54563ad..355cc3b 100644
--- a/net/lapb/lapb_timer.c
+++ b/net/lapb/lapb_timer.c
@@ -154,6 +154,7 @@ static void lapb_t1timer_expiry(unsigned long param)
 			} else {
 				lapb->n2count++;
 				lapb_requeue_frames(lapb);
+				lapb_kick(lapb);
 			}
 			break;
 
-- 
1.7.5.4
