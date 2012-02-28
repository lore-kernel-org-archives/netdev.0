From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 06/13] mac802154: slave interfaces
	definition
Date: Tue, 28 Feb 2012 18:00:25 +0300
Message-ID: <1330441232-17650-7-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1330441232-17650-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1330441232-17650-1-git-send-email-alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Slaves represent typical network interfaces available from userspace.
Each ieee802154 device/transceiver may have several slaves and able
to be associated with several networks at the same time. So this
patch adds structure for slaves definition.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/mac802154/mac802154.h |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 7606ba9..5ef4c8b 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -57,6 +57,31 @@ struct mac802154_priv {
 #define	MAC802154_DEVICE_STOPPED	0x00
 #define MAC802154_DEVICE_RUN		0x01
 
+/*
+ * Slave interface definition
+ */
+struct mac802154_sub_if_data {
+	struct list_head list; /* the ieee802154_priv->slaves list */
+
+	struct mac802154_priv *hw;
+	struct net_device *dev;
+
+	int type;
+
+	spinlock_t mib_lock;
+
+	__le16 pan_id;
+	__le16 short_addr;
+
+	u8 chan;
+	u8 page;
+
+	/* MAC BSN field */
+	u8 bsn;
+	/* MAC DSN field */
+	u8 dsn;
+};
+
 #define mac802154_to_priv(_hw)	container_of(_hw, struct mac802154_priv, hw)
 
 #define MAC802154_MAX_XMIT_ATTEMPTS	3
-- 
1.7.2.3


------------------------------------------------------------------------------
Keep Your Developer Skills Current with LearnDevNow!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-d2d
