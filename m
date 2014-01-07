From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 17/17] ovs: make functions local
Date: Mon,  6 Jan 2014 16:16:16 -0800
Message-ID: <1389053776-62865-18-git-send-email-jesse@nicira.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1389053776-62865-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>

Several functions and datastructures could be local
Found with 'make namespacecheck'

Signed-off-by: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c | 4 ++--
 net/openvswitch/datapath.h | 2 --
 net/openvswitch/vport.c    | 6 +++++-
 net/openvswitch/vport.h    | 1 -
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 61ae3b8..df46928 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -132,7 +132,7 @@ static struct datapath *get_dp(struct net *net, int dp_ifindex)
 }
 
 /* Must be called with rcu_read_lock or ovs_mutex. */
-const char *ovs_dp_name(const struct datapath *dp)
+static const char *ovs_dp_name(const struct datapath *dp)
 {
 	struct vport *vport = ovs_vport_ovsl_rcu(dp, OVSP_LOCAL);
 	return vport->ops->get_name(vport);
@@ -1466,7 +1466,7 @@ struct genl_family dp_vport_genl_family = {
 	.parallel_ops = true,
 };
 
-struct genl_multicast_group ovs_dp_vport_multicast_group = {
+static struct genl_multicast_group ovs_dp_vport_multicast_group = {
 	.name = OVS_VPORT_MCGROUP
 };
 
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 62619a4..6be9fbb 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -182,14 +182,12 @@ static inline struct vport *ovs_vport_ovsl(const struct datapath *dp, int port_n
 
 extern struct notifier_block ovs_dp_device_notifier;
 extern struct genl_family dp_vport_genl_family;
-extern struct genl_multicast_group ovs_dp_vport_multicast_group;
 
 void ovs_dp_process_received_packet(struct vport *, struct sk_buff *);
 void ovs_dp_detach_port(struct vport *);
 int ovs_dp_upcall(struct datapath *, struct sk_buff *,
 		  const struct dp_upcall_info *);
 
-const char *ovs_dp_name(const struct datapath *dp);
 struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 pid, u32 seq,
 					 u8 cmd);
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index d830a95f..f28ff7e 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -33,6 +33,9 @@
 #include "vport.h"
 #include "vport-internal_dev.h"
 
+static void ovs_vport_record_error(struct vport *,
+				   enum vport_err_type err_type);
+
 /* List of statically compiled vport implementations.  Don't forget to also
  * add yours to the list at the bottom of vport.h. */
 static const struct vport_ops *vport_ops_list[] = {
@@ -396,7 +399,8 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
  * If using the vport generic stats layer indicate that an error of the given
  * type has occurred.
  */
-void ovs_vport_record_error(struct vport *vport, enum vport_err_type err_type)
+static void ovs_vport_record_error(struct vport *vport,
+				   enum vport_err_type err_type)
 {
 	spin_lock(&vport->stats_lock);
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 1a9fbce..92137dd 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -192,7 +192,6 @@ static inline struct vport *vport_from_priv(const void *priv)
 
 void ovs_vport_receive(struct vport *, struct sk_buff *,
 		       struct ovs_key_ipv4_tunnel *);
-void ovs_vport_record_error(struct vport *, enum vport_err_type err_type);
 
 /* List of statically compiled vport implementations.  Don't forget to also
  * add yours to the list at the top of vport.c. */
-- 
1.8.3.2
