From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 10/13] net: Move prototype declaration to header file
 include/net/datalink.h from net/ipx/af_ipx.c
Date: Sun, 9 Feb 2014 01:35:38 +0530
Message-ID: <f1d749c96d96ee3d237723dbcefcdbf43387eacf.1391888654.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:60742 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbaBHUFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Feb 2014 15:05:44 -0500
Content-Disposition: inline
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move prototype declarations of function to header file
include/net/datalink.h from net/ipx/af_ipx.c because they are used by
more than one file.

This eliminates the following warning in net/ipx/pe2.c:
net/ipx/pe2.c:20:24: warning: no previous prototype for =E2=80=98make_E=
II_client=E2=80=99 [-Wmissing-prototypes]
net/ipx/pe2.c:32:6: warning: no previous prototype for =E2=80=98destroy=
_EII_client=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
---
 include/net/datalink.h |    2 ++
 net/ipx/af_ipx.c       |    4 +---
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/datalink.h b/include/net/datalink.h
index deb7ca7..93cb18f 100644
--- a/include/net/datalink.h
+++ b/include/net/datalink.h
@@ -15,4 +15,6 @@ struct datalink_proto {
 	struct list_head node;
 };
=20
+struct datalink_proto *make_EII_client(void);
+void destroy_EII_client(struct datalink_proto *dl);
 #endif
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index e5a00a9..224d058 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -52,6 +52,7 @@
 #include <net/p8022.h>
 #include <net/psnap.h>
 #include <net/sock.h>
+#include <net/datalink.h>
 #include <net/tcp_states.h>
=20
 #include <asm/uaccess.h>
@@ -1977,9 +1978,6 @@ static struct notifier_block ipx_dev_notifier =3D=
 {
 	.notifier_call	=3D ipxitf_device_event,
 };
=20
-extern struct datalink_proto *make_EII_client(void);
-extern void destroy_EII_client(struct datalink_proto *);
-
 static const unsigned char ipx_8022_type =3D 0xE0;
 static const unsigned char ipx_snap_id[5] =3D { 0x0, 0x0, 0x0, 0x81, 0=
x37 };
 static const char ipx_EII_err_msg[] __initconst =3D
--=20
1.7.9.5
