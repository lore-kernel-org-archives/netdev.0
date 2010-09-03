From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] wan: make driver strings const
Date: Thu, 2 Sep 2010 17:29:35 -0700
Message-ID: <20100902172935.469cfeeb@nehalam>
References: <20100901181515.02c5abdc@nehalam>
	<20100901.182014.141246825.davem@davemloft.net>
	<20100901.191921.66727586.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, andrew.hendry@gmail.com,
	elendil@planet.nl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57966 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444Ab0ICA3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Sep 2010 20:29:38 -0400
In-Reply-To: <20100901.191921.66727586.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: wan: make read-only data const

Change several wan drivers to make strings and other initialize
only parameters const.

Compile tested only (with no new warnings)

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - fixe get_options_index as well

 drivers/net/wan/cycx_drv.c  |   10 +++++-----
 drivers/net/wan/cycx_main.c |    6 +++---
 drivers/net/wan/lapbether.c |    2 +-
 drivers/net/wan/pc300_drv.c |    2 +-
 drivers/net/wan/z85230.c    |    2 +-
 5 files changed, 11 insertions(+), 11 deletions(-)

--- a/drivers/net/wan/cycx_drv.c	2010-09-02 10:21:41.557110204 -0700
+++ b/drivers/net/wan/cycx_drv.c	2010-09-02 10:36:52.526128313 -0700
@@ -73,7 +73,7 @@ static int reset_cyc2x(void __iomem *add
 static int detect_cyc2x(void __iomem *addr);
 
 /* Miscellaneous functions */
-static int get_option_index(long *optlist, long optval);
+static int get_option_index(const long *optlist, long optval);
 static u16 checksum(u8 *buf, u32 len);
 
 #define wait_cyc(addr) cycx_exec(addr + CMD_OFFSET)
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
@@ -529,7 +529,7 @@ static int detect_cyc2x(void __iomem *ad
 /* Miscellaneous */
 /* Get option's index into the options list.
  *	Return option's index (1 .. N) or zero if option is invalid. */
-static int get_option_index(long *optlist, long optval)
+static int get_option_index(const long *optlist, long optval)
 {
 	int i = 1;
 
--- a/drivers/net/wan/cycx_main.c	2010-09-02 10:21:41.505110837 -0700
+++ b/drivers/net/wan/cycx_main.c	2010-09-02 10:22:18.512662264 -0700
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
--- a/drivers/net/wan/lapbether.c	2010-09-02 10:21:41.613109523 -0700
+++ b/drivers/net/wan/lapbether.c	2010-09-02 10:22:18.512662264 -0700
@@ -46,7 +46,7 @@
 
 #include <net/x25device.h>
 
-static char bcast_addr[6] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
+static const u8 bcast_addr[6] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
 
 /* If this number is made larger, check that the temporary string buffer
  * in lapbeth_new_device is large enough to store the probe device name.*/
--- a/drivers/net/wan/z85230.c	2010-09-02 10:21:41.633109279 -0700
+++ b/drivers/net/wan/z85230.c	2010-09-02 10:22:18.516662216 -0700
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
--- a/drivers/net/wan/pc300_drv.c	2010-09-02 10:21:41.577109961 -0700
+++ b/drivers/net/wan/pc300_drv.c	2010-09-02 10:22:18.516662216 -0700
@@ -1,5 +1,5 @@
 #define	USE_PCI_CLOCK
-static char rcsid[] = 
+static const char rcsid[] =
 "Revision: 3.4.5 Date: 2002/03/07 ";
 
 /*
