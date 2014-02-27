From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] ipv6: addrconf: silence sparse endianness warnings
Date: Thu, 27 Feb 2014 14:20:29 +0100
Message-ID: <1393507229-14871-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44139 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbaB0NUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 08:20:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid the following sparse __CHECK_ENDIAN__ warnings:

 include/net/addrconf.h:318:25: warning: restricted __be64 degrades to =
integer
 include/net/addrconf.h:318:70: warning: restricted __be64 degrades to =
integer
 include/net/addrconf.h:330:25: warning: restricted __be64 degrades to =
integer
 include/net/addrconf.h:330:70: warning: restricted __be64 degrades to =
integer
 include/net/addrconf.h:347:25: warning: restricted __be64 degrades to =
integer
 include/net/addrconf.h:348:26: warning: restricted __be64 degrades to =
integer
 include/net/addrconf.h:349:18: warning: restricted __be64 degrades to =
integer

The warnings are false but they make it harder to spot real
bugs.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 include/net/addrconf.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 50e39a8822b4..933a9f22a05f 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -314,7 +314,7 @@ static inline bool ipv6_addr_is_multicast(const str=
uct in6_addr *addr)
 static inline bool ipv6_addr_is_ll_all_nodes(const struct in6_addr *ad=
dr)
 {
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG =3D=
=3D 64
-	__u64 *p =3D (__u64 *)addr;
+	__be64 *p =3D (__be64 *)addr;
 	return ((p[0] ^ cpu_to_be64(0xff02000000000000UL)) | (p[1] ^ cpu_to_b=
e64(1))) =3D=3D 0UL;
 #else
 	return ((addr->s6_addr32[0] ^ htonl(0xff020000)) |
@@ -326,7 +326,7 @@ static inline bool ipv6_addr_is_ll_all_nodes(const =
struct in6_addr *addr)
 static inline bool ipv6_addr_is_ll_all_routers(const struct in6_addr *=
addr)
 {
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG =3D=
=3D 64
-	__u64 *p =3D (__u64 *)addr;
+	__be64 *p =3D (__be64 *)addr;
 	return ((p[0] ^ cpu_to_be64(0xff02000000000000UL)) | (p[1] ^ cpu_to_b=
e64(2))) =3D=3D 0UL;
 #else
 	return ((addr->s6_addr32[0] ^ htonl(0xff020000)) |
@@ -343,7 +343,7 @@ static inline bool ipv6_addr_is_isatap(const struct=
 in6_addr *addr)
 static inline bool ipv6_addr_is_solict_mult(const struct in6_addr *add=
r)
 {
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG =3D=
=3D 64
-	__u64 *p =3D (__u64 *)addr;
+	__be64 *p =3D (__be64 *)addr;
 	return ((p[0] ^ cpu_to_be64(0xff02000000000000UL)) |
 		((p[1] ^ cpu_to_be64(0x00000001ff000000UL)) &
 		 cpu_to_be64(0xffffffffff000000UL))) =3D=3D 0UL;
--=20
1.9.0
