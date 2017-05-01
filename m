From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 48/53] ipvs: change comparison on sync_refresh_period
Date: Mon,  1 May 2017 12:47:15 +0200
Message-ID: <1493635640-24325-49-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49648 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S379009AbdEAKtD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:49:03 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1BB3821058C
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0DA16FF137
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EAA90468
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:05 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>

The sync_refresh_period variable is unsigned, so it can never be < 0.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 30d6b2cc00a0..0e5b64a75da0 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -520,7 +520,7 @@ static int ip_vs_sync_conn_needed(struct netns_ipvs *ipvs,
 		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE) &&
 		    pkts % sync_period != sysctl_sync_threshold(ipvs))
 			return 0;
-	} else if (sync_refresh_period <= 0 &&
+	} else if (!sync_refresh_period &&
 		   pkts != sysctl_sync_threshold(ipvs))
 		return 0;
 
-- 
2.1.4
