From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 05/17] net: mark const init data with __initconst instead of __initdata
Date: Thu, 29 Mar 2012 23:12:22 +0200
Message-ID: <1333055554-31300-5-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20120329211131.GA31250@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de,
	Andreas Koensgen <ajk@comnets.uni-bremen.de>,
	Klaus Kudielka <klaus.kudielka@ieee.org>,
	Joerg Reuter <jreuter@yaina.de>,
	Jean-Paul Roubelat <jpr@f6fbb.org>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
To: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20120329211131.GA31250@pengutronix.de>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As long as there is no other non-const variable marked __initdata in th=
e
same compilation unit it doesn't hurt. If there were one however
compilation would fail with

	error: $variablename causes a section type conflict

because a section containing const variables is marked read only and so
cannot contain non-const variables.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: Andreas Koensgen <ajk@comnets.uni-bremen.de>
Cc: Klaus Kudielka <klaus.kudielka@ieee.org>
Cc: Joerg Reuter <jreuter@yaina.de>
Cc: Jean-Paul Roubelat <jpr@f6fbb.org>
Cc: netdev@vger.kernel.org
Cc: linux-hams@vger.kernel.org
---
 drivers/net/ethernet/8390/ne3210.c |    2 +-
 drivers/net/hamradio/6pack.c       |    4 ++--
 drivers/net/hamradio/bpqether.c    |    2 +-
 drivers/net/hamradio/mkiss.c       |    4 ++--
 drivers/net/hamradio/scc.c         |    2 +-
 drivers/net/hamradio/yam.c         |    2 +-
 drivers/net/tokenring/smctr.c      |    2 +-
 drivers/net/wan/z85230.c           |    2 +-
 8 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/8390/ne3210.c b/drivers/net/ethernet/=
8390/ne3210.c
index a2f8b2b..f826e74 100644
--- a/drivers/net/ethernet/8390/ne3210.c
+++ b/drivers/net/ethernet/8390/ne3210.c
@@ -81,7 +81,7 @@ static void ne3210_block_output(struct net_device *de=
v, int count, const unsigne
=20
 static unsigned char irq_map[] __initdata =3D {15, 12, 11, 10, 9, 7, 5=
, 3};
 static unsigned int shmem_map[] __initdata =3D {0xff0, 0xfe0, 0xfff0, =
0xd8, 0xffe0, 0xffc0, 0xd0, 0x0};
-static const char *ifmap[] __initdata =3D {"UTP", "?", "BNC", "AUI"};
+static const char *ifmap[] __initconst =3D {"UTP", "?", "BNC", "AUI"};
 static int ifmap_val[] __initdata =3D {
 		IF_PORT_10BASET,
 		IF_PORT_UNKNOWN,
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.=
c
index 64783a0..d225a2a 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -811,9 +811,9 @@ static struct tty_ldisc_ops sp_ldisc =3D {
=20
 /* Initialize 6pack control device -- register 6pack line discipline *=
/
=20
-static const char msg_banner[]  __initdata =3D KERN_INFO \
+static const char msg_banner[]  __initconst =3D KERN_INFO \
 	"AX.25: 6pack driver, " SIXPACK_VERSION "\n";
-static const char msg_regfail[] __initdata =3D KERN_ERR  \
+static const char msg_regfail[] __initconst =3D KERN_ERR  \
 	"6pack: can't register line discipline (err =3D %d)\n";
=20
 static int __init sixpack_init_driver(void)
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpq=
ether.c
index 76d5477..c2e5497 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -87,7 +87,7 @@
=20
 #include <linux/bpqether.h>
=20
-static const char banner[] __initdata =3D KERN_INFO \
+static const char banner[] __initconst =3D KERN_INFO \
 	"AX.25: bpqether driver version 004\n";
=20
 static char bcast_addr[6]=3D{0xFF,0xFF,0xFF,0xFF,0xFF,0xFF};
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.=
c
index aed1a61..d694215 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -997,9 +997,9 @@ static struct tty_ldisc_ops ax_ldisc =3D {
 	.write_wakeup	=3D mkiss_write_wakeup
 };
=20
-static const char banner[] __initdata =3D KERN_INFO \
+static const char banner[] __initconst =3D KERN_INFO \
 	"mkiss: AX.25 Multikiss, Hans Albas PE1AYX\n";
-static const char msg_regfail[] __initdata =3D KERN_ERR \
+static const char msg_regfail[] __initconst =3D KERN_ERR \
 	"mkiss: can't register line discipline (err =3D %d)\n";
=20
 static int __init mkiss_init_driver(void)
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index efc6c97..1b4a47b 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -182,7 +182,7 @@
=20
 #include "z8530.h"
=20
-static const char banner[] __initdata =3D KERN_INFO \
+static const char banner[] __initconst =3D KERN_INFO \
 	"AX.25: Z8530 SCC driver version "VERSION".dl1bke\n";
=20
 static void t_dwait(unsigned long);
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 5a6412e..c6645f1 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -76,7 +76,7 @@
 /* -------------------------------------------------------------------=
-- */
=20
 static const char yam_drvname[] =3D "yam";
-static const char yam_drvinfo[] __initdata =3D KERN_INFO \
+static const char yam_drvinfo[] __initconst =3D KERN_INFO \
 	"YAM driver version 0.8 by F1OAT/F6FBB\n";
=20
 /* -------------------------------------------------------------------=
-- */
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smct=
r.c
index cb35fb7..90b5f1e 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -59,7 +59,7 @@
=20
 #include "smctr.h"               /* Our Stuff */
=20
-static const char version[] __initdata =3D
+static const char version[] __initconst =3D
 	KERN_INFO "smctr.c: v1.4 7/12/00 by jschlst@samba.org\n";
 static const char cardname[] =3D "smctr";
=20
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 0e57690..feacc3b 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -1775,7 +1775,7 @@ EXPORT_SYMBOL(z8530_queue_xmit);
 /*
  *	Module support
  */
-static const char banner[] __initdata =3D
+static const char banner[] __initconst =3D
 	KERN_INFO "Generic Z85C30/Z85230 interface driver v0.02\n";
=20
 static int __init z85230_init_driver(void)
--=20
1.7.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
