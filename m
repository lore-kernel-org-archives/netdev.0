From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH 2/3] sit: handle ICMPv4 for tunnels with no remote
Date: Sat,  6 Jun 2009 16:02:51 +0200
Message-ID: <1244296972-20748-2-git-send-email-contact@saschahlusiak.de>
References: <1244296972-20748-1-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:49401 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbZFFOA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2009 10:00:56 -0400
In-Reply-To: <1244296972-20748-1-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't drop ICMPv4 packages, if tunnel has no remote endpoint, like
6to4 or isatap tunnels.

Also don't drop it if tunnel inherits ttl and icmp_time_exceeded.
Don't really see the usecase here.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
---
 net/ipv6/sit.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index ba74094..89d8369 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -520,12 +520,10 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 				skb->dev,
 				iph->daddr,
 				iph->saddr);
-	if (t == NULL || t->parms.iph.daddr == 0)
+	if (t == NULL)
 		goto out;
 
 	err = 0;
-	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
-		goto out;
 
 	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
 		t->err_count++;
-- 
1.6.3.1

