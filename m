From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pktgen: restore nanosec delays
Date: Sat, 03 Oct 2009 13:39:18 +0200
Message-ID: <4AC737E6.1050809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47910 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345AbZJCLjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2009 07:39:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit fd29cf72 (pktgen: convert to use ktime_t)
inadvertantly converted "delay" parameter from nanosec to microsec.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b694552..227ba31 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -964,7 +964,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (value == 0x7FFFFFFF)
 			pkt_dev->delay = ULLONG_MAX;
 		else
-			pkt_dev->delay = (u64)value * NSEC_PER_USEC;
+			pkt_dev->delay = (u64)value;
 
 		sprintf(pg_result, "OK: delay=%llu",
 			(unsigned long long) pkt_dev->delay);
