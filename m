From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [PATCH net-next 1/3] bnxt_en: include bnxt_vfr.c code under CONFIG_BNXT_SRIOV switch
Date: Tue, 25 Jul 2017 06:49:31 -0400
Message-ID: <20170725104933.9633-1-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp02.broadcom.com ([192.19.232.149]:44495 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751647AbdGYKzd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 06:55:33 -0400
Received: from Sathya-S84.localdomain (unknown [10.192.238.84])
        by relay.smtp.broadcom.com (Postfix) with ESMTP id E8F9E1A0028
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 03:49:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes build error when CONFIG_BNXT_SRIOV is switched off:
>> drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c:165:16: error: 'struct
>> bnxt' has no member named 'sriov_lock'

Reported-by: kbuild test robot <lkp@intel.com>
Fixes: 4ab0c6a8ffd7 ("bnxt_en: add support to enable VF-representors")
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index 83478e9..86850ae 100644
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
+#endif /* CONFIG_BNXT_SRIOV */
-- 
1.8.3.1
