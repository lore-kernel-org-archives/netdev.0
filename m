From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 04/11] rocker: mark rocker_tlv_put_* functions as noinline_if_stackbloat
Date: Wed, 14 Jun 2017 23:15:39 +0200
Message-ID: <20170614211556.2062728-5-arnd@arndb.de>
References: <20170614211556.2062728-1-arnd@arndb.de>
Cc: kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Arnd Bergmann <arnd@arndb.de>, Jiri Pirko <jiri@resnulli.us>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614211556.2062728-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Inlining these functions creates lots of stack variables when KASAN is
enabled, leading to this warning about potential stack overflow:

drivers/net/ethernet/rocker/rocker_ofdpa.c: In function 'ofdpa_cmd_flow_tbl_add':
drivers/net/ethernet/rocker/rocker_ofdpa.c:621:1: error: the frame size of 2752 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]

This marks all of them noinline_if_stackbloat, which solves the problem by
keeping the redzone inside of the separate stack frames.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/rocker/rocker_tlv.h | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_tlv.h b/drivers/net/ethernet/rocker/rocker_tlv.h
index a63ef82e7c72..8970a414eb5b 100644
--- a/drivers/net/ethernet/rocker/rocker_tlv.h
+++ b/drivers/net/ethernet/rocker/rocker_tlv.h
@@ -139,38 +139,38 @@ rocker_tlv_start(struct rocker_desc_info *desc_info)
 int rocker_tlv_put(struct rocker_desc_info *desc_info,
 		   int attrtype, int attrlen, const void *data);
 
-static inline int rocker_tlv_put_u8(struct rocker_desc_info *desc_info,
-				    int attrtype, u8 value)
+static noinline_if_stackbloat int
+rocker_tlv_put_u8(struct rocker_desc_info *desc_info, int attrtype, u8 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(u8), &value);
 }
 
-static inline int rocker_tlv_put_u16(struct rocker_desc_info *desc_info,
-				     int attrtype, u16 value)
+static noinline_if_stackbloat int
+rocker_tlv_put_u16(struct rocker_desc_info *desc_info, int attrtype, u16 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(u16), &value);
 }
 
-static inline int rocker_tlv_put_be16(struct rocker_desc_info *desc_info,
-				      int attrtype, __be16 value)
+static noinline_if_stackbloat int
+rocker_tlv_put_be16(struct rocker_desc_info *desc_info, int attrtype, __be16 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(__be16), &value);
 }
 
-static inline int rocker_tlv_put_u32(struct rocker_desc_info *desc_info,
-				     int attrtype, u32 value)
+static noinline_if_stackbloat int
+rocker_tlv_put_u32(struct rocker_desc_info *desc_info, int attrtype, u32 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(u32), &value);
 }
 
-static inline int rocker_tlv_put_be32(struct rocker_desc_info *desc_info,
-				      int attrtype, __be32 value)
+static noinline_if_stackbloat int
+rocker_tlv_put_be32(struct rocker_desc_info *desc_info, int attrtype, __be32 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(__be32), &value);
 }
 
-static inline int rocker_tlv_put_u64(struct rocker_desc_info *desc_info,
-				     int attrtype, u64 value)
+static noinline_if_stackbloat int
+rocker_tlv_put_u64(struct rocker_desc_info *desc_info, int attrtype, u64 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(u64), &value);
 }
-- 
2.9.0
