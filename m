From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3] ipv4: Kill spurious opt->srr check in
 ip_options_rcv_srr().
Date: Thu, 12 May 2011 19:38:38 -0400 (EDT)
Message-ID: <20110512.193838.1441331188443095419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757882Ab1ELXil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 19:38:41 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4CNcc6p008023
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 12 May 2011 16:38:39 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All call sites conditionalize the call to ip_options_rcv_srr()
with a check of opt->srr, so no need to check it again there.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_options.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 01fc409..e82c304 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -601,7 +601,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	unsigned long orefdst;
 	int err;
 
-	if (!opt->srr || !rt)
+	if (!rt)
 		return 0;
 
 	if (skb->pkt_type != PACKET_HOST)
-- 
1.7.4.4

