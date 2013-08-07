From: Fan Du <fan.du@windriver.com>
Subject: [RFC PATCHv2 1/3] hrtimer: Add notifer for clock_was_set
Date: Wed, 7 Aug 2013 17:04:54 +0800
Message-ID: <1375866296-15079-2-git-send-email-fan.du@windriver.com>
References: <1375866296-15079-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45205 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757248Ab3HGJDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 05:03:18 -0400
In-Reply-To: <1375866296-15079-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When clock_was_set is called in case of system wall time change
or host resume from suspend state, use this notifier for places
where interested in this action.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 kernel/hrtimer.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
index 383319b..b7c62a9 100644
--- a/kernel/hrtimer.c
+++ b/kernel/hrtimer.c
@@ -755,6 +755,9 @@ static inline void retrigger_next_event(void *arg) { }
 
 #endif /* CONFIG_HIGH_RES_TIMERS */
 
+ATOMIC_NOTIFIER_HEAD(clock_change_notifier_list);
+EXPORT_SYMBOL(clock_change_notifier_list);
+
 /*
  * Clock realtime was set
  *
@@ -773,6 +776,7 @@ void clock_was_set(void)
 	on_each_cpu(retrigger_next_event, NULL, 1);
 #endif
 	timerfd_clock_was_set();
+	atomic_notifier_call_chain(&clock_change_notifier_list, 0, 0);
 }
 
 /*
-- 
1.7.9.5
