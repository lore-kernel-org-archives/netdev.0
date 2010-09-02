From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] wan: make driver strings const
Date: Wed, 1 Sep 2010 18:15:15 -0700
Message-ID: <20100901181515.02c5abdc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	Frans Pop <elendil@planet.nl>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60727 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752182Ab0IBBPT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 21:15:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change several wan drivers to make strings and other initialize
only parameters const.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/wan/cycx_drv.c  |   10 +++++-----
 drivers/net/wan/cycx_main.c |    6 +++---
 drivers/net/wan/lapbether.c |    2 +-
 drivers/net/wan/pc300_drv.c |    2 +-
 drivers/net/wan/z85230.c    |    2 +-
 5 files changed, 11 insertions(+), 11 deletions(-)

--- a/drivers/net/wan/cycx_drv.c	2010-09-01 17:49:46.685881759 -0700
+++ b/drivers/net/wan/cycx_drv.c	2010-09-01 17:50:36.862253771 -0700
@@ -81,23 +81,23 @@ static u16 checksum(u8 *buf, u32 len);
 /* Global Data */
 
 /* private data */
-static char modname[] = "cycx_drv";
-static char fullname[] = "Cyclom 2X Support Module";
-static char copyright[] = "(c) 1998-2003 Arnaldo Carvalho de Melo "
+static const char modname[] = "cycx_drv";
+static const char fullname[] = "Cyclom 2X Support Module";
+static const char copyright[] = "(c) 1998-2003 Arnaldo Carvalho de Melo "
 			  "<acme@conectiva.com.br>";
 
 /* Hardware configuration options.
  * These are arrays of configuration options used by verification routines.
  * The first element of each array is its size (i.e. number of options).
  */
-static long cyc2x_dpmbase_options[] = {
+static const long cyc2x_dpmbase_options[] = {
 	20,
 	0xA0000, 0xA4000, 0xA8000, 0xAC000, 0xB0000, 0xB4000, 0xB8000,
 	0xBC000, 0xC0000, 0xC4000, 0xC8000, 0xCC000, 0xD0000, 0xD4000,
 	0xD8000, 0xDC000, 0xE0000, 0xE4000, 0xE8000, 0xEC000
 };
 
-static long cycx_2x_irq_options[]  = { 7, 3, 5, 9, 10, 11, 12, 15 };
+static const long cycx_2x_irq_options[]  = { 7, 3, 5, 9, 10, 11, 12, 15 };
 
 /* Kernel Loadable Module Entry Points */
 /* Module 'insert' entry point.
--- a/drivers/net/wan/cycx_main.c	2010-09-01 17:49:46.713881960 -0700
+++ b/drivers/net/wan/cycx_main.c	2010-09-01 17:50:52.134372392 -0700
@@ -81,9 +81,9 @@ static irqreturn_t cycx_isr(int irq, voi
  */
 
 /* private data */
-static char cycx_drvname[] = "cyclomx";
-static char cycx_fullname[] = "CYCLOM 2X(tm) Sync Card Driver";
-static char cycx_copyright[] = "(c) 1998-2003 Arnaldo Carvalho de Melo "
+static const char cycx_drvname[] = "cyclomx";
+static const char cycx_fullname[] = "CYCLOM 2X(tm) Sync Card Driver";
+static const char cycx_copyright[] = "(c) 1998-2003 Arnaldo Carvalho de Melo "
 			  "<acme@conectiva.com.br>";
 static int cycx_ncards = CONFIG_CYCX_CARDS;
 static struct cycx_device *cycx_card_array;	/* adapter data space */
--- a/drivers/net/wan/lapbether.c	2010-09-01 17:49:46.801882588 -0700
+++ b/drivers/net/wan/lapbether.c	2010-09-01 17:52:14.047049568 -0700
@@ -46,7 +46,7 @@
 
 #include <net/x25device.h>
 
-static char bcast_addr[6] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
+static const u8 bcast_addr[6] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
 
 /* If this number is made larger, check that the temporary string buffer
  * in lapbeth_new_device is large enough to store the probe device name.*/
--- a/drivers/net/wan/z85230.c	2010-09-01 17:49:46.917883415 -0700
+++ b/drivers/net/wan/z85230.c	2010-09-01 17:56:52.853813325 -0700
@@ -766,7 +766,7 @@ irqreturn_t z8530_interrupt(int irq, voi
 
 EXPORT_SYMBOL(z8530_interrupt);
 
-static char reg_init[16]=
+static const u8 reg_init[16]=
 {
 	0,0,0,0,
 	0,0,0,0,
@@ -1206,7 +1206,7 @@ EXPORT_SYMBOL(z8530_sync_txdma_close);
  *	it exists...
  */
  
-static char *z8530_type_name[]={
+static const char *z8530_type_name[]={
 	"Z8530",
 	"Z85C30",
 	"Z85230"
--- a/drivers/net/wan/pc300_drv.c	2010-09-01 17:49:46.857882987 -0700
+++ b/drivers/net/wan/pc300_drv.c	2010-09-01 17:56:23.265489845 -0700
@@ -1,5 +1,5 @@
 #define	USE_PCI_CLOCK
-static char rcsid[] = 
+static const char rcsid[] =
 "Revision: 3.4.5 Date: 2002/03/07 ";
 
 /*
