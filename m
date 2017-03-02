From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 05/26] netlink: mark nla_put_{u8,u16,u32} noinline_for_kasan
Date: Thu,  2 Mar 2017 17:38:13 +0100
Message-ID: <20170302163834.2273519-6-arnd@arndb.de>
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
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_KASAN is enabled, the "--param asan-stack=1" causes rather large
stack frames in some functions. This goes unnoticed normally because
CONFIG_FRAME_WARN is disabled with CONFIG_KASAN by default as of commit
3f181b4d8652 ("lib/Kconfig.debug: disable -Wframe-larger-than warnings with
KASAN=y").

The kernelci.org build bot however has the warning enabled and that led
me to investigate it a little further, as every build produces these warnings:

net/wireless/nl80211.c:4389:1: warning: the frame size of 2240 bytes is larger than 2048 bytes [-Wframe-larger-than=]
net/wireless/nl80211.c:1895:1: warning: the frame size of 3776 bytes is larger than 2048 bytes [-Wframe-larger-than=]
net/wireless/nl80211.c:1410:1: warning: the frame size of 2208 bytes is larger than 2048 bytes [-Wframe-larger-than=]
net/bridge/br_netlink.c:1282:1: warning: the frame size of 2544 bytes is larger than 2048 bytes [-Wframe-larger-than=]

With the new noinline_for_kasan annotation, we can avoid the problem
when KASAN is enabled but not change anything otherwise.

Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/net/netlink.h | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index b239fcd33d80..d84878d8347f 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -755,7 +755,7 @@ static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
+static noinline_for_kasan int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
 {
 	return nla_put(skb, attrtype, sizeof(u8), &value);
 }
@@ -766,7 +766,7 @@ static inline int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
+static noinline_for_kasan int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
 {
 	return nla_put(skb, attrtype, sizeof(u16), &value);
 }
@@ -777,7 +777,7 @@ static inline int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
+static noinline_for_kasan int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
 {
 	return nla_put(skb, attrtype, sizeof(__be16), &value);
 }
@@ -788,7 +788,7 @@ static inline int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
+static noinline_for_kasan int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
 {
 	return nla_put_be16(skb, attrtype | NLA_F_NET_BYTEORDER, value);
 }
@@ -799,7 +799,7 @@ static inline int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
+static noinline_for_kasan int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
 {
 	return nla_put(skb, attrtype, sizeof(__le16), &value);
 }
@@ -810,7 +810,7 @@ static inline int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
+static noinline_for_kasan int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
 {
 	return nla_put(skb, attrtype, sizeof(u32), &value);
 }
@@ -821,7 +821,7 @@ static inline int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
+static noinline_for_kasan int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
 {
 	return nla_put(skb, attrtype, sizeof(__be32), &value);
 }
@@ -832,7 +832,7 @@ static inline int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
+static noinline_for_kasan int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
 {
 	return nla_put_be32(skb, attrtype | NLA_F_NET_BYTEORDER, value);
 }
@@ -843,7 +843,7 @@ static inline int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_le32(struct sk_buff *skb, int attrtype, __le32 value)
+static noinline_for_kasan int nla_put_le32(struct sk_buff *skb, int attrtype, __le32 value)
 {
 	return nla_put(skb, attrtype, sizeof(__le32), &value);
 }
@@ -855,7 +855,7 @@ static inline int nla_put_le32(struct sk_buff *skb, int attrtype, __le32 value)
  * @value: numeric value
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_u64_64bit(struct sk_buff *skb, int attrtype,
+static noinline_for_kasan int nla_put_u64_64bit(struct sk_buff *skb, int attrtype,
 				    u64 value, int padattr)
 {
 	return nla_put_64bit(skb, attrtype, sizeof(u64), &value, padattr);
@@ -868,7 +868,7 @@ static inline int nla_put_u64_64bit(struct sk_buff *skb, int attrtype,
  * @value: numeric value
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value,
+static noinline_for_kasan int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value,
 			       int padattr)
 {
 	return nla_put_64bit(skb, attrtype, sizeof(__be64), &value, padattr);
@@ -881,7 +881,7 @@ static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value,
  * @value: numeric value
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value,
+static noinline_for_kasan int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value,
 				int padattr)
 {
 	return nla_put_be64(skb, attrtype | NLA_F_NET_BYTEORDER, value,
@@ -895,7 +895,7 @@ static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value,
  * @value: numeric value
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value,
+static noinline_for_kasan int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value,
 			       int padattr)
 {
 	return nla_put_64bit(skb, attrtype, sizeof(__le64), &value, padattr);
@@ -907,7 +907,7 @@ static inline int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value,
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_s8(struct sk_buff *skb, int attrtype, s8 value)
+static noinline_for_kasan int nla_put_s8(struct sk_buff *skb, int attrtype, s8 value)
 {
 	return nla_put(skb, attrtype, sizeof(s8), &value);
 }
@@ -918,7 +918,7 @@ static inline int nla_put_s8(struct sk_buff *skb, int attrtype, s8 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_s16(struct sk_buff *skb, int attrtype, s16 value)
+static noinline_for_kasan int nla_put_s16(struct sk_buff *skb, int attrtype, s16 value)
 {
 	return nla_put(skb, attrtype, sizeof(s16), &value);
 }
@@ -929,7 +929,7 @@ static inline int nla_put_s16(struct sk_buff *skb, int attrtype, s16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_s32(struct sk_buff *skb, int attrtype, s32 value)
+static noinline_for_kasan int nla_put_s32(struct sk_buff *skb, int attrtype, s32 value)
 {
 	return nla_put(skb, attrtype, sizeof(s32), &value);
 }
@@ -941,7 +941,7 @@ static inline int nla_put_s32(struct sk_buff *skb, int attrtype, s32 value)
  * @value: numeric value
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_s64(struct sk_buff *skb, int attrtype, s64 value,
+static noinline_for_kasan int nla_put_s64(struct sk_buff *skb, int attrtype, s64 value,
 			      int padattr)
 {
 	return nla_put_64bit(skb, attrtype, sizeof(s64), &value, padattr);
@@ -976,7 +976,7 @@ static inline int nla_put_flag(struct sk_buff *skb, int attrtype)
  * @njiffies: number of jiffies to convert to msecs
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_msecs(struct sk_buff *skb, int attrtype,
+static noinline_for_kasan int nla_put_msecs(struct sk_buff *skb, int attrtype,
 				unsigned long njiffies, int padattr)
 {
 	u64 tmp = jiffies_to_msecs(njiffies);
-- 
2.9.0
