From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/13 net-3.1-stable] ipv4: fix for ip_options_rcv_srr()
 daddr update.
Date: Tue, 06 Dec 2011 16:33:10 -0500 (EST)
Message-ID: <20111206.163310.1649047298054361761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33951 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754429Ab1LFVdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:33:11 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6LXAah024121
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:33:11 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Li Wei <lw@cn.fujitsu.com>

[ Upstream commit b12f62efb8ec0b9523bdb6c2d412c07193086de9 ]

When opt->srr_is_hit is set skb_rtable(skb) has been updated for
'nexthop' and iph->daddr should always equals to skb_rtable->rt_dst
holds, We need update iph->daddr either.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_options.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index ec93335..05d20cc 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -640,6 +640,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	}
 	if (srrptr <= srrspace) {
 		opt->srr_is_hit = 1;
+		iph->daddr = nexthop;
 		opt->is_changed = 1;
 	}
 	return 0;
-- 
1.7.7.3
