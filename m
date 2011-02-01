From: Tom Herbert <therbert@google.com>
Subject: (unknown)
Date: Mon, 31 Jan 2011 16:21:43 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1101311618140.13796@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:24976 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab1BAAVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 19:21:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From b6943d0caff7db23aaed20ec7abb7848281e502a Mon Sep 17 00:00:00 2001
From: Tom Herbert <therbert@google.com>
Date: Mon, 31 Jan 2011 16:12:02 -0800
Subject: [PATCH] net: Check rps_flow_table when RPS map length is 1

In get_rps_cpu, add check that the rps_flow_table for the device is
NULL when trying to take fast path when RPS map length is one.
Without this, RFS is effectively disabled if map length is one which
is not correct.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ddd5df2..283ed85 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2666,7 +2666,8 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 
 	map = rcu_dereference(rxqueue->rps_map);
 	if (map) {
-		if (map->len == 1) {
+		if (map->len == 1 &&
+		    !rcu_dereference_raw(rxqueue->rps_flow_table)) {
 			tcpu = map->cpus[0];
 			if (cpu_online(tcpu))
 				cpu = tcpu;
-- 
1.7.3.1

