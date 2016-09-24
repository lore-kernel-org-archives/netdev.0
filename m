From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 2/2] brcmfmac: compile fws(ignal) code only with BCDC support enabled
Date: Sat, 24 Sep 2016 22:44:19 +0200
Message-ID: <20160924204419.10213-2-zajec5@gmail.com>
References: <20160924204419.10213-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Franky Lin <frankyl@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35426 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756783AbcIXUoj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 16:44:39 -0400
In-Reply-To: <20160924204419.10213-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

It's not needed by the other (msgbuf) protocol, so let's save some size
and compile it conditionally.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
 .../wireless/broadcom/brcm80211/brcmfmac/Makefile  |  4 +-
 .../broadcom/brcm80211/brcmfmac/fwsignal.h         | 59 ++++++++++++++++++++++
 2 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
index 9e4b505..ad3b06e 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
@@ -27,7 +27,6 @@ brcmfmac-objs += \
 		chip.o \
 		fwil.o \
 		fweh.o \
-		fwsignal.o \
 		p2p.o \
 		proto.o \
 		common.o \
@@ -37,7 +36,8 @@ brcmfmac-objs += \
 		btcoex.o \
 		vendor.o
 brcmfmac-$(CONFIG_BRCMFMAC_PROTO_BCDC) += \
-		bcdc.o
+		bcdc.o \
+		fwsignal.o
 brcmfmac-$(CONFIG_BRCMFMAC_PROTO_MSGBUF) += \
 		commonring.o \
 		flowring.o \
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.h
index 8f7c1d7..ba0c1bc 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.h
@@ -18,6 +18,7 @@
 #ifndef FWSIGNAL_H_
 #define FWSIGNAL_H_
 
+#ifdef CONFIG_BRCMFMAC_PROTO_BCDC
 int brcmf_fws_init(struct brcmf_pub *drvr);
 void brcmf_fws_deinit(struct brcmf_pub *drvr);
 bool brcmf_fws_skbs_queueing(struct brcmf_fws_info *fws);
@@ -31,5 +32,63 @@ void brcmf_fws_del_interface(struct brcmf_if *ifp);
 void brcmf_fws_bustxfail(struct brcmf_fws_info *fws, struct sk_buff *skb);
 void brcmf_fws_bus_blocked(struct brcmf_pub *drvr, bool flow_blocked);
 void brcmf_fws_rxreorder(struct brcmf_if *ifp, struct sk_buff *skb);
+#else
+static inline int brcmf_fws_init(struct brcmf_pub *drvr)
+{
+	return -ENOTSUPP;
+}
+
+static inline void brcmf_fws_deinit(struct brcmf_pub *drvr)
+{
+}
+
+static inline bool brcmf_fws_skbs_queueing(struct brcmf_fws_info *fws)
+{
+	return false;
+}
+
+static inline bool brcmf_fws_fc_active(struct brcmf_fws_info *fws)
+{
+	return false;
+}
+
+static inline void brcmf_fws_hdrpull(struct brcmf_if *ifp, s16 siglen,
+				     struct sk_buff *skb)
+{
+}
+
+static inline int brcmf_fws_process_skb(struct brcmf_if *ifp,
+					struct sk_buff *skb)
+{
+	return -ENOTSUPP;
+}
+
+static inline void brcmf_fws_reset_interface(struct brcmf_if *ifp)
+{
+}
+
+static inline void brcmf_fws_add_interface(struct brcmf_if *ifp)
+{
+}
+
+static inline void brcmf_fws_del_interface(struct brcmf_if *ifp)
+{
+}
+
+static inline void brcmf_fws_bustxfail(struct brcmf_fws_info *fws,
+				       struct sk_buff *skb)
+{
+}
+
+static inline void brcmf_fws_bus_blocked(struct brcmf_pub *drvr,
+					 bool flow_blocked)
+{
+}
+
+static inline void brcmf_fws_rxreorder(struct brcmf_if *ifp,
+				       struct sk_buff *skb)
+{
+}
+#endif
 
 #endif /* FWSIGNAL_H_ */
-- 
2.9.3
