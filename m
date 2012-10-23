From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH net-next 14/15] mac802154: remove
	unnecessary spinlocks
Date: Tue, 23 Oct 2012 00:09:56 -0400
Message-ID: <1350965397-12384-15-git-send-email-tony.cheneau@amnesiak.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1350965397-12384-1-git-send-email-tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

These spinlock protects an int variable, that is always accessible in an
atomic fashion.

Signed-off-by: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
---
 net/mac802154/mib.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index f47781a..2339f8d 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -103,15 +103,10 @@ void mac802154_dev_set_short_addr(struct net_device *dev, u16 val)
 u16 mac802154_dev_get_short_addr(const struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
-	u16 ret;
 
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
-	spin_lock_bh(&priv->mib_lock);
-	ret = priv->short_addr;
-	spin_unlock_bh(&priv->mib_lock);
-
-	return ret;
+	return priv->short_addr;
 }
 
 void mac802154_dev_set_ieee_addr(struct net_device *dev)
@@ -131,15 +126,10 @@ void mac802154_dev_set_ieee_addr(struct net_device *dev)
 u16 mac802154_dev_get_pan_id(const struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
-	u16 ret;
 
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
-	spin_lock_bh(&priv->mib_lock);
-	ret = priv->pan_id;
-	spin_unlock_bh(&priv->mib_lock);
-
-	return ret;
+	return priv->pan_id;
 }
 
 void mac802154_dev_set_pan_id(struct net_device *dev, u16 val)
-- 
1.7.8.6


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_sfd2d_oct
