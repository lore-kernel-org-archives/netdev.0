From: Roopa Prabhu via Bridge <bridge@lists.linux-foundation.org>
Subject: [PATCH net-next] bridge: remove unnecessary check for
	vtbegin in br_fill_vlan_tinfo_range
Date: Tue,  7 Feb 2017 06:43:23 -0800
Message-ID: <1486478603-38776-1-git-send-email-roopa@cumulusnetworks.com>
Reply-To: Roopa Prabhu <roopa@cumulusnetworks.com>
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, dan.carpenter@oracle.com
To: davem@davemloft.net
Return-path: <bridge-bounces@lists.linux-foundation.org>
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

From: Roopa Prabhu <roopa@cumulusnetworks.com>

vtbegin should not be NULL in this function, Its already checked by the
caller.

this should silence the below smatch complaint:
  net/bridge/br_netlink_tunnel.c:144 br_fill_vlan_tinfo_range()
    error: we previously assumed 'vtbegin' could be null (see line 130)

net/bridge/br_netlink_tunnel.c
   129
   130      if (vtbegin && vtend && (vtend->vid - vtbegin->vid) > 0) {
                    ^^^^^^^
Check for NULL.

Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
Reported-By: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink_tunnel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_netlink_tunnel.c b/net/bridge/br_netlink_tunnel.c
index 99c6801..4c1303b 100644
--- a/net/bridge/br_netlink_tunnel.c
+++ b/net/bridge/br_netlink_tunnel.c
@@ -127,7 +127,7 @@ static int br_fill_vlan_tinfo_range(struct sk_buff *skb,
 {
 	int err;
 
-	if (vtbegin && vtend && (vtend->vid - vtbegin->vid) > 0) {
+	if (vtend && (vtend->vid - vtbegin->vid) > 0) {
 		/* add range to skb */
 		err = br_fill_vlan_tinfo(skb, vtbegin->vid,
 					 vtbegin->tinfo.tunnel_id,
-- 
1.7.10.4
