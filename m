From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 3/3] openvswitch: Fix FLOW_BUFSIZE definition.
Date: Tue,  4 Sep 2012 12:08:08 -0700
Message-ID: <1346785688-2910-4-git-send-email-jesse@nicira.com>
References: <1346785688-2910-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1346785688-2910-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

The vlan encapsulation fields in the maximum flow defintion were
never updated when the representation changed before upstreaming.
In theory this could cause a kernel panic when a maximum length
flow is used.  In practice this has never happened (to my knowledge)
because skb allocations are padded out to a cache line so you would
need the right combination of flow and packet being sent to userspace.

Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.h |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 9b75617..c30df1a 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -145,15 +145,17 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies);
  *  OVS_KEY_ATTR_PRIORITY      4    --     4      8
  *  OVS_KEY_ATTR_IN_PORT       4    --     4      8
  *  OVS_KEY_ATTR_ETHERNET     12    --     4     16
+ *  OVS_KEY_ATTR_ETHERTYPE     2     2     4      8  (outer VLAN ethertype)
  *  OVS_KEY_ATTR_8021Q         4    --     4      8
- *  OVS_KEY_ATTR_ETHERTYPE     2     2     4      8
+ *  OVS_KEY_ATTR_ENCAP         0    --     4      4  (VLAN encapsulation)
+ *  OVS_KEY_ATTR_ETHERTYPE     2     2     4      8  (inner VLAN ethertype)
  *  OVS_KEY_ATTR_IPV6         40    --     4     44
  *  OVS_KEY_ATTR_ICMPV6        2     2     4      8
  *  OVS_KEY_ATTR_ND           28    --     4     32
  *  -------------------------------------------------
- *  total                                       132
+ *  total                                       144
  */
-#define FLOW_BUFSIZE 132
+#define FLOW_BUFSIZE 144
 
 int ovs_flow_to_nlattrs(const struct sw_flow_key *, struct sk_buff *);
 int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
-- 
1.7.9.5
