From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 01/10] bnxt_en: Use RSS flags defined in the bnxt_hsi.h file.
Date: Tue, 20 Sep 2016 02:50:19 -0400
Message-ID: <1474354228-3221-2-git-send-email-michael.chan@broadcom.com>
References: <1474354228-3221-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36377 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752504AbcITGui (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 02:50:38 -0400
Received: by mail-pf0-f181.google.com with SMTP id q2so4060882pfj.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 23:50:37 -0700 (PDT)
In-Reply-To: <1474354228-3221-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And remove redundant definitions of the same flags.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 8 ++++----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 5 -----
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 228c964..cee0e8d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3419,10 +3419,10 @@ static int bnxt_hwrm_vnic_set_rss(struct bnxt *bp, u16 vnic_id, bool set_rss)
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_VNIC_RSS_CFG, -1, -1);
 	if (set_rss) {
-		vnic->hash_type = BNXT_RSS_HASH_TYPE_FLAG_IPV4 |
-				 BNXT_RSS_HASH_TYPE_FLAG_TCP_IPV4 |
-				 BNXT_RSS_HASH_TYPE_FLAG_IPV6 |
-				 BNXT_RSS_HASH_TYPE_FLAG_TCP_IPV6;
+		vnic->hash_type = VNIC_RSS_CFG_REQ_HASH_TYPE_IPV4 |
+				  VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV4 |
+				  VNIC_RSS_CFG_REQ_HASH_TYPE_IPV6 |
+				  VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV6;
 
 		req.hash_type = cpu_to_le32(vnic->hash_type);
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 23e04a6..db4814e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -389,11 +389,6 @@ struct rx_tpa_end_cmp_ext {
 
 #define INVALID_HW_RING_ID	((u16)-1)
 
-#define BNXT_RSS_HASH_TYPE_FLAG_IPV4		0x01
-#define BNXT_RSS_HASH_TYPE_FLAG_TCP_IPV4	0x02
-#define BNXT_RSS_HASH_TYPE_FLAG_IPV6		0x04
-#define BNXT_RSS_HASH_TYPE_FLAG_TCP_IPV6	0x08
-
 /* The hardware supports certain page sizes.  Use the supported page sizes
  * to allocate the rings.
  */
-- 
1.8.3.1
