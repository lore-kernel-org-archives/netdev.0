From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] ibmtr: use kernel min/max
Date: Mon, 23 Feb 2004 13:31:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223133141.16c6c2e4.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.3-current.

--
~Randy

From: Michael Veeck <michael.veeck@gmx.net>


Hi!
Patch (against 2.6.3-rc1) removes unnecessary min/max macros and changes 
calls to use kernel.h macros instead.
Feedback always welcome
Michael

diff -Naur linux-2.6.2.org/drivers/net/tokenring/ibmtr.c linux-2.6.2.new/drivers/net/tokenring/ibmtr.c


 linux-263-kj1-rddunlap/drivers/net/tokenring/ibmtr.c |   24 ++++++++-----------
 1 files changed, 11 insertions(+), 13 deletions(-)

diff -puN drivers/net/tokenring/ibmtr.c~net_ibmtr_minmax drivers/net/tokenring/ibmtr.c
--- linux-263-kj1/drivers/net/tokenring/ibmtr.c~net_ibmtr_minmax	2004-02-18 14:45:11.000000000 -0800
+++ linux-263-kj1-rddunlap/drivers/net/tokenring/ibmtr.c	2004-02-18 14:45:11.000000000 -0800
@@ -136,8 +136,6 @@ in the event that chatty debug messages 
 
 #define DPRINTK(format, args...) printk("%s: " format, dev->name , ## args)
 #define DPRINTD(format, args...) DummyCall("%s: " format, dev->name , ## args)
-#define MIN(X, Y) ((X) < (Y) ? (X) : (Y))
-#define MAX(X, Y) ((X) > (Y) ? (X) : (Y))
 
 /* version and credits */
 #ifndef PCMCIA
@@ -730,47 +728,47 @@ static int __devinit ibmtr_probe1(struct
 	*/
 	if (!ti->page_mask) {
 		ti->avail_shared_ram=
-				MIN(ti->mapped_ram_size,ti->avail_shared_ram);
+				min(ti->mapped_ram_size,ti->avail_shared_ram);
 	}
 
 	switch (ti->avail_shared_ram) {
 	case 16:		/* 8KB shared RAM */
-		ti->dhb_size4mb = MIN(ti->dhb_size4mb, 2048);
+		ti->dhb_size4mb = min(ti->dhb_size4mb, (unsigned short)2048);
 		ti->rbuf_len4 = 1032;
 		ti->rbuf_cnt4=2;
-		ti->dhb_size16mb = MIN(ti->dhb_size16mb, 2048);
+		ti->dhb_size16mb = min(ti->dhb_size16mb, (unsigned short)2048);
 		ti->rbuf_len16 = 1032;
 		ti->rbuf_cnt16=2;
 		break;
 	case 32:		/* 16KB shared RAM */
-		ti->dhb_size4mb = MIN(ti->dhb_size4mb, 4464);
+		ti->dhb_size4mb = min(ti->dhb_size4mb, (unsigned short)4464);
 		ti->rbuf_len4 = 1032;
 		ti->rbuf_cnt4=4;
-		ti->dhb_size16mb = MIN(ti->dhb_size16mb, 4096);
+		ti->dhb_size16mb = min(ti->dhb_size16mb, (unsigned short)4096);
 		ti->rbuf_len16 = 1032;	/*1024 usable */
 		ti->rbuf_cnt16=4;
 		break;
 	case 64:		/* 32KB shared RAM */
-		ti->dhb_size4mb = MIN(ti->dhb_size4mb, 4464);
+		ti->dhb_size4mb = min(ti->dhb_size4mb, (unsigned short)4464);
 		ti->rbuf_len4 = 1032;
 		ti->rbuf_cnt4=6;
-		ti->dhb_size16mb = MIN(ti->dhb_size16mb, 10240);
+		ti->dhb_size16mb = min(ti->dhb_size16mb, (unsigned short)10240);
 		ti->rbuf_len16 = 1032;
 		ti->rbuf_cnt16=6;
 		break;
 	case 127:		/* 63.5KB shared RAM */
-		ti->dhb_size4mb = MIN(ti->dhb_size4mb, 4464);
+		ti->dhb_size4mb = min(ti->dhb_size4mb, (unsigned short)4464);
 		ti->rbuf_len4 = 1032;
 		ti->rbuf_cnt4=6;
-		ti->dhb_size16mb = MIN(ti->dhb_size16mb, 16384);
+		ti->dhb_size16mb = min(ti->dhb_size16mb, (unsigned short)16384);
 		ti->rbuf_len16 = 1032;
 		ti->rbuf_cnt16=16;
 		break;
 	case 128:		/* 64KB   shared RAM */
-		ti->dhb_size4mb = MIN(ti->dhb_size4mb, 4464);
+		ti->dhb_size4mb = min(ti->dhb_size4mb, (unsigned short)4464);
 		ti->rbuf_len4 = 1032;
 		ti->rbuf_cnt4=6;
-		ti->dhb_size16mb = MIN(ti->dhb_size16mb, 17960);
+		ti->dhb_size16mb = min(ti->dhb_size16mb, (unsigned short)17960);
 		ti->rbuf_len16 = 1032;
 		ti->rbuf_cnt16=16;
 		break;

_
