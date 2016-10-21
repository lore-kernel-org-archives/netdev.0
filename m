From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/6] mlxsw: item: Make struct mlxsw_item args const
Date: Fri, 21 Oct 2016 16:07:18 +0200
Message-ID: <1477058843-9981-2-git-send-email-jiri@resnulli.us>
References: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35069 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755675AbcJUOH2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:07:28 -0400
Received: by mail-lf0-f67.google.com with SMTP id x79so5865268lff.2
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 07:07:27 -0700 (PDT)
In-Reply-To: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

These should be const, so enforce it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/item.h | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/item.h b/drivers/net/ethernet/mellanox/mlxsw/item.h
index a94dbda6..1c55a34 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/item.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/item.h
@@ -55,7 +55,7 @@ struct mlxsw_item {
 };
 
 static inline unsigned int
-__mlxsw_item_offset(struct mlxsw_item *item, unsigned short index,
+__mlxsw_item_offset(const struct mlxsw_item *item, unsigned short index,
 		    size_t typesize)
 {
 	BUG_ON(index && !item->step);
@@ -72,7 +72,7 @@ __mlxsw_item_offset(struct mlxsw_item *item, unsigned short index,
 		typesize);
 }
 
-static inline u16 __mlxsw_item_get16(char *buf, struct mlxsw_item *item,
+static inline u16 __mlxsw_item_get16(char *buf, const struct mlxsw_item *item,
 				     unsigned short index)
 {
 	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u16));
@@ -87,7 +87,7 @@ static inline u16 __mlxsw_item_get16(char *buf, struct mlxsw_item *item,
 	return tmp;
 }
 
-static inline void __mlxsw_item_set16(char *buf, struct mlxsw_item *item,
+static inline void __mlxsw_item_set16(char *buf, const struct mlxsw_item *item,
 				      unsigned short index, u16 val)
 {
 	unsigned int offset = __mlxsw_item_offset(item, index,
@@ -105,7 +105,7 @@ static inline void __mlxsw_item_set16(char *buf, struct mlxsw_item *item,
 	b[offset] = cpu_to_be16(tmp);
 }
 
-static inline u32 __mlxsw_item_get32(char *buf, struct mlxsw_item *item,
+static inline u32 __mlxsw_item_get32(char *buf, const struct mlxsw_item *item,
 				     unsigned short index)
 {
 	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u32));
@@ -120,7 +120,7 @@ static inline u32 __mlxsw_item_get32(char *buf, struct mlxsw_item *item,
 	return tmp;
 }
 
-static inline void __mlxsw_item_set32(char *buf, struct mlxsw_item *item,
+static inline void __mlxsw_item_set32(char *buf, const struct mlxsw_item *item,
 				      unsigned short index, u32 val)
 {
 	unsigned int offset = __mlxsw_item_offset(item, index,
@@ -138,7 +138,7 @@ static inline void __mlxsw_item_set32(char *buf, struct mlxsw_item *item,
 	b[offset] = cpu_to_be32(tmp);
 }
 
-static inline u64 __mlxsw_item_get64(char *buf, struct mlxsw_item *item,
+static inline u64 __mlxsw_item_get64(char *buf, const struct mlxsw_item *item,
 				     unsigned short index)
 {
 	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u64));
@@ -153,7 +153,7 @@ static inline u64 __mlxsw_item_get64(char *buf, struct mlxsw_item *item,
 	return tmp;
 }
 
-static inline void __mlxsw_item_set64(char *buf, struct mlxsw_item *item,
+static inline void __mlxsw_item_set64(char *buf, const struct mlxsw_item *item,
 				      unsigned short index, u64 val)
 {
 	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u64));
@@ -171,7 +171,7 @@ static inline void __mlxsw_item_set64(char *buf, struct mlxsw_item *item,
 }
 
 static inline void __mlxsw_item_memcpy_from(char *buf, char *dst,
-					    struct mlxsw_item *item,
+					    const struct mlxsw_item *item,
 					    unsigned short index)
 {
 	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(char));
@@ -180,7 +180,7 @@ static inline void __mlxsw_item_memcpy_from(char *buf, char *dst,
 }
 
 static inline void __mlxsw_item_memcpy_to(char *buf, const char *src,
-					  struct mlxsw_item *item,
+					  const struct mlxsw_item *item,
 					  unsigned short index)
 {
 	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(char));
@@ -189,7 +189,8 @@ static inline void __mlxsw_item_memcpy_to(char *buf, const char *src,
 }
 
 static inline u16
-__mlxsw_item_bit_array_offset(struct mlxsw_item *item, u16 index, u8 *shift)
+__mlxsw_item_bit_array_offset(const struct mlxsw_item *item,
+			      u16 index, u8 *shift)
 {
 	u16 max_index, be_index;
 	u16 offset;		/* byte offset inside the array */
@@ -212,7 +213,8 @@ __mlxsw_item_bit_array_offset(struct mlxsw_item *item, u16 index, u8 *shift)
 	return item->offset + offset;
 }
 
-static inline u8 __mlxsw_item_bit_array_get(char *buf, struct mlxsw_item *item,
+static inline u8 __mlxsw_item_bit_array_get(char *buf,
+					    const struct mlxsw_item *item,
 					    u16 index)
 {
 	u8 shift, tmp;
@@ -224,7 +226,8 @@ static inline u8 __mlxsw_item_bit_array_get(char *buf, struct mlxsw_item *item,
 	return tmp;
 }
 
-static inline void __mlxsw_item_bit_array_set(char *buf, struct mlxsw_item *item,
+static inline void __mlxsw_item_bit_array_set(char *buf,
+					      const struct mlxsw_item *item,
 					      u16 index, u8 val)
 {
 	u8 shift, tmp;
-- 
2.5.5
