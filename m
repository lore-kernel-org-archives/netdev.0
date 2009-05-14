From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] syscall: Implement a convinience function restart_syscall
Date: Wed, 13 May 2009 19:55:10 -0700
Message-ID: <m1y6t0qtpt.fsf@fess.ebiederm.org>
References: <m13ab8s8cr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54673 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755224AbZENCzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 22:55:12 -0400
In-Reply-To: <m13ab8s8cr.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Wed\, 13 May 2009 19\:53\:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently when we have a signal pending we have the functionality
to restart that the current system call.  There are other cases
such as nasty lock ordering issues where it makes sense to have
a simple fix that uses try lock and restarts the system call.
Buying time to figure out how to rework the locking strategy.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 include/linux/sched.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index b4c38bc..d853f6b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2178,6 +2178,12 @@ static inline int test_tsk_need_resched(struct task_struct *tsk)
 	return unlikely(test_tsk_thread_flag(tsk,TIF_NEED_RESCHED));
 }
 
+static inline int restart_syscall(void)
+{
+	set_tsk_thread_flag(current, TIF_SIGPENDING);
+	return -ERESTARTNOINTR;
+}
+
 static inline int signal_pending(struct task_struct *p)
 {
 	return unlikely(test_tsk_thread_flag(p,TIF_SIGPENDING));
-- 
1.6.0.6

