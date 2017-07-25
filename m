From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 1/3] bnxt_en: include bnxt_vfr.c code under CONFIG_BNXT_SRIOV switch
Date: Tue, 25 Jul 2017 13:28:39 -0400
Message-ID: <1501003721-12407-2-git-send-email-michael.chan@broadcom.com>
References: <1501003721-12407-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35834 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbdGYR25 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 13:28:57 -0400
Received: by mail-qk0-f181.google.com with SMTP id d145so66248223qkc.2
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 10:28:57 -0700 (PDT)
In-Reply-To: <1501003721-12407-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>

And define empty functions in bnxt_vfr.h when CONFIG_BNXT_SRIOV is not
defined.

This fixes build error when CONFIG_BNXT_SRIOV is switched off:
>> drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c:165:16: error: 'struct
>> bnxt' has no member named 'sriov_lock'

Reported-by: kbuild test robot <lkp@intel.com>
Fixes: 4ab0c6a8ffd7 ("bnxt_en: add support to enable VF-representors")
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c |  4 ++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h | 30 +++++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index 83478e9..a52e292 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -16,6 +16,8 @@
 #include "bnxt.h"
 #include "bnxt_vfr.h"
 
+#ifdef CONFIG_BNXT_SRIOV
+
 #define CFA_HANDLE_INVALID		0xffff
 #define VF_IDX_INVALID			0xffff
 
@@ -487,3 +489,5 @@ void bnxt_dl_unregister(struct bnxt *bp)
 	devlink_unregister(dl);
 	devlink_free(dl);
 }
+
+#endif
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
index c6cd55a..e55a3b6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
@@ -10,6 +10,8 @@
 #ifndef BNXT_VFR_H
 #define BNXT_VFR_H
 
+#ifdef CONFIG_BNXT_SRIOV
+
 #define	MAX_CFA_CODE			65536
 
 /* Struct to hold housekeeping info needed by devlink interface */
@@ -39,4 +41,32 @@ static inline void bnxt_link_bp_to_dl(struct devlink *dl, struct bnxt *bp)
 void bnxt_vf_rep_rx(struct bnxt *bp, struct sk_buff *skb);
 struct net_device *bnxt_get_vf_rep(struct bnxt *bp, u16 cfa_code);
 
+#else
+
+static inline int bnxt_dl_register(struct bnxt *bp)
+{
+	return 0;
+}
+
+static inline void bnxt_dl_unregister(struct bnxt *bp)
+{
+}
+
+static inline void bnxt_vf_reps_close(struct bnxt *bp)
+{
+}
+
+static inline void bnxt_vf_reps_open(struct bnxt *bp)
+{
+}
+
+static inline void bnxt_vf_rep_rx(struct bnxt *bp, struct sk_buff *skb)
+{
+}
+
+static inline struct net_device *bnxt_get_vf_rep(struct bnxt *bp, u16 cfa_code)
+{
+	return NULL;
+}
+#endif /* CONFIG_BNXT_SRIOV */
 #endif /* BNXT_VFR_H */
-- 
1.8.3.1
