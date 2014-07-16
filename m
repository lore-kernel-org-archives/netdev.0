From: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
Subject: [PATCH v8] net: openvswitch - set name assign type
Date: Thu, 17 Jul 2014 00:43:10 +0200
Message-ID: <1405550594-11786-3-git-send-email-teg@jklm.no>
References: <1405550594-11786-1-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1405550594-11786-1-git-send-email-teg-B22kvLQNl6c@public.gmane.org>
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

Signed-off-by: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
Cc: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
---

This patch goes on top of net-next.

 net/openvswitch/datapath.c           | 1 +
 net/openvswitch/vport-internal_dev.c | 2 +-
 net/openvswitch/vport.h              | 2 ++
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index fe95b6c..c1400c0 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1370,6 +1370,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	/* Set up our datapath device. */
 	parms.name = nla_data(a[OVS_DP_ATTR_NAME]);
+	parms.name_assign_type = NET_NAME_USER;
 	parms.type = OVS_VPORT_TYPE_INTERNAL;
 	parms.options = NULL;
 	parms.dp = dp;
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index bd65855..df185a7 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -165,7 +165,7 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
 	netdev_vport = netdev_vport_priv(vport);
 
 	netdev_vport->dev = alloc_netdev(sizeof(struct internal_dev),
-					 parms->name, NET_NAME_UNKNOWN,
+					 parms->name, parms->name_assign_type,
 					 do_setup);
 	if (!netdev_vport->dev) {
 		err = -ENOMEM;
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 8d721e6..a9d7480 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -97,6 +97,7 @@ struct vport {
  * struct vport_parms - parameters for creating a new vport
  *
  * @name: New vport's name.
+ * @name_assign_type: New vport's name's origin.
  * @type: New vport's type.
  * @options: %OVS_VPORT_ATTR_OPTIONS attribute from Netlink message, %NULL if
  * none was supplied.
@@ -105,6 +106,7 @@ struct vport {
  */
 struct vport_parms {
 	const char *name;
+	unsigned char name_assign_type;
 	enum ovs_vport_type type;
 	struct nlattr *options;
 
-- 
1.9.3
