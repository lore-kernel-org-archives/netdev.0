From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] bridge: mdb: fix vlan_enabled access when
	vlans are not configured
Date: Tue,  4 Aug 2015 01:19:58 +0200
Message-ID: <1438643998-9259-1-git-send-email-razor@blackwall.org>
References: <201508040606.8x0wKgcJ%fengguang.wu@intel.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <201508040606.8x0wKgcJ%fengguang.wu@intel.com>
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

Instead of trying to access br->vlan_enabled directly use the provided
helper br_vlan_enabled().

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Sorry, forgot to change this before sending the patch.

 net/bridge/br_mdb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 1df3ef4a73b9..d747275fad18 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -490,7 +490,7 @@ static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EINVAL;
 
 	pv = nbp_get_vlan_info(p);
-	if (br->vlan_enabled && pv && entry->vid == 0) {
+	if (br_vlan_enabled(br) && pv && entry->vid == 0) {
 		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
 			entry->vid = vid;
 			err = __br_mdb_add(net, br, entry);
@@ -592,7 +592,7 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EINVAL;
 
 	pv = nbp_get_vlan_info(p);
-	if (br->vlan_enabled && pv && entry->vid == 0) {
+	if (br_vlan_enabled(br) && pv && entry->vid == 0) {
 		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
 			entry->vid = vid;
 			err = __br_mdb_del(br, entry);
-- 
2.4.3
