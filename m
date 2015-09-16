From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 10/30] ipv4: Don't recompute net in ipmr_queue_xmit
Date: Tue, 15 Sep 2015 20:03:58 -0500
Message-ID: <1442365458-16349-10-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39233 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbbIPBLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:11:51 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling dev_net(dev) for is just silly.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ipmr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a0a5def920fc..075bc695ae34 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1745,7 +1745,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 		 * to blackhole.
 		 */
 
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_FRAGFAILS);
 		ip_rt_put(rt);
 		goto out_free;
 	}
-- 
2.2.1
