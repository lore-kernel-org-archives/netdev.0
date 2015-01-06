From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] doc: fix the compile error of txtimestamp.c
Date: Tue,  6 Jan 2015 15:45:32 -0800
Message-ID: <1420587932-8733-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1420587932-8733-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: carlos@redhat.com, vlee@twopensource.com, davem@davemloft.net,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:62266 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbbAFXpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 18:45:39 -0500
Received: by mail-pd0-f182.google.com with SMTP id p10so808584pdj.13
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 15:45:38 -0800 (PST)
In-Reply-To: <1420587932-8733-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vinson reported:

  HOSTCC  Documentation/networking/timestamping/txtimestamp
Documentation/networking/timestamping/txtimestamp.c:64:8: error:
redefinition of =E2=80=98struct in6_pktinfo=E2=80=99
 struct in6_pktinfo {
        ^
In file included from /usr/include/arpa/inet.h:23:0,
                 from Documentation/networking/timestamping/txtimestamp=
=2Ec:33:
/usr/include/netinet/in.h:456:8: note: originally defined here
 struct in6_pktinfo
        ^

After we sync with libc header, we don't need this ugly hack any more.

Reported-by: Vinson Lee <vlee@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 Documentation/networking/timestamping/txtimestamp.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/Documentation/networking/timestamping/txtimestamp.c b/Docu=
mentation/networking/timestamping/txtimestamp.c
index 876f71c..8778e68 100644
--- a/Documentation/networking/timestamping/txtimestamp.c
+++ b/Documentation/networking/timestamping/txtimestamp.c
@@ -59,14 +59,6 @@
 #include <time.h>
 #include <unistd.h>
=20
-/* ugly hack to work around netinet/in.h and linux/ipv6.h conflicts */
-#ifndef in6_pktinfo
-struct in6_pktinfo {
-	struct in6_addr	ipi6_addr;
-	int		ipi6_ifindex;
-};
-#endif
-
 /* command line parameters */
 static int cfg_proto =3D SOCK_STREAM;
 static int cfg_ipproto =3D IPPROTO_TCP;
--=20
1.8.3.1
