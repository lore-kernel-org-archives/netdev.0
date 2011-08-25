From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next v2 06/10] headers, netfilter: Use kernel type names
 __u8, __u16, __u32
Date: Thu, 25 Aug 2011 05:44:57 +0100
Message-ID: <1314247497.27179.123.camel@deadeye>
References: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VdO05L2u4ehBeGid+yUt"
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1314247131.27179.116.camel@deadeye>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VdO05L2u4ehBeGid+yUt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

These types are guaranteed to be defined by <linux/types.h> for
both userland and kernel, unlike u_intN_t.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter_arp/arp_tables.h  |   14 +++++++-------
 include/linux/netfilter_ipv4/ip_tables.h  |   20 ++++++++++----------
 include/linux/netfilter_ipv6/ip6_tables.h |   22 +++++++++++-----------
 3 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfi=
lter_arp/arp_tables.h
index adbf4bf..e08565d 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -52,7 +52,7 @@ struct arpt_arp {
 	struct in_addr smsk, tmsk;
=20
 	/* Device hw address length, src+target device addresses */
-	u_int8_t arhln, arhln_mask;
+	__u8 arhln, arhln_mask;
 	struct arpt_devaddr_info src_devaddr;
 	struct arpt_devaddr_info tgt_devaddr;
=20
@@ -71,9 +71,9 @@ struct arpt_arp {
 	unsigned char iniface_mask[IFNAMSIZ], outiface_mask[IFNAMSIZ];
=20
 	/* Flags word */
-	u_int8_t flags;
+	__u8 flags;
 	/* Inverse flags */
-	u_int16_t invflags;
+	__u16 invflags;
 };
=20
 /* Values for "flag" field in struct arpt_ip (general arp structure).
@@ -102,9 +102,9 @@ struct arpt_entry
 	struct arpt_arp arp;
=20
 	/* Size of arpt_entry + matches */
-	u_int16_t target_offset;
+	__u16 target_offset;
 	/* Size of arpt_entry + matches + target */
-	u_int16_t next_offset;
+	__u16 next_offset;
=20
 	/* Back pointer */
 	unsigned int comefrom;
@@ -260,8 +260,8 @@ extern unsigned int arpt_do_table(struct sk_buff *skb,
=20
 struct compat_arpt_entry {
 	struct arpt_arp arp;
-	u_int16_t target_offset;
-	u_int16_t next_offset;
+	__u16 target_offset;
+	__u16 next_offset;
 	compat_uint_t comefrom;
 	struct compat_xt_counters counters;
 	unsigned char elems[0];
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfi=
lter_ipv4/ip_tables.h
index 64a5d95..db79231 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -81,12 +81,12 @@ struct ipt_ip {
 	unsigned char iniface_mask[IFNAMSIZ], outiface_mask[IFNAMSIZ];
=20
 	/* Protocol, 0 =3D ANY */
-	u_int16_t proto;
+	__u16 proto;
=20
 	/* Flags word */
-	u_int8_t flags;
+	__u8 flags;
 	/* Inverse flags */
-	u_int8_t invflags;
+	__u8 invflags;
 };
=20
 /* Values for "flag" field in struct ipt_ip (general ip structure). */
@@ -114,9 +114,9 @@ struct ipt_entry {
 	unsigned int nfcache;
=20
 	/* Size of ipt_entry + matches */
-	u_int16_t target_offset;
+	__u16 target_offset;
 	/* Size of ipt_entry + matches + target */
-	u_int16_t next_offset;
+	__u16 next_offset;
=20
 	/* Back pointer */
 	unsigned int comefrom;
@@ -149,9 +149,9 @@ struct ipt_entry {
=20
 /* ICMP matching stuff */
 struct ipt_icmp {
-	u_int8_t type;				/* type to match */
-	u_int8_t code[2];			/* range of code */
-	u_int8_t invflags;			/* Inverse flags */
+	__u8 type;				/* type to match */
+	__u8 code[2];				/* range of code */
+	__u8 invflags;				/* Inverse flags */
 };
=20
 /* Values for "inv" field for struct ipt_icmp. */
@@ -288,8 +288,8 @@ extern unsigned int ipt_do_table(struct sk_buff *skb,
 struct compat_ipt_entry {
 	struct ipt_ip ip;
 	compat_uint_t nfcache;
-	u_int16_t target_offset;
-	u_int16_t next_offset;
+	__u16 target_offset;
+	__u16 next_offset;
 	compat_uint_t comefrom;
 	struct compat_xt_counters counters;
 	unsigned char elems[0];
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netf=
ilter_ipv6/ip6_tables.h
index c9784f7..f549adc 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -81,14 +81,14 @@ struct ip6t_ip6 {
 	 *   MH do not match any packets.
 	 * - You also need to set IP6T_FLAGS_PROTO to "flags" to check protocol.
 	 */
-	u_int16_t proto;
+	__u16 proto;
 	/* TOS to match iff flags & IP6T_F_TOS */
-	u_int8_t tos;
+	__u8 tos;
=20
 	/* Flags word */
-	u_int8_t flags;
+	__u8 flags;
 	/* Inverse flags */
-	u_int8_t invflags;
+	__u8 invflags;
 };
=20
 /* Values for "flag" field in struct ip6t_ip6 (general ip6 structure). */
@@ -118,9 +118,9 @@ struct ip6t_entry {
 	unsigned int nfcache;
=20
 	/* Size of ipt_entry + matches */
-	u_int16_t target_offset;
+	__u16 target_offset;
 	/* Size of ipt_entry + matches + target */
-	u_int16_t next_offset;
+	__u16 next_offset;
=20
 	/* Back pointer */
 	unsigned int comefrom;
@@ -186,9 +186,9 @@ struct ip6t_error {
=20
 /* ICMP matching stuff */
 struct ip6t_icmp {
-	u_int8_t type;				/* type to match */
-	u_int8_t code[2];			/* range of code */
-	u_int8_t invflags;			/* Inverse flags */
+	__u8 type;				/* type to match */
+	__u8 code[2];				/* range of code */
+	__u8 invflags;				/* Inverse flags */
 };
=20
 /* Values for "inv" field for struct ipt_icmp. */
@@ -298,8 +298,8 @@ extern int ipv6_find_hdr(const struct sk_buff *skb, uns=
igned int *offset,
 struct compat_ip6t_entry {
 	struct ip6t_ip6 ipv6;
 	compat_uint_t nfcache;
-	u_int16_t target_offset;
-	u_int16_t next_offset;
+	__u16 target_offset;
+	__u16 next_offset;
 	compat_uint_t comefrom;
 	struct compat_xt_counters counters;
 	unsigned char elems[0];
--=20
1.7.5.4




--=-VdO05L2u4ehBeGid+yUt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlXTSee/yOyVhhEJAQqZtBAAmxCd/yJgHYhcOEFVYKgg4ixnTtkrXxbv
VD58tDM05s3wDwiM6Erb7/2nYoyt4kjEXy2QvgeV3pikDbWQeQdCi16xA1+Ulq69
UsFUc9bCbvc1YEwf/yUUTgxc31Z8QjUU/pJSQGQf5smUrkKwifcbUhRW0nzU1/gi
Rx5gFDxepQn9zy8FG3PcRXjsYoZ1AGE0WKehwvXVPxnb/5rFkeuxmWWPo/1Wc1YE
uqyzpj5vWMpEO085xTjOms+aJtFgNMMguxVMtBW1619Dpz960EbsMXI7VEBD+KvQ
Qf93gJGsmjkrNEeoKj9pVy8OBj2aBRa1AXyy4pPyzii4uKxG+nyH+09jG+vG1THe
8VNZBBTxlibp/jqT1G+vsFX9Yx2KGM5LDNtLB3qk169yW0gAeqcA+L+5suq+5Gdm
VfZgkE08yo3H58Hw039xy1fYBrDTECTRT0Ljj8jDSnV72PaB1CCeCX4GVZauQ0Dg
SeZGogh+V695PXIxISPg2X+qyrUE+TlpKUpCNm7L6YR2AbzTclpvOLTMhq9w846n
rkTP6X7P5DcyOGn9OAjccSJo68DZdRHgN2wmO4BaFtxA70PjZc3X4e5Wtwc3cXwz
L3MF6xdpg6oNRJhX0im2NfqQYMgi8fE9gziFftmXe5jUFCXOgu8YcItsw1f2ykB4
54l4krW7foM=
=J0K4
-----END PGP SIGNATURE-----

--=-VdO05L2u4ehBeGid+yUt--
