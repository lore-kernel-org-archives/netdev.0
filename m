From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 2/2] pkt_sched: Change PSCHED_SHIFT from 10 to 6
Date: Tue, 9 Jun 2009 08:05:13 +0000
Message-ID: <20090609080513.GB5237@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Martin Devera <devik@cdi.cz>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:33173 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356AbZFIIFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 04:05:16 -0400
Received: by mail-ew0-f210.google.com with SMTP id 6so4929033ewy.37
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2009 01:05:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change PSCHED_SHIFT from 10 to 6 to increase schedulers time
resolution. This will increase 16x a number of (internal) ticks per
nanosecond, and is needed to improve accuracy of schedulers based on
rate tables, like HTB, TBF or CBQ, with rates above 100Mbit. It is
assumed this change is safe for 32bit accounting of time diffs up
to 2 minutes, which should be enough for common use (extremely low
rate values may overflow, so get inaccurate instead). To make full
use of this change an updated iproute2 will be needed. (But using
older iproute2 should be safe too.)

This change breaks ticks - microseconds similarity, so some minor code
fixes might be needed. It is also planned to change naming adequately
eg. to PSCHED_TICKS2NS() etc. in the near future.

Reported-by: Antonio Almeida <vexwek@gmail.com>
Tested-by: Antonio Almeida <vexwek@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff -Nurp a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2009-06-08 23:06:31.000000000 +0200
+++ b/include/net/pkt_sched.h	2009-06-08 23:23:53.000000000 +0200
@@ -41,8 +41,8 @@ static inline void *qdisc_priv(struct Qd
 typedef u64	psched_time_t;
 typedef long	psched_tdiff_t;
 
-/* Avoid doing 64 bit divide by 1000 */
-#define PSCHED_SHIFT			10
+/* Avoid doing 64 bit divide */
+#define PSCHED_SHIFT			6
 #define PSCHED_US2NS(x)			((s64)(x) << PSCHED_SHIFT)
 #define PSCHED_NS2US(x)			((x) >> PSCHED_SHIFT)
 
