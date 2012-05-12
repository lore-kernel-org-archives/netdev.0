From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v4 06/13] mac802154: slave interfaces definition
Date: Sat, 12 May 2012 17:59:18 +0400
Message-ID: <1336831165-23944-7-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:47024 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756134Ab2ELOAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 10:00:18 -0400
Received: by mail-wi0-f172.google.com with SMTP id hj8so359000wib.1
        for <netdev@vger.kernel.org>; Sat, 12 May 2012 07:00:18 -0700 (PDT)
In-Reply-To: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Slaves represent typical network interfaces available from userspace.
Each ieee802154 device/transceiver may have several slaves and able
to be associated with several networks at the same time. So this
patch adds structure for slaves definition.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
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
