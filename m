From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 02/11] netlink: mark nla_put_{u8,u16,u32} noinline_if_stackbloat
Date: Wed, 14 Jun 2017 23:15:37 +0200
Message-ID: <20170614211556.2062728-3-arnd@arndb.de>
References: <20170614211556.2062728-1-arnd@arndb.de>
Cc: kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Alexey Dobriyan <adobriyan@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614211556.2062728-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
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

With the new noinline_if_stackbloat annotation, we can avoid the problem
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
index 01709172b3d3..24b4badd6eaf 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -766,7 +766,7 @@ static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
+static noinline_if_stackbloat int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
 {
 	return nla_put(skb, attrtype, sizeof(u8), &value);
 }
@@ -777,7 +777,7 @@ static inline int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
+static noinline_if_stackbloat int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
 {
 	return nla_put(skb, attrtype, sizeof(u16), &value);
 }
@@ -788,7 +788,7 @@ static inline int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
+static noinline_if_stackbloat int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
 {
 	return nla_put(skb, attrtype, sizeof(__be16), &value);
 }
@@ -799,7 +799,7 @@ static inline int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
+static noinline_if_stackbloat int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
 {
 	return nla_put_be16(skb, attrtype | NLA_F_NET_BYTEORDER, value);
 }
@@ -810,7 +810,7 @@ static inline int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
+static noinline_if_stackbloat int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
 {
 	return nla_put(skb, attrtype, sizeof(__le16), &value);
 }
@@ -821,7 +821,7 @@ static inline int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
+static noinline_if_stackbloat int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
 {
 	return nla_put(skb, attrtype, sizeof(u32), &value);
 }
@@ -832,7 +832,7 @@ static inline int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
+static noinline_if_stackbloat int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
 {
 	return nla_put(skb, attrtype, sizeof(__be32), &value);
 }
@@ -843,7 +843,7 @@ static inline int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
+static noinline_if_stackbloat int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
 {
 	return nla_put_be32(skb, attrtype | NLA_F_NET_BYTEORDER, value);
 }
@@ -854,7 +854,7 @@ static inline int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_le32(struct sk_buff *skb, int attrtype, __le32 value)
+static noinline_if_stackbloat int nla_put_le32(struct sk_buff *skb, int attrtype, __le32 value)
 {
 	return nla_put(skb, attrtype, sizeof(__le32), &value);
 }
@@ -866,7 +866,7 @@ static inline int nla_put_le32(struct sk_buff *skb, int attrtype, __le32 value)
  * @value: numeric value
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_u64_64bit(struct sk_buff *skb, int attrtype,
+static noinline_if_stackbloat int nla_put_u64_64bit(struct sk_buff *skb, int attrtype,
 				    u64 value, int padattr)
 {
 	return nla_put_64bit(skb, attrtype, sizeof(u64), &value, padattr);
@@ -879,7 +879,7 @@ static inline int nla_put_u64_64bit(struct sk_buff *skb, int attrtype,
  * @value: numeric value
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value,
+static noinline_if_stackbloat int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value,
 			       int padattr)
 {
 	return nla_put_64bit(skb, attrtype, sizeof(__be64), &value, padattr);
@@ -892,7 +892,7 @@ static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value,
  * @value: numeric value
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value,
+static noinline_if_stackbloat int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value,
 				int padattr)
 {
 	return nla_put_be64(skb, attrtype | NLA_F_NET_BYTEORDER, value,
@@ -906,7 +906,7 @@ static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value,
  * @value: numeric value
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value,
+static noinline_if_stackbloat int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value,
 			       int padattr)
 {
 	return nla_put_64bit(skb, attrtype, sizeof(__le64), &value, padattr);
@@ -918,7 +918,7 @@ static inline int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value,
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_s8(struct sk_buff *skb, int attrtype, s8 value)
+static noinline_if_stackbloat int nla_put_s8(struct sk_buff *skb, int attrtype, s8 value)
 {
 	return nla_put(skb, attrtype, sizeof(s8), &value);
 }
@@ -929,7 +929,7 @@ static inline int nla_put_s8(struct sk_buff *skb, int attrtype, s8 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_s16(struct sk_buff *skb, int attrtype, s16 value)
+static noinline_if_stackbloat int nla_put_s16(struct sk_buff *skb, int attrtype, s16 value)
 {
 	return nla_put(skb, attrtype, sizeof(s16), &value);
 }
@@ -940,7 +940,7 @@ static inline int nla_put_s16(struct sk_buff *skb, int attrtype, s16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_s32(struct sk_buff *skb, int attrtype, s32 value)
+static noinline_if_stackbloat int nla_put_s32(struct sk_buff *skb, int attrtype, s32 value)
 {
 	return nla_put(skb, attrtype, sizeof(s32), &value);
 }
@@ -952,7 +952,7 @@ static inline int nla_put_s32(struct sk_buff *skb, int attrtype, s32 value)
  * @value: numeric value
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_s64(struct sk_buff *skb, int attrtype, s64 value,
+static noinline_if_stackbloat int nla_put_s64(struct sk_buff *skb, int attrtype, s64 value,
 			      int padattr)
 {
 	return nla_put_64bit(skb, attrtype, sizeof(s64), &value, padattr);
@@ -987,7 +987,7 @@ static inline int nla_put_flag(struct sk_buff *skb, int attrtype)
  * @njiffies: number of jiffies to convert to msecs
  * @padattr: attribute type for the padding
  */
-static inline int nla_put_msecs(struct sk_buff *skb, int attrtype,
+static noinline_if_stackbloat int nla_put_msecs(struct sk_buff *skb, int attrtype,
 				unsigned long njiffies, int padattr)
 {
 	u64 tmp = jiffies_to_msecs(njiffies);
-- 
2.9.0
