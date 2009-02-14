From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 19/43] drivers/net/hamradio: fix warning: format not a string
	literal and no ...
Date: Sat, 14 Feb 2009 22:33:21 +0100
Message-ID: <20090214213243.24377.94508.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:57943 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbZBNVd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:33:27 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Use 'static const char[]' instead of 'static char[]' and while
being at it fix an issue in 'mkiss_init_driver', where in case of an
error the status code was not passed to printk.

Fix this warnings:
  drivers/net/hamradio/6pack.c: In function 'sixpack_init_driver':
  drivers/net/hamradio/6pack.c:802: warning: format not a string literal and no format arguments
  drivers/net/hamradio/bpqether.c: In function 'bpq_init_driver':
  drivers/net/hamradio/bpqether.c:609: warning: format not a string literal and no format arguments
  drivers/net/hamradio/mkiss.c: In function 'mkiss_init_driver':
  drivers/net/hamradio/mkiss.c:988: warning: format not a string literal and no format arguments
  drivers/net/hamradio/mkiss.c:991: warning: format not a string literal and no format arguments
  drivers/net/hamradio/scc.c: In function 'scc_init_driver':
  drivers/net/hamradio/scc.c:2109: warning: format not a string literal and no format arguments
  drivers/net/hamradio/yam.c: In function 'yam_init_driver':
  drivers/net/hamradio/yam.c:1094: warning: format not a string literal and no format arguments

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/hamradio/6pack.c    |    4 ++--
 drivers/net/hamradio/bpqether.c |    3 ++-
 drivers/net/hamradio/mkiss.c    |    9 +++++----
 drivers/net/hamradio/scc.c      |    3 ++-
 drivers/net/hamradio/yam.c      |    3 ++-
 5 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 3da9f39..1551600 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -790,9 +790,9 @@ static struct tty_ldisc_ops sp_ldisc = {
 
 /* Initialize 6pack control device -- register 6pack line discipline */
 
-static char msg_banner[]  __initdata = KERN_INFO \
+static const char msg_banner[]  __initdata = KERN_INFO \
 	"AX.25: 6pack driver, " SIXPACK_VERSION "\n";
-static char msg_regfail[] __initdata = KERN_ERR  \
+static const char msg_regfail[] __initdata = KERN_ERR  \
 	"6pack: can't register line discipline (err = %d)\n";
 
 static int __init sixpack_init_driver(void)
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 2c619bc..723e9c1 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -87,7 +87,8 @@
 
 #include <linux/bpqether.h>
 
-static char banner[] __initdata = KERN_INFO "AX.25: bpqether driver version 004\n";
+static const char banner[] __initdata = KERN_INFO \
+	"AX.25: bpqether driver version 004\n";
 
 static char bcast_addr[6]={0xFF,0xFF,0xFF,0xFF,0xFF,0xFF};
 
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index ed5b37d..032c0db 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -976,9 +976,9 @@ static struct tty_ldisc_ops ax_ldisc = {
 	.write_wakeup	= mkiss_write_wakeup
 };
 
-static char banner[] __initdata = KERN_INFO \
+static const char banner[] __initdata = KERN_INFO \
 	"mkiss: AX.25 Multikiss, Hans Albas PE1AYX\n";
-static char msg_regfail[] __initdata = KERN_ERR \
+static const char msg_regfail[] __initdata = KERN_ERR \
 	"mkiss: can't register line discipline (err = %d)\n";
 
 static int __init mkiss_init_driver(void)
@@ -987,8 +987,9 @@ static int __init mkiss_init_driver(void)
 
 	printk(banner);
 
-	if ((status = tty_register_ldisc(N_AX25, &ax_ldisc)) != 0)
-		printk(msg_regfail);
+	status = tty_register_ldisc(N_AX25, &ax_ldisc);
+	if (status != 0)
+		printk(msg_regfail, status);
 
 	return status;
 }
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 2acb18f..d712e7a 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -184,7 +184,8 @@
 
 #include "z8530.h"
 
-static char banner[] __initdata = KERN_INFO "AX.25: Z8530 SCC driver version "VERSION".dl1bke\n";
+static const char banner[] __initdata = KERN_INFO \
+	"AX.25: Z8530 SCC driver version "VERSION".dl1bke\n";
 
 static void t_dwait(unsigned long);
 static void t_txdelay(unsigned long);
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 82a8be7..a54b865 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -77,7 +77,8 @@
 /* --------------------------------------------------------------------- */
 
 static const char yam_drvname[] = "yam";
-static char yam_drvinfo[] __initdata = KERN_INFO "YAM driver version 0.8 by F1OAT/F6FBB\n";
+static const char yam_drvinfo[] __initdata = KERN_INFO \
+	"YAM driver version 0.8 by F1OAT/F6FBB\n";
 
 /* --------------------------------------------------------------------- */
 

