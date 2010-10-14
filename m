From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/8] tg3: Add clause 45 register accessor
 methods
Date: Thu, 14 Oct 2010 13:37:40 -0700
Message-ID: <1287088665-22135-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2074 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756016Ab0JNUiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 16:38:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds clause 45 register access methods.  They will be used in
the following patch.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/tg3.h |    4 ++++
 2 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1c680ff..afcc593 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1162,6 +1162,52 @@ static void tg3_mdio_fini(struct tg3 *tp)
 	}
 }
 
+static int tg3_phy_cl45_write(struct tg3 *tp, u32 devad, u32 addr, u32 val)
+{
+	int err;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_CTRL, devad);
+	if (err)
+		goto done;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_ADDRESS, addr);
+	if (err)
+		goto done;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_CTRL,
+			   MII_TG3_MMD_CTRL_DATA_NOINC | devad);
+	if (err)
+		goto done;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_ADDRESS, val);
+
+done:
+	return err;
+}
+
+static int tg3_phy_cl45_read(struct tg3 *tp, u32 devad, u32 addr, u32 *val)
+{
+	int err;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_CTRL, devad);
+	if (err)
+		goto done;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_ADDRESS, addr);
+	if (err)
+		goto done;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_CTRL,
+			   MII_TG3_MMD_CTRL_DATA_NOINC | devad);
+	if (err)
+		goto done;
+
+	err = tg3_readphy(tp, MII_TG3_MMD_ADDRESS, val);
+
+done:
+	return err;
+}
+
 /* tp->lock is held. */
 static inline void tg3_generate_fw_event(struct tg3 *tp)
 {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 89553c4..99fc306 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2061,6 +2061,10 @@
 #define  MII_TG3_CTRL_AS_MASTER		0x0800
 #define  MII_TG3_CTRL_ENABLE_AS_MASTER	0x1000
 
+#define MII_TG3_MMD_CTRL		0x0d /* MMD Access Control register */
+#define MII_TG3_MMD_CTRL_DATA_NOINC	0x4000
+#define MII_TG3_MMD_ADDRESS		0x0e /* MMD Address Data register */
+
 #define MII_TG3_EXT_CTRL		0x10 /* Extended control register */
 #define  MII_TG3_EXT_CTRL_FIFO_ELASTIC	0x0001
 #define  MII_TG3_EXT_CTRL_LNK3_LED_MODE	0x0002
-- 
1.7.2.2


