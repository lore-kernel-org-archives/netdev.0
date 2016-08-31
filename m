From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net] bridge: re-introduce 'fix parsing of MLDv2 reports'
Date: Wed, 31 Aug 2016 14:16:44 +0200
Message-ID: <00146cf9bbd373722167f61183d5d02a9d6c080e.1472644765.git.dcaratti@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Satish Ashok <sashok@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36726 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760313AbcHaMRr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 08:17:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit bc8c20acaea1 ("bridge: multicast: treat igmpv3 report with
INCLUDE and no sources as a leave") seems to have accidentally reverted
commit 47cc84ce0c2f ("bridge: fix parsing of MLDv2 reports"). This
commit brings back a change to br_ip6_multicast_mld2_report() where
parsing of MLDv2 reports stops when the first group is successfully
added to the MDB cache.

Fixes: bc8c20acaea1 ("bridge: multicast: treat igmpv3 report with INCLUDE and no sources as a leave")
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 net/bridge/br_multicast.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index a5423a1..c5fea93 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1138,7 +1138,7 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 		} else {
 			err = br_ip6_multicast_add_group(br, port,
 							 &grec->grec_mca, vid);
-			if (!err)
+			if (err)
 				break;
 		}
 	}
-- 
2.5.5
