From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH 5/5] ipvs: Use schedule_timeout_interruptible() instead of msleep_interruptible()
Date: Sun, 29 Jun 2008 19:32:46 +0200
Message-ID: <1214760766-1526-6-git-send-email-sven.wegener@stealer.net>
References: <1214760766-1526-1-git-send-email-sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:55426 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755179AbYF2SEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 14:04:46 -0400
In-Reply-To: <1214760766-1526-1-git-send-email-sven.wegener@stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So that kthread_stop() can wake up the thread and we don't have to wait one
second in the worst case for the daemon to actually stop.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_sync.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index fa49c24..259e611 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -744,7 +744,7 @@ static int sync_thread_master(void *data)
 			ip_vs_sync_buff_release(sb);
 		}
 
-		msleep_interruptible(1000);
+		schedule_timeout_interruptible(HZ);
 	}
 
 	/* clean up the sync_buff queue */
-- 
1.5.6.1

