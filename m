From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 3/8] net/ethernet: smsc9194: Drop conditional code for H8/300
Date: Fri, 30 Aug 2013 16:51:29 -0700
Message-ID: <1377906694-9578-4-git-send-email-linux@roeck-us.net>
References: <1377906694-9578-1-git-send-email-linux@roeck-us.net>
Cc: linux-ide@vger.kernel.org, netdev@vger.kernel.org,
	linux-watchdog@vger.kernel.org, Wim Van Sebroeck <wim@iguana.be>,
	"David S. Miller" <davem@davemloft.net>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Paris <eparis@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiang Liu <jiang.liu@huawei.com>,
	David Howells <dhowells@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Guenter Roeck <linux@roeck-us.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377906694-9578-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the H8/300 architecture gone, this code is no longer necessary.

Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/smsc/smc9194.c |   24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
index e85c2e7..afd9873 100644
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -95,14 +95,6 @@ static const char version[] =
 #define USE_32_BIT 1
 #endif
 
-#if defined(__H8300H__) || defined(__H8300S__)
-#define NO_AUTOPROBE
-#undef insl
-#undef outsl
-#define insl(a,b,l)  io_insl_noswap(a,b,l)
-#define outsl(a,b,l) io_outsl_noswap(a,b,l)
-#endif
-
 /*
  .the SMC9194 can be at any of the following port addresses.  To change,
  .for a slightly different card, you can add it to the array.  Keep in
@@ -114,12 +106,6 @@ struct devlist {
 	unsigned int irq;
 };
 
-#if defined(CONFIG_H8S_EDOSK2674)
-static struct devlist smc_devlist[] __initdata = {
-	{.port = 0xf80000, .irq = 16},
-	{.port = 0,        .irq = 0 },
-};
-#else
 static struct devlist smc_devlist[] __initdata = {
 	{.port = 0x200, .irq = 0},
 	{.port = 0x220, .irq = 0},
@@ -139,7 +125,6 @@ static struct devlist smc_devlist[] __initdata = {
 	{.port = 0x3E0, .irq = 0},
 	{.port = 0,     .irq = 0},
 };
-#endif
 /*
  . Wait time for memory to be free.  This probably shouldn't be
  . tuned that much, as waiting for this means nothing else happens
@@ -651,11 +636,7 @@ static void smc_hardware_send_packet( struct net_device * dev )
 #ifdef USE_32_BIT
 	if ( length & 0x2  ) {
 		outsl(ioaddr + DATA_1, buf,  length >> 2 );
-#if !defined(__H8300H__) && !defined(__H8300S__)
 		outw( *((word *)(buf + (length & 0xFFFFFFFC))),ioaddr +DATA_1);
-#else
-		ctrl_outw( *((word *)(buf + (length & 0xFFFFFFFC))),ioaddr +DATA_1);
-#endif
 	}
 	else
 		outsl(ioaddr + DATA_1, buf,  length >> 2 );
@@ -899,7 +880,6 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 		retval = -ENODEV;
 		goto err_out;
 	}
-#if !defined(CONFIG_H8S_EDOSK2674)
 	/* well, we've already written once, so hopefully another time won't
  	   hurt.  This time, I need to switch the bank register to bank 1,
 	   so I can access the base address register */
@@ -914,10 +894,6 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 		retval = -ENODEV;
 		goto err_out;
 	}
-#else
-	(void)base_address_register; /* Warning suppression */
-#endif
-
 
 	/*  check if the revision register is something that I recognize.
 	    These might need to be added to later, as future revisions
-- 
1.7.9.7
