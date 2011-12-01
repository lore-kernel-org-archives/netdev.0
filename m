From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netem: fix build error on 32bit arches
Date: Thu, 01 Dec 2011 10:32:14 +0100
Message-ID: <1322731934.2335.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1322691627-20551-1-git-send-email-hagen@jauu.net>
	 <1322691627-20551-2-git-send-email-hagen@jauu.net>
	 <1322710225.2577.1.camel@edumazet-laptop>
	 <cfd2e2c26063da002d8afe76991ff0c1@localhost>
	 <1322730108.2335.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:55205 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795Ab1LAJcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 04:32:17 -0500
Received: by qyk7 with SMTP id 7so133981qyk.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 01:32:17 -0800 (PST)
In-Reply-To: <1322730108.2335.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ERROR: "__udivdi3" [net/sched/sch_netem.ko] undefined!

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_netem.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 9b7af9f..3bfd733 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -301,7 +301,10 @@ static psched_tdiff_t tabledist(psched_tdiff_t mu, psched_tdiff_t sigma,
 
 static psched_time_t packet_len_2_sched_time(unsigned int len, u32 rate)
 {
-	return PSCHED_NS2TICKS((u64)len * NSEC_PER_SEC / rate);
+	u64 ticks = (u64)len * NSEC_PER_SEC;
+
+	do_div(ticks, rate);
+	return PSCHED_NS2TICKS(ticks);
 }
 
 /*
