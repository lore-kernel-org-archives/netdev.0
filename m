From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next] openvswitch: Avoid useless holes in
	struct vport
Date: Mon, 3 Dec 2012 22:24:32 +0000
Message-ID: <20121203222432.GB14494@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
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


Having the 16bit port_no in between a set of pointers creates
an unwanted and useless hole in the struct.

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
---
 net/openvswitch/vport.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 3f7961e..aee7d43 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -68,10 +68,10 @@ struct vport_err_stats {
 /**
  * struct vport - one port within a datapath
  * @rcu: RCU callback head for deferred destruction.
- * @port_no: Index into @dp's @ports array.
  * @dp: Datapath to which this port belongs.
  * @upcall_portid: The Netlink port to use for packets received on this port that
  * miss the flow table.
+ * @port_no: Index into @dp's @ports array.
  * @hash_node: Element in @dev_table hash table in vport.c.
  * @dp_hash_node: Element in @datapath->ports hash table in datapath.c.
  * @ops: Class structure.
@@ -81,9 +81,9 @@ struct vport_err_stats {
  */
 struct vport {
 	struct rcu_head rcu;
-	u16 port_no;
 	struct datapath	*dp;
 	u32 upcall_portid;
+	u16 port_no;
 
 	struct hlist_node hash_node;
 	struct hlist_node dp_hash_node;
