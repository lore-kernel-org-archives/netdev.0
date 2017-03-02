From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 06/26] rocker: mark rocker_tlv_put_* functions as noinline_for_kasan
Date: Thu,  2 Mar 2017 17:38:14 +0100
Message-ID: <20170302163834.2273519-7-arnd@arndb.de>
References: <20170302163834.2273519-1-arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: kasan-dev@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:64120 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753967AbdCBRLM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 12:11:12 -0500
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inlining these functions creates lots of stack variables when KASAN is
enabled, leading to this warning about potential stack overflow:

drivers/net/ethernet/rocker/rocker_ofdpa.c: In function 'ofdpa_cmd_flow_tbl_add':
drivers/net/ethernet/rocker/rocker_ofdpa.c:621:1: error: the frame size of 2752 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]

This marks all of them noinline_for_kasan, which solves the problem by
keeping the redzone inside of the separate stack frames.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/rocker/rocker_tlv.h | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_tlv.h b/drivers/net/ethernet/rocker/rocker_tlv.h
index a63ef82e7c72..3a9573fe0191 100644
--- a/drivers/net/ethernet/rocker/rocker_tlv.h
+++ b/drivers/net/ethernet/rocker/rocker_tlv.h
@@ -139,38 +139,38 @@ rocker_tlv_start(struct rocker_desc_info *desc_info)
 int rocker_tlv_put(struct rocker_desc_info *desc_info,
 		   int attrtype, int attrlen, const void *data);
 
-static inline int rocker_tlv_put_u8(struct rocker_desc_info *desc_info,
-				    int attrtype, u8 value)
+static noinline_for_kasan int
+rocker_tlv_put_u8(struct rocker_desc_info *desc_info, int attrtype, u8 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(u8), &value);
 }
 
-static inline int rocker_tlv_put_u16(struct rocker_desc_info *desc_info,
-				     int attrtype, u16 value)
+static noinline_for_kasan int
+rocker_tlv_put_u16(struct rocker_desc_info *desc_info, int attrtype, u16 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(u16), &value);
 }
 
-static inline int rocker_tlv_put_be16(struct rocker_desc_info *desc_info,
-				      int attrtype, __be16 value)
+static noinline_for_kasan int
+rocker_tlv_put_be16(struct rocker_desc_info *desc_info, int attrtype, __be16 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(__be16), &value);
 }
 
-static inline int rocker_tlv_put_u32(struct rocker_desc_info *desc_info,
-				     int attrtype, u32 value)
+static noinline_for_kasan int
+rocker_tlv_put_u32(struct rocker_desc_info *desc_info, int attrtype, u32 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(u32), &value);
 }
 
-static inline int rocker_tlv_put_be32(struct rocker_desc_info *desc_info,
-				      int attrtype, __be32 value)
+static noinline_for_kasan int
+rocker_tlv_put_be32(struct rocker_desc_info *desc_info, int attrtype, __be32 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(__be32), &value);
 }
 
-static inline int rocker_tlv_put_u64(struct rocker_desc_info *desc_info,
-				     int attrtype, u64 value)
+static noinline_for_kasan int
+rocker_tlv_put_u64(struct rocker_desc_info *desc_info, int attrtype, u64 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(u64), &value);
 }
-- 
2.9.0
