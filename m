From: Colin King <colin.king@canonical.com>
Subject: [PATCH] flow disector: check if arp_eth is null rather than arp
Date: Fri, 13 Jan 2017 13:34:28 +0000
Message-ID: <20170113133428.20130-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Simon Horman <simon.horman@netronome.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@ikuai8.com>, Amir Vadai <amir@vadai.me>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:54560 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751444AbdAMNfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 08:35:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

arp is being checked instead of arp_eth to see if the call to
__skb_header_pointer failed. Fix this by checking arp_eth is
null instead of arp.

CoverityScan CID#1396428 ("Logically dead code") on 2nd
arp comparison (which should be arp_eth instead).

Fixes: commit 55733350e5e8b70c5 ("flow disector: ARP support")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/core/flow_dissector.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index e3dffc7..fec48e9 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -409,7 +409,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 					       sizeof(_arp_eth), data,
 					       hlen - sizeof(_arp),
 					       &_arp_eth);
-		if (!arp)
+		if (!arp_eth)
 			goto out_bad;
 
 		if (dissector_uses_key(flow_dissector,
-- 
2.10.2
