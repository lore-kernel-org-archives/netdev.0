From: roy.qing.li@gmail.com
Subject: [PATCH 1/2] ipv6: fix mss when it is bigger than IPV6_MAXPLEN - sizeof(struct tcphdr)
Date: Tue, 28 Feb 2012 16:28:16 +0800
Message-ID: <1330417697-2637-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38095 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756364Ab2B1I21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 03:28:27 -0500
Received: by ghrr11 with SMTP id r11so137771ghr.19
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 00:28:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

When mss is bigger than IPV6_MAXPLEN - sizeof(struct tcphdr),
set mss to IPV6_MAXPLEN - sizeof(struct tcphdr), not IPV6_MAXPLEN.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv6/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 92be12b..42cc16c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1054,7 +1054,7 @@ static unsigned int ip6_default_advmss(const struct dst_entry *dst)
 	 * rely only on pmtu discovery"
 	 */
 	if (mtu > IPV6_MAXPLEN - sizeof(struct tcphdr))
-		mtu = IPV6_MAXPLEN;
+		mtu = IPV6_MAXPLEN - sizeof(struct tcphdr);
 	return mtu;
 }
 
-- 
1.7.1
