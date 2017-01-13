From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] flow dissector: check if arp_eth is null rather than arp
Date: Fri, 13 Jan 2017 18:48:20 +0000
Message-ID: <20170113184820.823-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>,
        Gao Feng <fgao@ikuai8.com>, Amir Vadai <amir@vadai.me>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

arp is being checked instead of arp_eth to see if the call to
__skb_header_pointer failed. Fix this by checking arp_eth is
null instead of arp.   Also fix to use length hlen rather than
hlen - sizeof(_arp); thanks to Eric Dumazet for spotting
this latter issue.

CoverityScan CID#1396428 ("Logically dead code") on 2nd
arp comparison (which should be arp_eth instead).

Fixes: commit 55733350e5e8b70c5 ("flow disector: ARP support")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/core/flow_dissector.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index e3dffc7..c35aae1 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -407,9 +407,9 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 
 		arp_eth = __skb_header_pointer(skb, nhoff + sizeof(_arp),
 					       sizeof(_arp_eth), data,
-					       hlen - sizeof(_arp),
+					       hlen,
 					       &_arp_eth);
-		if (!arp)
+		if (!arp_eth)
 			goto out_bad;
 
 		if (dissector_uses_key(flow_dissector,
-- 
2.10.2
