From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/19] mlxsw: item: Add helpers for getting pointer into payload for char buffer item
Date: Thu,  2 Feb 2017 16:12:42 +0100
Message-ID: <1486048379-19237-3-git-send-email-jiri@resnulli.us>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32827 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751634AbdBBPNE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 10:13:04 -0500
Received: by mail-wm0-f68.google.com with SMTP id v77so4675723wmv.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 07:13:04 -0800 (PST)
In-Reply-To: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Sometimes it is handy to get a pointer to a char buffer item and use it
direcly to write/read data. So add these helpers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/item.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/item.h b/drivers/net/ethernet/mellanox/mlxsw/item.h
index 09f35de..28427f0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/item.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/item.h
@@ -225,6 +225,14 @@ static inline void __mlxsw_item_memcpy_to(char *buf, const char *src,
 	memcpy(&buf[offset], src, item->size.bytes);
 }
 
+static inline char *__mlxsw_item_data(char *buf, const struct mlxsw_item *item,
+				      unsigned short index)
+{
+	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(char));
+
+	return &buf[offset];
+}
+
 static inline u16
 __mlxsw_item_bit_array_offset(const struct mlxsw_item *item,
 			      u16 index, u8 *shift)
@@ -468,6 +476,11 @@ mlxsw_##_type##_##_cname##_##_iname##_memcpy_to(char *buf, const char *src)	\
 {										\
 	__mlxsw_item_memcpy_to(buf, src,					\
 			       &__ITEM_NAME(_type, _cname, _iname), 0);		\
+}										\
+static inline char *								\
+mlxsw_##_type##_##_cname##_##_iname##_data(char *buf)				\
+{										\
+	return __mlxsw_item_data(buf, &__ITEM_NAME(_type, _cname, _iname), 0);	\
 }
 
 #define MLXSW_ITEM_BUF_INDEXED(_type, _cname, _iname, _offset, _sizebytes,	\
@@ -494,6 +507,12 @@ mlxsw_##_type##_##_cname##_##_iname##_memcpy_to(char *buf,			\
 {										\
 	__mlxsw_item_memcpy_to(buf, src,					\
 			       &__ITEM_NAME(_type, _cname, _iname), index);	\
+}										\
+static inline char *								\
+mlxsw_##_type##_##_cname##_##_iname##_data(char *buf, unsigned short index)	\
+{										\
+	return __mlxsw_item_data(buf,						\
+				 &__ITEM_NAME(_type, _cname, _iname), index);	\
 }
 
 #define MLXSW_ITEM_BIT_ARRAY(_type, _cname, _iname, _offset, _sizebytes,	\
-- 
2.7.4
