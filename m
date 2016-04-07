From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] lockdep: provide always true lockdep_is_held stub if lockdep disabled
Date: Fri,  8 Apr 2016 01:12:02 +0200
Message-ID: <1460070722-18652-1-git-send-email-hannes@stressinduktion.org>
Cc: netdev@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I need this to provide a generic lockdep_sock_is_held function which can
be easily used in the kernel without using ifdef PROVEN macros.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
Hello Peter and Ingo,

if it is possible coud this go in via the net-tree, as this problem is
visible there already? Would be happy to get a review.

Thanks,
Hannes

 include/linux/lockdep.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index d026b190c53066..dc8d447cb3ab1c 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -428,6 +428,8 @@ struct lock_class_key { };
 #define lockdep_pin_lock(l)				do { (void)(l); } while (0)
 #define lockdep_unpin_lock(l)			do { (void)(l); } while (0)
 
+#define lockdep_is_held(l)			({ (void)(l); (1); })
+
 #endif /* !LOCKDEP */
 
 #ifdef CONFIG_LOCK_STAT
-- 
2.5.5
