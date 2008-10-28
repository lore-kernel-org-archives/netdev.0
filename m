From: Patrick McHardy <kaber@trash.net>
Subject: netlink: constify struct nlattr * arg to parsing functions
Date: Tue, 28 Oct 2008 16:33:32 +0100
Message-ID: <490730CC.2050800@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080009090103070109040500"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34291 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbYJ1Pde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 11:33:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080009090103070109040500
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------080009090103070109040500
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit cc823313faa0a950f1df7484fa38319a20cff2d0
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Oct 28 16:29:48 2008 +0100

    netlink: constify struct nlattr * arg to parsing functions
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 3643bbb..46b7764 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -233,7 +233,7 @@ extern int		nla_parse(struct nlattr *tb[], int maxtype,
 extern struct nlattr *	nla_find(struct nlattr *head, int len, int attrtype);
 extern size_t		nla_strlcpy(char *dst, const struct nlattr *nla,
 				    size_t dstsize);
-extern int		nla_memcpy(void *dest, struct nlattr *src, int count);
+extern int		nla_memcpy(void *dest, const struct nlattr *src, int count);
 extern int		nla_memcmp(const struct nlattr *nla, const void *data,
 				   size_t size);
 extern int		nla_strcmp(const struct nlattr *nla, const char *str);
@@ -741,7 +741,7 @@ static inline struct nlattr *nla_find_nested(struct nlattr *nla, int attrtype)
  * See nla_parse()
  */
 static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
-				   struct nlattr *nla,
+				   const struct nlattr *nla,
 				   const struct nla_policy *policy)
 {
 	return nla_parse(tb, maxtype, nla_data(nla), nla_len(nla), policy);
@@ -875,7 +875,7 @@ static inline int nla_put_msecs(struct sk_buff *skb, int attrtype,
  * nla_get_u32 - return payload of u32 attribute
  * @nla: u32 netlink attribute
  */
-static inline u32 nla_get_u32(struct nlattr *nla)
+static inline u32 nla_get_u32(const struct nlattr *nla)
 {
 	return *(u32 *) nla_data(nla);
 }
@@ -884,7 +884,7 @@ static inline u32 nla_get_u32(struct nlattr *nla)
  * nla_get_be32 - return payload of __be32 attribute
  * @nla: __be32 netlink attribute
  */
-static inline __be32 nla_get_be32(struct nlattr *nla)
+static inline __be32 nla_get_be32(const struct nlattr *nla)
 {
 	return *(__be32 *) nla_data(nla);
 }
@@ -893,7 +893,7 @@ static inline __be32 nla_get_be32(struct nlattr *nla)
  * nla_get_u16 - return payload of u16 attribute
  * @nla: u16 netlink attribute
  */
-static inline u16 nla_get_u16(struct nlattr *nla)
+static inline u16 nla_get_u16(const struct nlattr *nla)
 {
 	return *(u16 *) nla_data(nla);
 }
@@ -902,7 +902,7 @@ static inline u16 nla_get_u16(struct nlattr *nla)
  * nla_get_be16 - return payload of __be16 attribute
  * @nla: __be16 netlink attribute
  */
-static inline __be16 nla_get_be16(struct nlattr *nla)
+static inline __be16 nla_get_be16(const struct nlattr *nla)
 {
 	return *(__be16 *) nla_data(nla);
 }
@@ -911,7 +911,7 @@ static inline __be16 nla_get_be16(struct nlattr *nla)
  * nla_get_le16 - return payload of __le16 attribute
  * @nla: __le16 netlink attribute
  */
-static inline __le16 nla_get_le16(struct nlattr *nla)
+static inline __le16 nla_get_le16(const struct nlattr *nla)
 {
 	return *(__le16 *) nla_data(nla);
 }
@@ -920,7 +920,7 @@ static inline __le16 nla_get_le16(struct nlattr *nla)
  * nla_get_u8 - return payload of u8 attribute
  * @nla: u8 netlink attribute
  */
-static inline u8 nla_get_u8(struct nlattr *nla)
+static inline u8 nla_get_u8(const struct nlattr *nla)
 {
 	return *(u8 *) nla_data(nla);
 }
@@ -929,7 +929,7 @@ static inline u8 nla_get_u8(struct nlattr *nla)
  * nla_get_u64 - return payload of u64 attribute
  * @nla: u64 netlink attribute
  */
-static inline u64 nla_get_u64(struct nlattr *nla)
+static inline u64 nla_get_u64(const struct nlattr *nla)
 {
 	u64 tmp;
 
@@ -942,7 +942,7 @@ static inline u64 nla_get_u64(struct nlattr *nla)
  * nla_get_flag - return payload of flag attribute
  * @nla: flag netlink attribute
  */
-static inline int nla_get_flag(struct nlattr *nla)
+static inline int nla_get_flag(const struct nlattr *nla)
 {
 	return !!nla;
 }
@@ -953,7 +953,7 @@ static inline int nla_get_flag(struct nlattr *nla)
  *
  * Returns the number of milliseconds in jiffies.
  */
-static inline unsigned long nla_get_msecs(struct nlattr *nla)
+static inline unsigned long nla_get_msecs(const struct nlattr *nla)
 {
 	u64 msecs = nla_get_u64(nla);
 
diff --git a/net/netlink/attr.c b/net/netlink/attr.c
index 2d106cf..c83fea7 100644
--- a/net/netlink/attr.c
+++ b/net/netlink/attr.c
@@ -233,7 +233,7 @@ size_t nla_strlcpy(char *dst, const struct nlattr *nla, size_t dstsize)
  *
  * Returns the number of bytes copied.
  */
-int nla_memcpy(void *dest, struct nlattr *src, int count)
+int nla_memcpy(void *dest, const struct nlattr *src, int count)
 {
 	int minlen = min_t(int, count, nla_len(src));
 

--------------080009090103070109040500--
