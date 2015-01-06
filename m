From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] ipv6: fix redefinition of in6_pktinfo and ip6_mtuinfo
Date: Tue,  6 Jan 2015 15:45:31 -0800
Message-ID: <1420587932-8733-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: carlos@redhat.com, vlee@twopensource.com, davem@davemloft.net,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36723 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbbAFXph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 18:45:37 -0500
Received: by mail-pd0-f182.google.com with SMTP id p10so808476pdj.13
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 15:45:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both netinet/in.h and linux/ipv6.h define these two structs,
if we include both of them, we got:

	/usr/include/linux/ipv6.h:19:8: error: redefinition of =E2=80=98struct=
 in6_pktinfo=E2=80=99
	 struct in6_pktinfo {
		^
	In file included from /usr/include/arpa/inet.h:22:0,
			 from txtimestamp.c:33:
	/usr/include/netinet/in.h:524:8: note: originally defined here
	 struct in6_pktinfo
		^
	In file included from txtimestamp.c:40:0:
	/usr/include/linux/ipv6.h:24:8: error: redefinition of =E2=80=98struct=
 ip6_mtuinfo=E2=80=99
	 struct ip6_mtuinfo {
		^
	In file included from /usr/include/arpa/inet.h:22:0,
			 from txtimestamp.c:33:
	/usr/include/netinet/in.h:531:8: note: originally defined here
	 struct ip6_mtuinfo
		^
So similarly to what we did for in6_addr, we need to sync with
libc header on their definitions.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/uapi/linux/ipv6.h        | 5 ++++-
 include/uapi/linux/libc-compat.h | 6 ++++++
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index e863d08..b9b1b7d 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -15,16 +15,19 @@
  *	*under construction*
  */
=20
-
+#if __UAPI_DEF_IN6_PKTINFO
 struct in6_pktinfo {
 	struct in6_addr	ipi6_addr;
 	int		ipi6_ifindex;
 };
+#endif
=20
+#if __UAPI_DEF_IP6_MTUINFO
 struct ip6_mtuinfo {
 	struct sockaddr_in6	ip6m_addr;
 	__u32			ip6m_mtu;
 };
+#endif
=20
 struct in6_ifreq {
 	struct in6_addr	ifr6_addr;
diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc=
-compat.h
index e28807a..fa673e9 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -70,6 +70,8 @@
 #define __UAPI_DEF_IPV6_MREQ		0
 #define __UAPI_DEF_IPPROTO_V6		0
 #define __UAPI_DEF_IPV6_OPTIONS		0
+#define __UAPI_DEF_IN6_PKTINFO		0
+#define __UAPI_DEF_IP6_MTUINFO		0
=20
 #else
=20
@@ -84,6 +86,8 @@
 #define __UAPI_DEF_IPV6_MREQ		1
 #define __UAPI_DEF_IPPROTO_V6		1
 #define __UAPI_DEF_IPV6_OPTIONS		1
+#define __UAPI_DEF_IN6_PKTINFO		1
+#define __UAPI_DEF_IP6_MTUINFO		1
=20
 #endif /* _NETINET_IN_H */
=20
@@ -106,6 +110,8 @@
 #define __UAPI_DEF_IPV6_MREQ		1
 #define __UAPI_DEF_IPPROTO_V6		1
 #define __UAPI_DEF_IPV6_OPTIONS		1
+#define __UAPI_DEF_IN6_PKTINFO		1
+#define __UAPI_DEF_IP6_MTUINFO		1
=20
 /* Definitions for xattr.h */
 #define __UAPI_DEF_XATTR		1
--=20
1.8.3.1
