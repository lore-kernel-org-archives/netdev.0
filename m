From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 1/7] openvswitch: Enable retrieval of TCP
	flags from IPv6 traffic.
Date: Fri, 20 Jul 2012 15:26:44 -0700
Message-ID: <1342823210-3308-2-git-send-email-jesse@nicira.com>
References: <1342823210-3308-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Mao <mmao-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1342823210-3308-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

We currently check that a packet is IPv4 and TCP before fetching the
TCP flags.  This enables fetching from IPv6 packets as well.

Reported-by: Michael Mao <mmao-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 2a11ec2..c6e1dae 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -182,7 +182,8 @@ void ovs_flow_used(struct sw_flow *flow, struct sk_buff *skb)
 {
 	u8 tcp_flags = 0;
 
-	if (flow->key.eth.type == htons(ETH_P_IP) &&
+	if ((flow->key.eth.type == htons(ETH_P_IP) ||
+	     flow->key.eth.type == htons(ETH_P_IPV6)) &&
 	    flow->key.ip.proto == IPPROTO_TCP &&
 	    likely(skb->len >= skb_transport_offset(skb) + sizeof(struct tcphdr))) {
 		u8 *tcp = (u8 *)tcp_hdr(skb);
-- 
1.7.9.5
