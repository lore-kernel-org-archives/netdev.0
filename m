From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next 07/13] dsa: implement ndo_swdev_get_id
Date: Wed,  3 Sep 2014 11:24:54 +0200
Message-ID: <1409736300-12303-8-git-send-email-jiri@resnulli.us>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1409736300-12303-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
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

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 include/linux/netdevice.h |  3 ++-
 include/net/dsa.h         |  1 +
 net/dsa/Kconfig           |  2 +-
 net/dsa/dsa.c             |  3 +++
 net/dsa/slave.c           | 10 ++++++++++
 5 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6a009d1..7ee070f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -41,7 +41,6 @@
 
 #include <linux/ethtool.h>
 #include <net/net_namespace.h>
-#include <net/dsa.h>
 #ifdef CONFIG_DCB
 #include <net/dcbnl.h>
 #endif
@@ -1259,6 +1258,8 @@ enum netdev_priv_flags {
 #define IFF_LIVE_ADDR_CHANGE		IFF_LIVE_ADDR_CHANGE
 #define IFF_MACVLAN			IFF_MACVLAN
 
+#include <net/dsa.h>
+
 /**
  *	struct net_device - The DEVICE structure.
  *		Actually, this whole structure is a big mistake.  It mixes I/O
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 9771292..d60cd42 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -140,6 +140,7 @@ struct dsa_switch {
 	u32			phys_mii_mask;
 	struct mii_bus		*slave_mii_bus;
 	struct net_device	*ports[DSA_MAX_PORTS];
+	struct netdev_phys_item_id psid;
 };
 
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index a585fd6..4e144a2 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -1,6 +1,6 @@
 config HAVE_NET_DSA
 	def_bool y
-	depends on NETDEVICES && !S390
+	depends on NETDEVICES && NET_SWITCHDEV && !S390
 
 # Drivers must select NET_DSA and the appropriate tagging format
 
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 61f145c..374912d 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -202,6 +202,9 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 		ds->ports[i] = slave_dev;
 	}
 
+	ds->psid.id_len = MAX_PHYS_ITEM_ID_LEN;
+	get_random_bytes(ds->psid.id, ds->psid.id_len);
+
 	return ds;
 
 out_free:
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7333a4a..d79a6c7 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -192,6 +192,15 @@ static netdev_tx_t dsa_slave_notag_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static int dsa_slave_swdev_get_id(struct net_device *dev,
+				  struct netdev_phys_item_id *psid)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	memcpy(psid, &ds->psid, sizeof(*psid));
+	return 0;
+}
 
 /* ethtool operations *******************************************************/
 static int
@@ -323,6 +332,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
+	.ndo_swdev_get_id	= dsa_slave_swdev_get_id,
 };
 
 static const struct dsa_device_ops notag_netdev_ops = {
-- 
1.9.3
