From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 02/10] openvswitch: Use nla_memcpy() to
	memcpy() data from attributes
Date: Tue, 16 Apr 2013 14:00:11 -0700
Message-ID: <1366146019-9015-3-git-send-email-jesse@nicira.com>
References: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1366146019-9015-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>

Less error prone as it takes into account the length of both the
destination buffer and the source attribute and documents when
data is copied from an attribute.

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |    2 +-
 net/openvswitch/flow.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 5b58d16..bca63c8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -672,7 +672,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err;
 	skb_reserve(packet, NET_IP_ALIGN);
 
-	memcpy(__skb_put(packet, len), nla_data(a[OVS_PACKET_ATTR_PACKET]), len);
+	nla_memcpy(__skb_put(packet, len), a[OVS_PACKET_ATTR_PACKET], len);
 
 	skb_reset_mac_header(packet);
 	eth = eth_hdr(packet);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 3324868..cf9328b 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -211,7 +211,7 @@ struct sw_flow_actions *ovs_flow_actions_alloc(const struct nlattr *actions)
 		return ERR_PTR(-ENOMEM);
 
 	sfa->actions_len = actions_len;
-	memcpy(sfa->actions, nla_data(actions), actions_len);
+	nla_memcpy(sfa->actions, actions, actions_len);
 	return sfa;
 }
 
-- 
1.7.10.4
