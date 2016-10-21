From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/6] mlxsw: item: Make char *buf arg constant for getters
Date: Fri, 21 Oct 2016 16:07:19 +0200
Message-ID: <1477058843-9981-3-git-send-email-jiri@resnulli.us>
References: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35865 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755662AbcJUOHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:07:30 -0400
Received: by mail-lf0-f65.google.com with SMTP id b75so6096698lfg.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 07:07:29 -0700 (PDT)
In-Reply-To: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Enforce const for getter buf args.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/item.h     | 31 ++++++++++++++------------
 drivers/net/ethernet/mellanox/mlxsw/pci.c      |  5 +++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  4 ++--
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  2 +-
 4 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/item.h b/drivers/net/ethernet/mellanox/mlxsw/item.h
index 1c55a34..3c95e3d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/item.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/item.h
@@ -72,7 +72,8 @@ __mlxsw_item_offset(const struct mlxsw_item *item, unsigned short index,
 		typesize);
 }
 
-static inline u16 __mlxsw_item_get16(char *buf, const struct mlxsw_item *item,
+static inline u16 __mlxsw_item_get16(const char *buf,
+				     const struct mlxsw_item *item,
 				     unsigned short index)
 {
 	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u16));
@@ -105,7 +106,8 @@ static inline void __mlxsw_item_set16(char *buf, const struct mlxsw_item *item,
 	b[offset] = cpu_to_be16(tmp);
 }
 
-static inline u32 __mlxsw_item_get32(char *buf, const struct mlxsw_item *item,
+static inline u32 __mlxsw_item_get32(const char *buf,
+				     const struct mlxsw_item *item,
 				     unsigned short index)
 {
 	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u32));
@@ -138,7 +140,8 @@ static inline void __mlxsw_item_set32(char *buf, const struct mlxsw_item *item,
 	b[offset] = cpu_to_be32(tmp);
 }
 
-static inline u64 __mlxsw_item_get64(char *buf, const struct mlxsw_item *item,
+static inline u64 __mlxsw_item_get64(const char *buf,
+				     const struct mlxsw_item *item,
 				     unsigned short index)
 {
 	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u64));
@@ -170,7 +173,7 @@ static inline void __mlxsw_item_set64(char *buf, const struct mlxsw_item *item,
 	b[offset] = cpu_to_be64(tmp);
 }
 
-static inline void __mlxsw_item_memcpy_from(char *buf, char *dst,
+static inline void __mlxsw_item_memcpy_from(const char *buf, char *dst,
 					    const struct mlxsw_item *item,
 					    unsigned short index)
 {
@@ -213,7 +216,7 @@ __mlxsw_item_bit_array_offset(const struct mlxsw_item *item,
 	return item->offset + offset;
 }
 
-static inline u8 __mlxsw_item_bit_array_get(char *buf,
+static inline u8 __mlxsw_item_bit_array_get(const char *buf,
 					    const struct mlxsw_item *item,
 					    u16 index)
 {
@@ -257,7 +260,7 @@ static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
 	.size = {.bits = _sizebits,},						\
 	.name = #_type "_" #_cname "_" #_iname,					\
 };										\
-static inline u16 mlxsw_##_type##_##_cname##_##_iname##_get(char *buf)		\
+static inline u16 mlxsw_##_type##_##_cname##_##_iname##_get(const char *buf)	\
 {										\
 	return __mlxsw_item_get16(buf, &__ITEM_NAME(_type, _cname, _iname), 0);	\
 }										\
@@ -278,7 +281,7 @@ static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
 	.name = #_type "_" #_cname "_" #_iname,					\
 };										\
 static inline u16								\
-mlxsw_##_type##_##_cname##_##_iname##_get(char *buf, unsigned short index)	\
+mlxsw_##_type##_##_cname##_##_iname##_get(const char *buf, unsigned short index)\
 {										\
 	return __mlxsw_item_get16(buf, &__ITEM_NAME(_type, _cname, _iname),	\
 				  index);					\
@@ -298,7 +301,7 @@ static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
 	.size = {.bits = _sizebits,},						\
 	.name = #_type "_" #_cname "_" #_iname,					\
 };										\
-static inline u32 mlxsw_##_type##_##_cname##_##_iname##_get(char *buf)		\
+static inline u32 mlxsw_##_type##_##_cname##_##_iname##_get(const char *buf)	\
 {										\
 	return __mlxsw_item_get32(buf, &__ITEM_NAME(_type, _cname, _iname), 0);	\
 }										\
@@ -319,7 +322,7 @@ static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
 	.name = #_type "_" #_cname "_" #_iname,					\
 };										\
 static inline u32								\
-mlxsw_##_type##_##_cname##_##_iname##_get(char *buf, unsigned short index)	\
+mlxsw_##_type##_##_cname##_##_iname##_get(const char *buf, unsigned short index)\
 {										\
 	return __mlxsw_item_get32(buf, &__ITEM_NAME(_type, _cname, _iname),	\
 				  index);					\
@@ -339,7 +342,7 @@ static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
 	.size = {.bits = _sizebits,},						\
 	.name = #_type "_" #_cname "_" #_iname,					\
 };										\
-static inline u64 mlxsw_##_type##_##_cname##_##_iname##_get(char *buf)		\
+static inline u64 mlxsw_##_type##_##_cname##_##_iname##_get(const char *buf)	\
 {										\
 	return __mlxsw_item_get64(buf, &__ITEM_NAME(_type, _cname, _iname), 0);	\
 }										\
@@ -360,7 +363,7 @@ static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
 	.name = #_type "_" #_cname "_" #_iname,					\
 };										\
 static inline u64								\
-mlxsw_##_type##_##_cname##_##_iname##_get(char *buf, unsigned short index)	\
+mlxsw_##_type##_##_cname##_##_iname##_get(const char *buf, unsigned short index)\
 {										\
 	return __mlxsw_item_get64(buf, &__ITEM_NAME(_type, _cname, _iname),	\
 				  index);					\
@@ -380,7 +383,7 @@ static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
 	.name = #_type "_" #_cname "_" #_iname,					\
 };										\
 static inline void								\
-mlxsw_##_type##_##_cname##_##_iname##_memcpy_from(char *buf, char *dst)		\
+mlxsw_##_type##_##_cname##_##_iname##_memcpy_from(const char *buf, char *dst)	\
 {										\
 	__mlxsw_item_memcpy_from(buf, dst,					\
 				 &__ITEM_NAME(_type, _cname, _iname), 0);	\
@@ -402,7 +405,7 @@ static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
 	.name = #_type "_" #_cname "_" #_iname,					\
 };										\
 static inline void								\
-mlxsw_##_type##_##_cname##_##_iname##_memcpy_from(char *buf,			\
+mlxsw_##_type##_##_cname##_##_iname##_memcpy_from(const char *buf,		\
 						  unsigned short index,		\
 						  char *dst)			\
 {										\
@@ -427,7 +430,7 @@ static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
 	.name = #_type "_" #_cname "_" #_iname,					\
 };										\
 static inline u8								\
-mlxsw_##_type##_##_cname##_##_iname##_get(char *buf, u16 index)			\
+mlxsw_##_type##_##_cname##_##_iname##_get(const char *buf, u16 index)		\
 {										\
 	return __mlxsw_item_bit_array_get(buf,					\
 					  &__ITEM_NAME(_type, _cname, _iname),	\
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index e742bd4..6f36806 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -238,8 +238,9 @@ static bool mlxsw_pci_elem_hw_owned(struct mlxsw_pci_queue *q, bool owner_bit)
 	return owner_bit != !!(q->consumer_counter & q->count);
 }
 
-static char *mlxsw_pci_queue_sw_elem_get(struct mlxsw_pci_queue *q,
-					 u32 (*get_elem_owner_func)(char *))
+static char *
+mlxsw_pci_queue_sw_elem_get(struct mlxsw_pci_queue *q,
+			    u32 (*get_elem_owner_func)(const char *))
 {
 	struct mlxsw_pci_queue_elem_info *elem_info;
 	char *elem;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6d8cb22..991a320 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1413,7 +1413,7 @@ static int mlxsw_sp_port_set_pauseparam(struct net_device *dev,
 
 struct mlxsw_sp_port_hw_stats {
 	char str[ETH_GSTRING_LEN];
-	u64 (*getter)(char *payload);
+	u64 (*getter)(const char *payload);
 };
 
 static struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_stats[] = {
@@ -1534,7 +1534,7 @@ static struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_prio_stats[] = {
 
 #define MLXSW_SP_PORT_HW_PRIO_STATS_LEN ARRAY_SIZE(mlxsw_sp_port_hw_prio_stats)
 
-static u64 mlxsw_reg_ppcnt_tc_transmit_queue_bytes_get(char *ppcnt_pl)
+static u64 mlxsw_reg_ppcnt_tc_transmit_queue_bytes_get(const char *ppcnt_pl)
 {
 	u64 transmit_queue = mlxsw_reg_ppcnt_tc_transmit_queue_get(ppcnt_pl);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 66af63d..963618d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -410,7 +410,7 @@ static void mlxsw_sx_port_get_drvinfo(struct net_device *dev,
 
 struct mlxsw_sx_port_hw_stats {
 	char str[ETH_GSTRING_LEN];
-	u64 (*getter)(char *payload);
+	u64 (*getter)(const char *payload);
 };
 
 static const struct mlxsw_sx_port_hw_stats mlxsw_sx_port_hw_stats[] = {
-- 
2.5.5
