From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 1/5] bridge: vlan: adjust rhashtable
	initial size and hash locks size
Date: Wed, 30 Sep 2015 20:16:51 +0200
Message-ID: <1443637015-4153-2-git-send-email-razor@blackwall.org>
References: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, vyasevich@gmail.com
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1443637015-4153-1-git-send-email-razor@blackwall.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

As Stephen pointed out the default initial size is more than we need, so
let's start small (4 elements, thus nelem_hint = 3). Also limit the hash
locks to the number of CPUs as we don't need any write-side scaling and
this looks like the minimum.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_vlan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index e227164bc3e1..283d012c3d89 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -19,6 +19,8 @@ static const struct rhashtable_params br_vlan_rht_params = {
 	.head_offset = offsetof(struct net_bridge_vlan, vnode),
 	.key_offset = offsetof(struct net_bridge_vlan, vid),
 	.key_len = sizeof(u16),
+	.nelem_hint = 3,
+	.locks_mul = 1,
 	.max_size = VLAN_N_VID,
 	.obj_cmpfn = br_vlan_cmp,
 	.automatic_shrinking = true,
-- 
2.4.3
