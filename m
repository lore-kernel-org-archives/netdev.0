From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] Add a veth_get_peer() and veth_set_peer() functions
Date: Wed, 20 Jan 2010 07:01:12 -0800
Message-ID: <1263999673-11279-3-git-send-email-danms@us.ibm.com>
References: <1263999673-11279-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1263999673-11279-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is needed for C/R.  For checkpoint, we need to be able to follow
the link from one veth device to its peer.  For restart, we need to be
able to link two veth devices we've restored to re-establish their
relationship.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/veth.c   |   14 ++++++++++++++
 include/linux/veth.h |    5 +++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index ade5b34..eb47080 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -454,6 +454,20 @@ static void veth_dellink(struct net_device *dev)
 	unregister_netdevice(peer);
 }
 
+struct net_device *veth_get_peer(struct net_device *veth)
+{
+	struct veth_priv *priv = netdev_priv(veth);
+
+	return priv->peer;
+}
+
+void veth_set_peer(struct net_device *veth, struct net_device *peer)
+{
+	struct veth_priv *priv = netdev_priv(veth);
+
+	priv->peer = peer;
+}
+
 static const struct nla_policy veth_policy[VETH_INFO_MAX + 1];
 
 static struct rtnl_link_ops veth_link_ops = {
diff --git a/include/linux/veth.h b/include/linux/veth.h
index 3354c1e..eee059d 100644
--- a/include/linux/veth.h
+++ b/include/linux/veth.h
@@ -9,4 +9,9 @@ enum {
 #define VETH_INFO_MAX	(__VETH_INFO_MAX - 1)
 };
 
+#ifdef __KERNEL__
+struct net_device *veth_get_peer(struct net_device *veth);
+void veth_set_peer(struct net_device *veth, struct net_device *peer);
+#endif
+
 #endif
-- 
1.6.2.5
