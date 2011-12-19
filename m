From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 07/14] mac802154: reduced mlme
	operations
Date: Mon, 19 Dec 2011 19:33:47 +0300
Message-ID: <1324312434-13151-7-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111219163117.GA13123@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111219163117.GA13123-AUGNqIMGY+bGcXpsla5Oef8+0UxHXcjY@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Initialize set of reduced operations.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/mac802154/Makefile    |    2 +-
 net/mac802154/mac802154.h |    2 ++
 net/mac802154/mac_cmd.c   |   43 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 46 insertions(+), 1 deletions(-)
 create mode 100644 net/mac802154/mac_cmd.c

diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
index 490beef..4d9dd0f 100644
--- a/net/mac802154/Makefile
+++ b/net/mac802154/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_MAC802154)	+= mac802154.o
-mac802154-objs		:= ieee802154_dev.o rx.o tx.o
+mac802154-objs		:= ieee802154_dev.o rx.o tx.o mac_cmd.o
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index cef6a4f..fc0aa75 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -85,6 +85,8 @@ struct mac802154_sub_if_data {
 
 #define MAC802154_MAX_XMIT_ATTEMPTS	3
 
+extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
+
 netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 							u8 page, u8 chan);
 
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
new file mode 100644
index 0000000..941c3e4
--- /dev/null
+++ b/net/mac802154/mac_cmd.c
@@ -0,0 +1,43 @@
+/*
+ * MAC commands interface
+ *
+ * Copyright 2007-2011 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/skbuff.h>
+#include <linux/if_arp.h>
+#include <net/ieee802154_netdev.h>
+#include <net/wpan-phy.h>
+#include <net/mac802154.h>
+
+#include "mac802154.h"
+
+struct wpan_phy *mac802154_get_phy(const struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return to_phy(get_device(&priv->hw->phy->dev));
+}
+
+struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced = {
+	.get_phy = mac802154_get_phy,
+};
-- 
1.7.2.3


------------------------------------------------------------------------------
Learn Windows Azure Live!  Tuesday, Dec 13, 2011
Microsoft is holding a special Learn Windows Azure training event for 
developers. It will provide a great way to learn Windows Azure and what it 
provides. You can attend the event by watching it streamed LIVE online.  
Learn more at http://p.sf.net/sfu/ms-windowsazure
