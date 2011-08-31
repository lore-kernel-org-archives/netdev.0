From: Rajan Aggarwal <rajan.aggarwal85@gmail.com>
Subject: [PATCH 1/1] net/can/af_can.c: Change del_timer to del_timer_sync
Date: Wed, 31 Aug 2011 15:27:38 +0530
Message-ID: <1314784658-23938-1-git-send-email-rajan.aggarwal85@gmail.com>
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:59724 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845Ab1HaJ6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 05:58:01 -0400
Received: by pzk37 with SMTP id 37so1068176pzk.1
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2011 02:58:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajan Aggarwal <Rajan Aggarwal rajan.aggarwal85@gmail.com>

This is important for SMP platform to check if timer function is
executing on other CPU with deleting the timer.

Signed-off-by: Rajan Aggarwal <Rajan Aggarwal rajan.aggarwal85@gmail.com>
---
 net/can/af_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 8ce926d..9b0c32a 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -857,7 +857,7 @@ static __exit void can_exit(void)
 	struct net_device *dev;
 
 	if (stats_timer)
-		del_timer(&can_stattimer);
+		del_timer_sync(&can_stattimer);
 
 	can_remove_proc();
 
-- 
1.7.4.1
