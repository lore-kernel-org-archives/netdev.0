From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/6] net: bridge: break if __br_mdb_del fails
Date: Wed, 17 May 2017 17:27:06 -0400
Message-ID: <20170517212709.6473-4-vivien.didelot@savoirfairelinux.com>
References: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org (moderated list:ETHERNET BRIDGE)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Be symmetric with br_mdb_add and break if __br_mdb_del returns an error.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_mdb.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index d20a01622b20..24eeeefb4179 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -688,8 +688,9 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			entry->vid = v->vid;
 			err = __br_mdb_del(br, entry);
-			if (!err)
-				__br_mdb_notify(dev, p, entry, RTM_DELMDB);
+			if (err)
+				break;
+			__br_mdb_notify(dev, p, entry, RTM_DELMDB);
 		}
 	} else {
 		err = __br_mdb_del(br, entry);
-- 
2.13.0
