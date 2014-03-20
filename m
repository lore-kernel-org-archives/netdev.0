From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 2/4] openvswitch: Read tcp flags only then the
	tranport header is present.
Date: Thu, 20 Mar 2014 11:09:12 -0700
Message-ID: <1395338954-26206-3-git-send-email-jesse@nicira.com>
References: <1395338954-26206-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1395338954-26206-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Only the first IP fragment can have a TCP header, check for this.

Signed-off-by: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 16f4b46..d71e60f 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -73,6 +73,7 @@ void ovs_flow_stats_update(struct sw_flow *flow, struct sk_buff *skb)
 
 	if ((flow->key.eth.type == htons(ETH_P_IP) ||
 	     flow->key.eth.type == htons(ETH_P_IPV6)) &&
+	    flow->key.ip.frag != OVS_FRAG_TYPE_LATER &&
 	    flow->key.ip.proto == IPPROTO_TCP &&
 	    likely(skb->len >= skb_transport_offset(skb) + sizeof(struct tcphdr))) {
 		tcp_flags = TCP_FLAGS_BE16(tcp_hdr(skb));
-- 
1.8.3.2
