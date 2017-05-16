From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/2] net: dsa: Sort DSA tagging protocol drivers
Date: Tue, 16 May 2017 22:40:07 +0200
Message-ID: <1494967208-11550-2-git-send-email-andrew@lunn.ch>
References: <1494967208-11550-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60847 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751775AbdEPUly (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 16:41:54 -0400
In-Reply-To: <1494967208-11550-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With more tag protocols being added, regain some order by sorting the
entries in various places.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 include/net/dsa.h  |  8 ++++----
 net/dsa/Kconfig    |  8 ++++----
 net/dsa/Makefile   |  6 +++---
 net/dsa/dsa.c      | 18 +++++++++---------
 net/dsa/dsa_priv.h | 18 +++++++++---------
 5 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 8e24677b1c62..f5b3ab645624 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -27,13 +27,13 @@ struct fixed_phy_status;
 
 enum dsa_tag_protocol {
 	DSA_TAG_PROTO_NONE = 0,
+	DSA_TAG_PROTO_BRCM,
 	DSA_TAG_PROTO_DSA,
-	DSA_TAG_PROTO_TRAILER,
 	DSA_TAG_PROTO_EDSA,
-	DSA_TAG_PROTO_BRCM,
-	DSA_TAG_PROTO_QCA,
-	DSA_TAG_PROTO_MTK,
 	DSA_TAG_PROTO_LAN9303,
+	DSA_TAG_PROTO_MTK,
+	DSA_TAG_PROTO_QCA,
+	DSA_TAG_PROTO_TRAILER,
 	DSA_TAG_LAST,		/* MUST BE LAST */
 };
 
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 81a0868edb1d..297389b2ab35 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -25,16 +25,16 @@ config NET_DSA_TAG_DSA
 config NET_DSA_TAG_EDSA
 	bool
 
-config NET_DSA_TAG_TRAILER
+config NET_DSA_TAG_LAN9303
 	bool
 
-config NET_DSA_TAG_QCA
+config NET_DSA_TAG_MTK
 	bool
 
-config NET_DSA_TAG_MTK
+config NET_DSA_TAG_TRAILER
 	bool
 
-config NET_DSA_TAG_LAN9303
+config NET_DSA_TAG_QCA
 	bool
 
 endif
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 0b747d75e65a..f8c0251d1f43 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -6,7 +6,7 @@ dsa_core-y += dsa.o slave.o dsa2.o switch.o legacy.o
 dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
 dsa_core-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
-dsa_core-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
-dsa_core-$(CONFIG_NET_DSA_TAG_QCA) += tag_qca.o
-dsa_core-$(CONFIG_NET_DSA_TAG_MTK) += tag_mtk.o
 dsa_core-$(CONFIG_NET_DSA_TAG_LAN9303) += tag_lan9303.o
+dsa_core-$(CONFIG_NET_DSA_TAG_MTK) += tag_mtk.o
+dsa_core-$(CONFIG_NET_DSA_TAG_QCA) += tag_qca.o
+dsa_core-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 26130ae438da..c0a1307c87dd 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -40,26 +40,26 @@ static const struct dsa_device_ops none_ops = {
 };
 
 const struct dsa_device_ops *dsa_device_ops[DSA_TAG_LAST] = {
+#ifdef CONFIG_NET_DSA_TAG_BRCM
+	[DSA_TAG_PROTO_BRCM] = &brcm_netdev_ops,
+#endif
 #ifdef CONFIG_NET_DSA_TAG_DSA
 	[DSA_TAG_PROTO_DSA] = &dsa_netdev_ops,
 #endif
 #ifdef CONFIG_NET_DSA_TAG_EDSA
 	[DSA_TAG_PROTO_EDSA] = &edsa_netdev_ops,
 #endif
-#ifdef CONFIG_NET_DSA_TAG_TRAILER
-	[DSA_TAG_PROTO_TRAILER] = &trailer_netdev_ops,
+#ifdef CONFIG_NET_DSA_TAG_LAN9303
+	[DSA_TAG_PROTO_LAN9303] = &lan9303_netdev_ops,
 #endif
-#ifdef CONFIG_NET_DSA_TAG_BRCM
-	[DSA_TAG_PROTO_BRCM] = &brcm_netdev_ops,
+#ifdef CONFIG_NET_DSA_TAG_MTK
+	[DSA_TAG_PROTO_MTK] = &mtk_netdev_ops,
 #endif
 #ifdef CONFIG_NET_DSA_TAG_QCA
 	[DSA_TAG_PROTO_QCA] = &qca_netdev_ops,
 #endif
-#ifdef CONFIG_NET_DSA_TAG_MTK
-	[DSA_TAG_PROTO_MTK] = &mtk_netdev_ops,
-#endif
-#ifdef CONFIG_NET_DSA_TAG_LAN9303
-	[DSA_TAG_PROTO_LAN9303] = &lan9303_netdev_ops,
+#ifdef CONFIG_NET_DSA_TAG_TRAILER
+	[DSA_TAG_PROTO_TRAILER] = &trailer_netdev_ops,
 #endif
 	[DSA_TAG_PROTO_NONE] = &none_ops,
 };
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index f4a88e485213..e9003b79cbbc 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -75,25 +75,25 @@ void dsa_slave_unregister_notifier(void);
 int dsa_switch_register_notifier(struct dsa_switch *ds);
 void dsa_switch_unregister_notifier(struct dsa_switch *ds);
 
+/* tag_brcm.c */
+extern const struct dsa_device_ops brcm_netdev_ops;
+
 /* tag_dsa.c */
 extern const struct dsa_device_ops dsa_netdev_ops;
 
 /* tag_edsa.c */
 extern const struct dsa_device_ops edsa_netdev_ops;
 
-/* tag_trailer.c */
-extern const struct dsa_device_ops trailer_netdev_ops;
+/* tag_lan9303.c */
+extern const struct dsa_device_ops lan9303_netdev_ops;
 
-/* tag_brcm.c */
-extern const struct dsa_device_ops brcm_netdev_ops;
+/* tag_mtk.c */
+extern const struct dsa_device_ops mtk_netdev_ops;
 
 /* tag_qca.c */
 extern const struct dsa_device_ops qca_netdev_ops;
 
-/* tag_mtk.c */
-extern const struct dsa_device_ops mtk_netdev_ops;
-
-/* tag_lan9303.c */
-extern const struct dsa_device_ops lan9303_netdev_ops;
+/* tag_trailer.c */
+extern const struct dsa_device_ops trailer_netdev_ops;
 
 #endif
-- 
2.11.0
