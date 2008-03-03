From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] fix drivers/net/atarilance.c compilation
Date: Mon, 3 Mar 2008 23:34:13 +0200
Message-ID: <20080303213413.GN26072@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org
To: jgarzik@pobox.com, geert@linux-m68k.org, zippel@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:49755 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753975AbYCCVfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 16:35:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following build error:

<--  snip  -->

...
  CC [M]  drivers/net/atarilance.o
{standard input}: Assembler messages:
{standard input}:406: Error: symbol `Lberr' is already defined
{standard input}:460: Error: symbol `Lberr' is already defined
make[3]: *** [drivers/net/atarilance.o] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/atarilance.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

0e01f8d77cf240995235717a4e8582dfefab2926 foobar
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index b74dbee..d612dd4 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -336,8 +336,6 @@ struct lance_addr {
 
 /***************************** Prototypes *****************************/
 
-static int addr_accessible( volatile void *regp, int wordflag, int
-                            writeflag );
 static unsigned long lance_probe1( struct net_device *dev, struct lance_addr
                                    *init_rec );
 static int lance_open( struct net_device *dev );
@@ -406,7 +404,8 @@ struct net_device * __init atarilance_probe(int unit)
 
 /* Derived from hwreg_present() in atari/config.c: */
 
-static int __init addr_accessible( volatile void *regp, int wordflag, int writeflag )
+static noinline int __init addr_accessible(volatile void *regp, int wordflag,
+					   int writeflag)
 {
 	int		ret;
 	long	flags;

