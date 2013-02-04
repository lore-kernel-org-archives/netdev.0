From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next] ipcomp: Mark as netns_ok.
Date: Mon, 04 Feb 2013 15:48:12 -0500 (EST)
Message-ID: <20130204.154812.1991513835460386879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001Ab3BDUsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 15:48:16 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 9890F585AF5
	for <netdev@vger.kernel.org>; Mon,  4 Feb 2013 12:48:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This module is namespace aware, netns_ok was just disabled by default
for sanity.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

l2tp is the only net_protocol not marked as namespace aware, and
there are patches coming for that.  After that's taken care of
we can demand that any protocol that gets registers in ipv4 be
netns_ok, and therefore we can eliminate the "init_net only"
checks in various locations, such as IP local deliver.

 net/ipv4/ipcomp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 9a46dae..f01d1b1 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -163,6 +163,7 @@ static const struct net_protocol ipcomp4_protocol = {
 	.handler	=	xfrm4_rcv,
 	.err_handler	=	ipcomp4_err,
 	.no_policy	=	1,
+	.netns_ok	=	1,
 };
 
 static int __init ipcomp4_init(void)
-- 
1.7.11.7
