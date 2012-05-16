From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v5 06/13] mac802154: slave interfaces declaration
Date: Wed, 16 May 2012 10:50:24 +0400
Message-ID: <1337151031-5178-7-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1337151031-5178-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:61076 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759372Ab2EPGvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 02:51:42 -0400
Received: by wibhm6 with SMTP id hm6so3146048wib.1
        for <netdev@vger.kernel.org>; Tue, 15 May 2012 23:51:40 -0700 (PDT)
In-Reply-To: <1337151031-5178-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Slaves represent typical network interfaces available from userspace.
Each ieee802154 device/transceiver may have several slaves and able
to be associated with several networks at the same time. So this
patch adds structure for slaves declaration.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/mac802154.h |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 4f2d975..d53b86c 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -58,6 +58,34 @@ struct mac802154_priv {
 #define	MAC802154_DEVICE_STOPPED	0x00
 #define MAC802154_DEVICE_RUN		0x01
 
+/* Slave interface definition.
+ *
+ * Slaves represent typical network interfaces available from userspace.
+ * Each ieee802154 device/transceiver may have several slaves and able
+ * to be associated with several networks at the same time.
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
