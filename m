From: kbuild test robot <fengguang.wu@intel.com>
Subject: [RFC PATCH net-next] tipc: link_is_bc_sndlink() can be static
Date: Sat, 24 Oct 2015 22:56:01 +0800
Message-ID: <20151024145600.GA2937@lkp-hsx03>
References: <201510242238.2cwVlzRz%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: kbuild-internal@linux.intel.com, lkp@eclists.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:51714 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753124AbbJXO5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2015 10:57:08 -0400
Content-Disposition: inline
In-Reply-To: <201510242238.2cwVlzRz%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TO: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org
CC: Jon Maloy <jon.maloy@ericsson.com>
CC: Ying Xue <ying.xue@windriver.com>
CC: tipc-discussion@lists.sourceforge.net
CC: linux-kernel@vger.kernel.org


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 link.c |    8 ++++----
 node.c |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 4449fa0..9efbdbd 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -163,12 +163,12 @@ bool tipc_link_is_blocked(struct tipc_link *l)
 	return l->state & (LINK_RESETTING | LINK_PEER_RESET | LINK_FAILINGOVER);
 }
 
-bool link_is_bc_sndlink(struct tipc_link *l)
+static bool link_is_bc_sndlink(struct tipc_link *l)
 {
 	return !l->bc_sndlink;
 }
 
-bool link_is_bc_rcvlink(struct tipc_link *l)
+static bool link_is_bc_rcvlink(struct tipc_link *l)
 {
 	return ((l->bc_rcvlink == l) && !link_is_bc_sndlink(l));
 }
@@ -1364,8 +1364,8 @@ static bool tipc_link_build_bc_proto_msg(struct tipc_link *l, bool bcast,
  * Give a newly added peer node the sequence number where it should
  * start receiving and acking broadcast packets.
  */
-void tipc_link_build_bc_init_msg(struct tipc_link *l,
-				 struct sk_buff_head *xmitq)
+static void tipc_link_build_bc_init_msg(struct tipc_link *l,
+					struct sk_buff_head *xmitq)
 {
 	struct sk_buff_head list;
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 7493506..20cddec 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1083,7 +1083,7 @@ int tipc_node_xmit_skb(struct net *net, struct sk_buff *skb, u32 dnode,
  *
  * Invoked with no locks held.
  */
-void tipc_node_bc_rcv(struct net *net, struct sk_buff *skb, int bearer_id)
+static void tipc_node_bc_rcv(struct net *net, struct sk_buff *skb, int bearer_id)
 {
 	int rc;
 	struct sk_buff_head xmitq;
