From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 07/14 v2] mac802154: reduced mlme operations
Date: Mon, 26 Dec 2011 20:09:11 +0300
Message-ID: <1324919351-15076-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49177 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab1LZQKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 11:10:13 -0500
Received: by eekc4 with SMTP id c4so11133323eek.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 08:10:12 -0800 (PST)
In-Reply-To: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize set of reduced operations.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
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
index 15f0f62..43a02d2 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -88,6 +88,8 @@ struct mac802154_sub_if_data {
 
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
+ * Sergey Lapin <slapin@ossfans.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
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
