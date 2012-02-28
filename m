From: roy.qing.li@gmail.com
Subject: [PATCH 2/2] ipv4: fix mss comparison
Date: Tue, 28 Feb 2012 16:28:17 +0800
Message-ID: <1330417697-2637-2-git-send-email-roy.qing.li@gmail.com>
References: <1330417697-2637-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45207 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756364Ab2B1I2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 03:28:36 -0500
Received: by yhmm54 with SMTP id m54so892149yhm.19
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 00:28:35 -0800 (PST)
In-Reply-To: <1330417697-2637-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

mss should compare with 65535 - sizeof(struct tcphdr),  
the largest mss is 65535 - sizeof(struct tcphdr).  
40 is sum of sizeof(struct tcphdr) and sizeof(struct iphdr)

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv4/route.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0489ced..c72f765 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1914,8 +1914,8 @@ static unsigned int ipv4_default_advmss(const struct dst_entry *dst)
 	if (advmss == 0) {
 		advmss = max_t(unsigned int, dst->dev->mtu - 40,
 			       ip_rt_min_advmss);
-		if (advmss > 65535 - 40)
-			advmss = 65535 - 40;
+		if (advmss > 65535 - sizeof(struct tcphdr))
+			advmss = 65535 - sizeof(struct tcphdr);
 	}
 	return advmss;
 }
-- 
1.7.1
