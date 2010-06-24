From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: u64_stats_sync improvements
Date: Thu, 24 Jun 2010 12:04:38 +0200
Message-ID: <1277373878.2816.177.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61310 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918Ab0FXKLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 06:11:39 -0400
Received: by wyi11 with SMTP id 11so1515494wyi.19
        for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 03:11:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Add a comment about interrupts:

6) If counter might be written by an interrupt, readers should block
interrupts.

- Fix a typo in sample of use.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/u64_stats_sync.h |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/u64_stats_sync.h b/include/linux/u64_stats_sync.h
index d050515..201d319 100644
--- a/include/linux/u64_stats_sync.h
+++ b/include/linux/u64_stats_sync.h
@@ -23,6 +23,10 @@
  *    pure reads. But if they have to fetch many values, it's better to not allow
  *    preemptions/interruptions to avoid many retries.
  *
+ * 6) If counter might be written by an interrupt, readers should block interrupts.
+ *    (On UP, there is no seqcount_t protection, a reader allowing interrupts could
+ *     read partial values)
+ *
  * Usage :
  *
  * Stats producer (writer) should use following template granted it already got
@@ -46,7 +50,7 @@
  *         start = u64_stats_fetch_begin(&stats->syncp);
  *         tbytes = stats->bytes64; // non atomic operation
  *         tpackets = stats->packets64; // non atomic operation
- * } while (u64_stats_fetch_retry(&stats->lock, syncp));
+ * } while (u64_stats_fetch_retry(&stats->syncp, start));
  *
  *
  * Example of use in drivers/net/loopback.c, using per_cpu containers,


