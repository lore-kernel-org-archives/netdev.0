From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/vxlan: Go over all candidate streams for GRO matching
Date: Wed, 29 Jan 2014 18:10:10 +0200
Message-ID: <1391011810-10682-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, therbert@google.com, edumazet@google.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60876 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751853AbaA2QKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jan 2014 11:10:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The loop in vxlan_gro_receive() over the current set of candidates for 
coalescing was wrongly aborted once a match was found. In rare cases,
this can cause a false-positives matching in the next layer GRO checks.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/vxlan.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 026a313..3d6cd1c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -596,10 +596,8 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
-		goto found;
 	}
 
-found:
 	type = eh->h_proto;
 
 	rcu_read_lock();
-- 
1.7.1
