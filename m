From: Shan Wei <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/9] net: openvswitch: use this_cpu_ptr per-cpu
	helper
Date: Wed, 31 Oct 2012 19:22:44 +0800
Message-ID: <50910A04.5000003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel-Maillist <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
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

From: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>

Signed-off-by: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>
---
 net/openvswitch/datapath.c |    4 ++--
 net/openvswitch/vport.c    |    5 ++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4c4b62c..77d16a5 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -208,7 +208,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	int error;
 	int key_len;
 
-	stats = per_cpu_ptr(dp->stats_percpu, smp_processor_id());
+	stats = this_cpu_ptr(dp->stats_percpu);
 
 	/* Extract flow from 'skb' into 'key'. */
 	error = ovs_flow_extract(skb, p->port_no, &key, &key_len);
@@ -282,7 +282,7 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 	return 0;
 
 err:
-	stats = per_cpu_ptr(dp->stats_percpu, smp_processor_id());
+	stats = this_cpu_ptr(dp->stats_percpu);
 
 	u64_stats_update_begin(&stats->sync);
 	stats->n_lost++;
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 03779e8..70af0be 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -333,8 +333,7 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb)
 {
 	struct vport_percpu_stats *stats;
 
-	stats = per_cpu_ptr(vport->percpu_stats, smp_processor_id());
-
+	stats = this_cpu_ptr(vport->percpu_stats);
 	u64_stats_update_begin(&stats->sync);
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
@@ -359,7 +358,7 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 	if (likely(sent)) {
 		struct vport_percpu_stats *stats;
 
-		stats = per_cpu_ptr(vport->percpu_stats, smp_processor_id());
+		stats = this_cpu_ptr(vport->percpu_stats);
 
 		u64_stats_update_begin(&stats->sync);
 		stats->tx_packets++;
-- 
1.7.1
