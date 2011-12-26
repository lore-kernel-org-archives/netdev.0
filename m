From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 06/14 v2] mac802154: slave interfaces definition
Date: Mon, 26 Dec 2011 20:07:32 +0300
Message-ID: <1324919252-14993-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48484 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832Ab1LZQIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 11:08:35 -0500
Received: by eekc4 with SMTP id c4so11132556eek.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 08:08:34 -0800 (PST)
In-Reply-To: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Slaves represent typical network interfaces available from userspace.
Each ieee802154 device/transceiver may have several slaves and able
to be associated with several networks at the same time.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/mac802154.h |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 09d15bc..15f0f62 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -59,6 +59,31 @@ enum {
 	MAC802154_DEVICE_RUN,
 };
 
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
