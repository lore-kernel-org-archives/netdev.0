From: greearb@candelatech.com
Subject: [PATCH] lockdep:  Print more info when MAX_LOCK_DEPTH is exceeded.
Date: Wed,  6 Feb 2013 10:52:42 -0800
Message-ID: <1360176762-4321-1-git-send-email-greearb@candelatech.com>
Cc: peterz@infradead.org, rostedt@goodmis.org, mingo@kernel.org,
	Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37701 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754094Ab3BFSxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 13:53:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This helps debug cases where a lock is acquired over and
over without being released.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 kernel/lockdep.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/kernel/lockdep.c b/kernel/lockdep.c
index 7981e5b..7e76b69 100644
--- a/kernel/lockdep.c
+++ b/kernel/lockdep.c
@@ -3189,8 +3189,12 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 		return 0;
 #endif
 	if (unlikely(curr->lockdep_depth >= MAX_LOCK_DEPTH)) {
+		debug_show_all_locks();
+		lockdep_print_held_locks(current);
+
 		debug_locks_off();
-		printk("BUG: MAX_LOCK_DEPTH too low!\n");
+		printk("BUG: MAX_LOCK_DEPTH too low, depth: %i  max: %lu!\n",
+		       curr->lockdep_depth, MAX_LOCK_DEPTH);
 		printk("turning off the locking correctness validator.\n");
 		dump_stack();
 		return 0;
-- 
1.7.3.4
