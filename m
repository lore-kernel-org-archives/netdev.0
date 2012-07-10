From: roy.qing.li@gmail.com
Subject: [PATCH] bridge: fix endian
Date: Tue, 10 Jul 2012 17:56:12 +0800
Message-ID: <1341914172-22075-1-git-send-email-roy.qing.li@gmail.com>
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:65418 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab2GJJ4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 05:56:21 -0400
Received: by qaas11 with SMTP id s11so10060qaa.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 02:56:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

mld->mld_maxdelay is net endian, so we should use ntohs, not htons

CC: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/bridge/br_multicast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index b665812..2d9a066 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1160,7 +1160,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 			goto out;
 		}
 		mld = (struct mld_msg *) icmp6_hdr(skb);
-		max_delay = msecs_to_jiffies(htons(mld->mld_maxdelay));
+		max_delay = msecs_to_jiffies(ntohs(mld->mld_maxdelay));
 		if (max_delay)
 			group = &mld->mld_mca;
 	} else if (skb->len >= sizeof(*mld2q)) {
-- 
1.7.1
