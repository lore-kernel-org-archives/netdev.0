From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 01/29] LMC: whitespace and cosmetic fixes.
Date: Sat, 31 Jul 2010 17:05:24 +0200
Message-ID: <1280588752-9340-1-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:37717 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753533Ab0GaPGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:19 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/lmc.h       |    9 +-
 drivers/net/wan/lmc/lmc_debug.c |  103 +-
 drivers/net/wan/lmc/lmc_debug.h |    8 +-
 drivers/net/wan/lmc/lmc_ioctl.h |  349 ++---
 drivers/net/wan/lmc/lmc_main.c  | 3348 +++++++++++++++++++------------=
--------
 drivers/net/wan/lmc/lmc_media.c | 1840 ++++++++++------------
 drivers/net/wan/lmc/lmc_proto.c |  129 +-
 drivers/net/wan/lmc/lmc_var.h   |  726 ++++-----
 8 files changed, 3059 insertions(+), 3453 deletions(-)

diff --git a/drivers/net/wan/lmc/lmc.h b/drivers/net/wan/lmc/lmc.h
index 4ced7ac..6d3af03 100644
--- a/drivers/net/wan/lmc/lmc.h
+++ b/drivers/net/wan/lmc/lmc.h
@@ -3,14 +3,11 @@
=20
 #include "lmc_var.h"
=20
-/*
- * prototypes for everyone
- */
-int lmc_probe(struct net_device * dev);
+int lmc_probe(struct net_device *dev);
 unsigned lmc_mii_readreg(lmc_softc_t * const sc, unsigned
-      			  devaddr, unsigned regno);
+			 devaddr, unsigned regno);
 void lmc_mii_writereg(lmc_softc_t * const sc, unsigned devaddr,
-			       unsigned regno, unsigned data);
+		      unsigned regno, unsigned data);
 void lmc_led_on(lmc_softc_t * const, u32);
 void lmc_led_off(lmc_softc_t * const, u32);
 unsigned lmc_mii_readreg(lmc_softc_t * const, unsigned, unsigned);
diff --git a/drivers/net/wan/lmc/lmc_debug.c b/drivers/net/wan/lmc/lmc_=
debug.c
index 15049d7..35a8610 100644
--- a/drivers/net/wan/lmc/lmc_debug.c
+++ b/drivers/net/wan/lmc/lmc_debug.c
@@ -1,50 +1,45 @@
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/interrupt.h>
-
 #include "lmc_debug.h"
=20
 /*
  * Prints out len, max to 80 octets using printk, 20 per line
  */
-#ifdef DEBUG
-#ifdef LMC_PACKET_LOG
+
+#if defined(DEBUG) && defined(LMC_PACKET_LOG)
 void lmcConsoleLog(char *type, unsigned char *ucData, int iLen)
 {
-  int iNewLine =3D 1;
-  char str[80], *pstr;
- =20
-  sprintf(str, KERN_DEBUG "lmc: %s: ", type);
-  pstr =3D str+strlen(str);
- =20
-  if(iLen > 240){
-      printk(KERN_DEBUG "lmc: Printing 240 chars... out of: %d\n", iLe=
n);
-    iLen =3D 240;
-  }
-  else{
-      printk(KERN_DEBUG "lmc: Printing %d chars\n", iLen);
-  }
+	int iNewLine =3D 1;
+	char str[80], *pstr;
=20
-  while(iLen > 0)=20
-    {
-      sprintf(pstr, "%02x ", *ucData);
-      pstr+=3D3;
-      ucData++;
-      if( !(iNewLine % 20))
-	{
-	  sprintf(pstr, "\n");
-	  printk(str);
-	  sprintf(str, KERN_DEBUG "lmc: %s: ", type);
-	  pstr=3Dstr+strlen(str);
+	sprintf(str, KERN_DEBUG "lmc: %s: ", type);
+	pstr =3D str+strlen(str);
+
+	if (iLen > 240) {
+		printk(KERN_DEBUG "lmc: Printing 240 chars... out of: %d\n",
+		       iLen);
+		iLen =3D 240;
+	} else
+		printk(KERN_DEBUG "lmc: Printing %d chars\n", iLen);
+
+	while (iLen > 0) {
+		sprintf(pstr, "%02x ", *ucData);
+		pstr +=3D 3;
+		ucData++;
+		if (!(iNewLine % 20)) {
+			sprintf(pstr, "\n");
+			printk(str);
+			sprintf(str, KERN_DEBUG "lmc: %s: ", type);
+			pstr =3D str + strlen(str);
+		}
+		iNewLine++;
+		iLen--;
 	}
-      iNewLine++;
-      iLen--;
-    }
-  sprintf(pstr, "\n");
-  printk(str);
+	sprintf(pstr, "\n");
+	printk(str);
 }
 #endif
-#endif
=20
 #ifdef DEBUG
 u32 lmcEventLogIndex;
@@ -52,31 +47,29 @@ u32 lmcEventLogBuf[LMC_EVENTLOGSIZE * LMC_EVENTLOGA=
RGS];
=20
 void lmcEventLog(u32 EventNum, u32 arg2, u32 arg3)
 {
-  lmcEventLogBuf[lmcEventLogIndex++] =3D EventNum;
-  lmcEventLogBuf[lmcEventLogIndex++] =3D arg2;
-  lmcEventLogBuf[lmcEventLogIndex++] =3D arg3;
-  lmcEventLogBuf[lmcEventLogIndex++] =3D jiffies;
-
-  lmcEventLogIndex &=3D (LMC_EVENTLOGSIZE * LMC_EVENTLOGARGS) - 1;
+	lmcEventLogBuf[lmcEventLogIndex++] =3D EventNum;
+	lmcEventLogBuf[lmcEventLogIndex++] =3D arg2;
+	lmcEventLogBuf[lmcEventLogIndex++] =3D arg3;
+	lmcEventLogBuf[lmcEventLogIndex++] =3D jiffies;
+	lmcEventLogIndex &=3D (LMC_EVENTLOGSIZE * LMC_EVENTLOGARGS) - 1;
 }
-#endif  /*  DEBUG  */
+#endif  /* DEBUG */
=20
-void lmc_trace(struct net_device *dev, char *msg){
+void lmc_trace(struct net_device *dev, char *msg)
+{
 #ifdef LMC_TRACE
-    unsigned long j =3D jiffies + 3; /* Wait for 50 ms */
+	unsigned long j =3D jiffies + 3; /* Wait for 50 ms */
=20
-    if(in_interrupt()){
-        printk("%s: * %s\n", dev->name, msg);
-//        while(time_before(jiffies, j+10))
-//            ;
-    }
-    else {
-        printk("%s: %s\n", dev->name, msg);
-        while(time_before(jiffies, j))
-            schedule();
-    }
+	if (in_interrupt()) {
+		printk(KERN_DEBUG "%s: * %s\n", dev->name, msg);
+#if 0
+		while (time_before(jiffies, j + 10))
+			;
+#endif
+	} else {
+		printk(KERN_DEBUG "%s: %s\n", dev->name, msg);
+		while (time_before(jiffies, j))
+			schedule();
+	}
 #endif
 }
-
-
-/* --------------------------- end if_lmc_linux.c --------------------=
---- */
diff --git a/drivers/net/wan/lmc/lmc_debug.h b/drivers/net/wan/lmc/lmc_=
debug.h
index 2d46f12..289f7d9 100644
--- a/drivers/net/wan/lmc/lmc_debug.h
+++ b/drivers/net/wan/lmc/lmc_debug.h
@@ -3,12 +3,12 @@
=20
 #ifdef DEBUG
 #ifdef LMC_PACKET_LOG
-#define LMC_CONSOLE_LOG(x,y,z) lmcConsoleLog((x), (y), (z))
+#define LMC_CONSOLE_LOG(x, y, z) lmcConsoleLog((x), (y), (z))
 #else
-#define LMC_CONSOLE_LOG(x,y,z)
+#define LMC_CONSOLE_LOG(x, y, z)
 #endif
 #else
-#define LMC_CONSOLE_LOG(x,y,z)
+#define LMC_CONSOLE_LOG(x, y, z)
 #endif
=20
=20
@@ -42,7 +42,7 @@ extern u32 lmcEventLogIndex;
 extern u32 lmcEventLogBuf[LMC_EVENTLOGSIZE * LMC_EVENTLOGARGS];
 #define LMC_EVENT_LOG(x, y, z) lmcEventLog((x), (y), (z))
 #else
-#define LMC_EVENT_LOG(x,y,z)
+#define LMC_EVENT_LOG(x, y, z)
 #endif /* end ifdef _DBG_EVENTLOG */
=20
 void lmcConsoleLog(char *type, unsigned char *ucData, int iLen);
diff --git a/drivers/net/wan/lmc/lmc_ioctl.h b/drivers/net/wan/lmc/lmc_=
ioctl.h
index 72fb113..45b97e0 100644
--- a/drivers/net/wan/lmc/lmc_ioctl.h
+++ b/drivers/net/wan/lmc/lmc_ioctl.h
@@ -1,76 +1,69 @@
 #ifndef _LMC_IOCTL_H_
 #define _LMC_IOCTL_H_
-/*	$Id: lmc_ioctl.h,v 1.15 2000/04/06 12:16:43 asj Exp $	*/
-
- /*
-  * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
-  * All rights reserved.  www.lanmedia.com
-  *
-  * This code is written by:
-  * Andrew Stanley-Jones (asj@cban.com)
-  * Rob Braun (bbraun@vix.com),
-  * Michael Graff (explorer@vix.com) and
-  * Matt Thomas (matt@3am-software.com).
-  *
-  * This software may be used and distributed according to the terms
-  * of the GNU General Public License version 2, incorporated herein b=
y reference.
-  */
-
-#define LMCIOCGINFO             SIOCDEVPRIVATE+3 /* get current state =
*/
-#define LMCIOCSINFO             SIOCDEVPRIVATE+4 /* set state to user =
values */
-#define LMCIOCGETLMCSTATS       SIOCDEVPRIVATE+5
-#define LMCIOCCLEARLMCSTATS     SIOCDEVPRIVATE+6
-#define LMCIOCDUMPEVENTLOG      SIOCDEVPRIVATE+7
-#define LMCIOCGETXINFO          SIOCDEVPRIVATE+8
-#define LMCIOCSETCIRCUIT        SIOCDEVPRIVATE+9
-#define LMCIOCUNUSEDATM         SIOCDEVPRIVATE+10
-#define LMCIOCRESET             SIOCDEVPRIVATE+11
-#define LMCIOCT1CONTROL         SIOCDEVPRIVATE+12
-#define LMCIOCIFTYPE            SIOCDEVPRIVATE+13
-#define LMCIOCXILINX            SIOCDEVPRIVATE+14
-
-#define LMC_CARDTYPE_UNKNOWN            -1
-#define LMC_CARDTYPE_HSSI               1       /* probed card is a HS=
SI card */
-#define LMC_CARDTYPE_DS3                2       /* probed card is a DS=
3 card */
-#define LMC_CARDTYPE_SSI                3       /* probed card is a SS=
I card */
-#define LMC_CARDTYPE_T1                 4       /* probed card is a T1=
 card */
-
-#define LMC_CTL_CARDTYPE_LMC5200	0	/* HSSI */
-#define LMC_CTL_CARDTYPE_LMC5245	1	/* DS3 */
-#define LMC_CTL_CARDTYPE_LMC1000	2	/* SSI, V.35 */
-#define LMC_CTL_CARDTYPE_LMC1200        3       /* DS1 */
-
-#define LMC_CTL_OFF			0	/* generic OFF value */
-#define LMC_CTL_ON			1	/* generic ON value */
-
-#define LMC_CTL_CLOCK_SOURCE_EXT	0	/* clock off line */
-#define LMC_CTL_CLOCK_SOURCE_INT	1	/* internal clock */
+/*
+ * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
+ * All rights reserved.  www.lanmedia.com
+ *
+ * This code is written by:
+ * Andrew Stanley-Jones (asj@cban.com)
+ * Rob Braun (bbraun@vix.com),
+ * Michael Graff (explorer@vix.com) and
+ * Matt Thomas (matt@3am-software.com).
+ *
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License version 2, incorporated herein by re=
ference.
+ */
+
+#define LMCIOCGINFO         (SIOCDEVPRIVATE + 3) /* get current state =
*/
+#define LMCIOCSINFO         (SIOCDEVPRIVATE + 4) /* set state to user =
values */
+#define LMCIOCGETLMCSTATS   (SIOCDEVPRIVATE + 5)
+#define LMCIOCCLEARLMCSTATS (SIOCDEVPRIVATE + 6)
+#define LMCIOCDUMPEVENTLOG  (SIOCDEVPRIVATE + 7)
+#define LMCIOCGETXINFO      (SIOCDEVPRIVATE + 8)
+#define LMCIOCSETCIRCUIT    (SIOCDEVPRIVATE + 9)
+#define LMCIOCUNUSEDATM     (SIOCDEVPRIVATE + 10)
+#define LMCIOCRESET         (SIOCDEVPRIVATE + 11)
+#define LMCIOCT1CONTROL     (SIOCDEVPRIVATE + 12)
+#define LMCIOCIFTYPE        (SIOCDEVPRIVATE + 13)
+#define LMCIOCXILINX        (SIOCDEVPRIVATE + 14)
+
+#define LMC_CARDTYPE_UNKNOWN		-1
+#define LMC_CARDTYPE_HSSI		1 /* probed card is a HSSI card */
+#define LMC_CARDTYPE_DS3		2 /* probed card is a DS3 card */
+#define LMC_CARDTYPE_SSI		3 /* probed card is a SSI card */
+#define LMC_CARDTYPE_T1			4 /* probed card is a T1 card */
+
+#define LMC_CTL_CARDTYPE_LMC5200	0 /* HSSI */
+#define LMC_CTL_CARDTYPE_LMC5245	1 /* DS3 */
+#define LMC_CTL_CARDTYPE_LMC1000	2 /* SSI, V.35 */
+#define LMC_CTL_CARDTYPE_LMC1200	3 /* DS1 */
+
+#define LMC_CTL_OFF			0 /* generic OFF value */
+#define LMC_CTL_ON			1 /* generic ON value */
+
+#define LMC_CTL_CLOCK_SOURCE_EXT	0 /* clock off line */
+#define LMC_CTL_CLOCK_SOURCE_INT	1 /* internal clock */
=20
 #define LMC_CTL_CRC_LENGTH_16		16
 #define LMC_CTL_CRC_LENGTH_32		32
-#define LMC_CTL_CRC_BYTESIZE_2          2
-#define LMC_CTL_CRC_BYTESIZE_4          4
+#define LMC_CTL_CRC_BYTESIZE_2		2
+#define LMC_CTL_CRC_BYTESIZE_4		4
=20
=20
-#define LMC_CTL_CABLE_LENGTH_LT_100FT	0	/* DS3 cable < 100 feet */
-#define LMC_CTL_CABLE_LENGTH_GT_100FT	1	/* DS3 cable >=3D 100 feet */
+#define LMC_CTL_CABLE_LENGTH_LT_100FT	0 /* DS3 cable < 100 feet */
+#define LMC_CTL_CABLE_LENGTH_GT_100FT	1 /* DS3 cable >=3D 100 feet */
=20
-#define LMC_CTL_CIRCUIT_TYPE_E1 0
-#define LMC_CTL_CIRCUIT_TYPE_T1 1
+#define LMC_CTL_CIRCUIT_TYPE_E1		0
+#define LMC_CTL_CIRCUIT_TYPE_T1		1
=20
-/*
- * IFTYPE defines
- */
-#define LMC_PPP         1               /* use generic HDLC interface =
*/
-#define LMC_NET         2               /* use direct net interface */
-#define LMC_RAW         3               /* use direct net interface */
+/* IFTYPE defines */
+#define LMC_PPP				1 /* use generic HDLC interface */
+#define LMC_NET				2 /* use direct net interface */
+#define LMC_RAW				3 /* use direct net interface */
=20
-/*
- * These are not in the least IOCTL related, but I want them common.
- */
-/*
- * assignments for the GPIO register on the DEC chip (common)
- */
+/* These are not in the least IOCTL related, but I want them common. *=
/
+
+/* assignments for the GPIO register on the DEC chip (common) */
 #define LMC_GEP_INIT		0x01 /* 0: */
 #define LMC_GEP_RESET		0x02 /* 1: */
 #define LMC_GEP_MODE		0x10 /* 4: */
@@ -78,42 +71,32 @@
 #define LMC_GEP_DATA		0x40 /* 6: serial out */
 #define LMC_GEP_CLK	        0x80 /* 7: serial clock */
=20
-/*
- * HSSI GPIO assignments
- */
+/* HSSI GPIO assignments */
 #define LMC_GEP_HSSI_ST		0x04 /* 2: receive timing sense (deprecated) =
*/
 #define LMC_GEP_HSSI_CLOCK	0x08 /* 3: clock source */
=20
-/*
- * T1 GPIO assignments
- */
+/* T1 GPIO assignments */
 #define LMC_GEP_SSI_GENERATOR	0x04 /* 2: enable prog freq gen serial i=
/f */
 #define LMC_GEP_SSI_TXCLOCK	0x08 /* 3: provide clock on TXCLOCK output=
 */
=20
-/*
- * Common MII16 bits
- */
-#define LMC_MII16_LED0         0x0080
-#define LMC_MII16_LED1         0x0100
-#define LMC_MII16_LED2         0x0200
-#define LMC_MII16_LED3         0x0400  /* Error, and the red one */
-#define LMC_MII16_LED_ALL      0x0780  /* LED bit mask */
-#define LMC_MII16_FIFO_RESET   0x0800
-
-/*
- * definitions for HSSI
- */
-#define LMC_MII16_HSSI_TA      0x0001
-#define LMC_MII16_HSSI_CA      0x0002
-#define LMC_MII16_HSSI_LA      0x0004
-#define LMC_MII16_HSSI_LB      0x0008
-#define LMC_MII16_HSSI_LC      0x0010
-#define LMC_MII16_HSSI_TM      0x0020
-#define LMC_MII16_HSSI_CRC     0x0040
-
-/*
- * assignments for the MII register 16 (DS3)
- */
+/* Common MII16 bits */
+#define LMC_MII16_LED0		0x0080
+#define LMC_MII16_LED1		0x0100
+#define LMC_MII16_LED2		0x0200
+#define LMC_MII16_LED3		0x0400  /* Error, and the red one */
+#define LMC_MII16_LED_ALL	0x0780  /* LED bit mask */
+#define LMC_MII16_FIFO_RESET	0x0800
+
+/* definitions for HSSI */
+#define LMC_MII16_HSSI_TA	0x0001
+#define LMC_MII16_HSSI_CA	0x0002
+#define LMC_MII16_HSSI_LA	0x0004
+#define LMC_MII16_HSSI_LB	0x0008
+#define LMC_MII16_HSSI_LC	0x0010
+#define LMC_MII16_HSSI_TM	0x0020
+#define LMC_MII16_HSSI_CRC	0x0040
+
+/* assignments for the MII register 16 (DS3) */
 #define LMC_MII16_DS3_ZERO	0x0001
 #define LMC_MII16_DS3_TRLBK	0x0002
 #define LMC_MII16_DS3_LNLBK	0x0004
@@ -126,127 +109,115 @@
 #define LMC_MII16_DS3_SCRAM_LARS 0x4000
=20
 /* Note: 2 pairs of LEDs where swapped by mistake
- * in Xilinx code for DS3 & DS1 adapters */
-#define LMC_DS3_LED0    0x0100          /* bit 08  yellow */
-#define LMC_DS3_LED1    0x0080          /* bit 07  blue   */
-#define LMC_DS3_LED2    0x0400          /* bit 10  green  */
-#define LMC_DS3_LED3    0x0200          /* bit 09  red    */
-
-/*
- * framer register 0 and 7 (7 is latched and reset on read)
- */
-#define LMC_FRAMER_REG0_DLOS            0x80    /* digital loss of ser=
vice */
-#define LMC_FRAMER_REG0_OOFS            0x40    /* out of frame sync *=
/
-#define LMC_FRAMER_REG0_AIS             0x20    /* alarm indication si=
gnal */
-#define LMC_FRAMER_REG0_CIS             0x10    /* channel idle */
-#define LMC_FRAMER_REG0_LOC             0x08    /* loss of clock */
-
-/*
- * Framer register 9 contains the blue alarm signal
- */
-#define LMC_FRAMER_REG9_RBLUE          0x02     /* Blue alarm failure =
*/
-
-/*
- * Framer register 0x10 contains xbit error
- */
-#define LMC_FRAMER_REG10_XBIT          0x01     /* X bit error alarm f=
ailure */
-
-/*
- * And SSI, LMC1000
- */
-#define LMC_MII16_SSI_DTR	0x0001	/* DTR output RW */
-#define LMC_MII16_SSI_DSR	0x0002	/* DSR input RO */
-#define LMC_MII16_SSI_RTS	0x0004	/* RTS output RW */
-#define LMC_MII16_SSI_CTS	0x0008	/* CTS input RO */
-#define LMC_MII16_SSI_DCD	0x0010	/* DCD input RO */
-#define LMC_MII16_SSI_RI		0x0020	/* RI input RO */
-#define LMC_MII16_SSI_CRC                0x1000  /* CRC select - RW */
-
-/*
- * bits 0x0080 through 0x0800 are generic, and described
- * above with LMC_MII16_LED[0123] _LED_ALL, and _FIFO_RESET
- */
-#define LMC_MII16_SSI_LL		0x1000	/* LL output RW */
-#define LMC_MII16_SSI_RL		0x2000	/* RL output RW */
-#define LMC_MII16_SSI_TM		0x4000	/* TM input RO */
-#define LMC_MII16_SSI_LOOP	0x8000	/* loopback enable RW */
-
-/*
- * Some of the MII16 bits are mirrored in the MII17 register as well,
- * but let's keep thing separate for now, and get only the cable from
- * the MII17.
- */
-#define LMC_MII17_SSI_CABLE_MASK	0x0038	/* mask to extract the cable t=
ype */
-#define LMC_MII17_SSI_CABLE_SHIFT 3	/* shift to extract the cable type=
 */
+   in Xilinx code for DS3 & DS1 adapters */
+#define LMC_DS3_LED0		0x0100 /* bit 08 yellow */
+#define LMC_DS3_LED1		0x0080 /* bit 07 blue   */
+#define LMC_DS3_LED2		0x0400 /* bit 10 green  */
+#define LMC_DS3_LED3		0x0200 /* bit 09 red    */
+
+/* framer register 0 and 7 (7 is latched and reset on read) */
+#define LMC_FRAMER_REG0_DLOS	0x80 /* digital loss of service */
+#define LMC_FRAMER_REG0_OOFS	0x40 /* out of frame sync */
+#define LMC_FRAMER_REG0_AIS	0x20 /* alarm indication signal */
+#define LMC_FRAMER_REG0_CIS	0x10 /* channel idle */
+#define LMC_FRAMER_REG0_LOC	0x08 /* loss of clock */
+
+/* Framer register 9 contains the blue alarm signal */
+#define LMC_FRAMER_REG9_RBLUE	0x02 /* Blue alarm failure */
+
+/* Framer register 0x10 contains xbit error */
+#define LMC_FRAMER_REG10_XBIT	0x01 /* X bit error alarm failure */
+
+/* And SSI, LMC1000 */
+#define LMC_MII16_SSI_DTR	0x0001 /* DTR output RW */
+#define LMC_MII16_SSI_DSR	0x0002 /* DSR input RO */
+#define LMC_MII16_SSI_RTS	0x0004 /* RTS output RW */
+#define LMC_MII16_SSI_CTS	0x0008 /* CTS input RO */
+#define LMC_MII16_SSI_DCD	0x0010 /* DCD input RO */
+#define LMC_MII16_SSI_RI	0x0020 /* RI input RO */
+#define LMC_MII16_SSI_CRC	0x1000 /* CRC select - RW */
+
+/* bits 0x0080 through 0x0800 are generic, and described
+   above with LMC_MII16_LED[0123] _LED_ALL, and _FIFO_RESET */
+#define LMC_MII16_SSI_LL	0x1000 /* LL output RW */
+#define LMC_MII16_SSI_RL	0x2000 /* RL output RW */
+#define LMC_MII16_SSI_TM	0x4000 /* TM input RO */
+#define LMC_MII16_SSI_LOOP	0x8000 /* loopback enable RW */
+
+/* Some of the MII16 bits are mirrored in the MII17 register as well,
+   but let's keep thing separate for now, and get only the cable from
+   the MII17. */
+#define LMC_MII17_SSI_CABLE_MASK	0x0038 /* mask to extract the cable t=
ype */
+#define LMC_MII17_SSI_CABLE_SHIFT	3 /* shift to extract the cable type=
 */
=20
 /*
  * And T1, LMC1200
  */
-#define LMC_MII16_T1_UNUSED1    0x0003
-#define LMC_MII16_T1_XOE                0x0004
-#define LMC_MII16_T1_RST                0x0008  /* T1 chip reset - RW =
*/
-#define LMC_MII16_T1_Z                  0x0010  /* output impedance T1=
=3D1, E1=3D0 output - RW */
-#define LMC_MII16_T1_INTR               0x0020  /* interrupt from 8370=
 - RO */
-#define LMC_MII16_T1_ONESEC             0x0040  /* one second square w=
ave - ro */
+#define LMC_MII16_T1_UNUSED1	0x0003
+#define LMC_MII16_T1_XOE	0x0004
+#define LMC_MII16_T1_RST	0x0008 /* T1 chip reset - RW */
+#define LMC_MII16_T1_Z		0x0010 /* output impedance T1=3D1, E1=3D0 outp=
ut - RW */
+#define LMC_MII16_T1_INTR	0x0020 /* interrupt from 8370 - RO */
+#define LMC_MII16_T1_ONESEC	0x0040 /* one second square wave - ro */
=20
-#define LMC_MII16_T1_LED0               0x0100
-#define LMC_MII16_T1_LED1               0x0080
-#define LMC_MII16_T1_LED2               0x0400
-#define LMC_MII16_T1_LED3               0x0200
-#define LMC_MII16_T1_FIFO_RESET 0x0800
+#define LMC_MII16_T1_LED0	0x0100
+#define LMC_MII16_T1_LED1	0x0080
+#define LMC_MII16_T1_LED2	0x0400
+#define LMC_MII16_T1_LED3	0x0200
+#define LMC_MII16_T1_FIFO_RESET	0x0800
=20
-#define LMC_MII16_T1_CRC                0x1000  /* CRC select - RW */
-#define LMC_MII16_T1_UNUSED2    0xe000
+#define LMC_MII16_T1_CRC	0x1000 /* CRC select - RW */
+#define LMC_MII16_T1_UNUSED2	0xe000
=20
=20
-/* 8370 framer registers  */
+/* 8370 framer registers */
=20
-#define T1FRAMER_ALARM1_STATUS  0x47
-#define T1FRAMER_ALARM2_STATUS  0x48
-#define T1FRAMER_FERR_LSB               0x50
-#define T1FRAMER_FERR_MSB               0x51    /* framing bit error c=
ounter */
-#define T1FRAMER_LCV_LSB                0x54
-#define T1FRAMER_LCV_MSB                0x55    /* line code violation=
 counter */
-#define T1FRAMER_AERR                   0x5A
+#define T1FRAMER_ALARM1_STATUS	0x47
+#define T1FRAMER_ALARM2_STATUS	0x48
+#define T1FRAMER_FERR_LSB	0x50
+#define T1FRAMER_FERR_MSB	0x51 /* framing bit error counter */
+#define T1FRAMER_LCV_LSB	0x54
+#define T1FRAMER_LCV_MSB	0x55 /* line code violation counter */
+#define T1FRAMER_AERR		0x5A
=20
 /* mask for the above AERR register */
-#define T1FRAMER_LOF_MASK               (0x0f0) /* receive loss of fra=
me */
-#define T1FRAMER_COFA_MASK              (0x0c0) /* change of frame ali=
gnment */
-#define T1FRAMER_SEF_MASK               (0x03)  /* severely errored fr=
ame  */
+#define T1FRAMER_LOF_MASK	(0x0f0) /* receive loss of frame */
+#define T1FRAMER_COFA_MASK	(0x0c0) /* change of frame alignment */
+#define T1FRAMER_SEF_MASK	(0x03)/* severely errored frame  */
=20
 /* 8370 framer register ALM1 (0x47) values
  * used to determine link status
  */
=20
-#define T1F_SIGFRZ      0x01    /* signaling freeze */
-#define T1F_RLOF        0x02    /* receive loss of frame alignment */
-#define T1F_RLOS        0x04    /* receive loss of signal */
-#define T1F_RALOS       0x08    /* receive analog loss of signal or RC=
KI loss of clock */
-#define T1F_RAIS        0x10    /* receive alarm indication signal */
-#define T1F_UNUSED      0x20
-#define T1F_RYEL        0x40    /* receive yellow alarm */
-#define T1F_RMYEL       0x80    /* receive multiframe yellow alarm */
+#define T1F_SIGFRZ	0x01 /* signaling freeze */
+#define T1F_RLOF	0x02 /* receive loss of frame alignment */
+#define T1F_RLOS	0x04 /* receive loss of signal */
+#define T1F_RALOS	0x08 /* receive analog loss of signal or RCKI loss o=
f clock */
+#define T1F_RAIS	0x10 /* receive alarm indication signal */
+#define T1F_UNUSED	0x20
+#define T1F_RYEL	0x40 /* receive yellow alarm */
+#define T1F_RMYEL	0x80 /* receive multiframe yellow alarm */
=20
-#define LMC_T1F_WRITE       0
-#define LMC_T1F_READ        1
+#define LMC_T1F_WRITE	0
+#define LMC_T1F_READ	1
=20
 typedef struct lmc_st1f_control {
-  int command;
-  int address;
-  int value;
-  char __user *data;
+	int command;
+	int address;
+	int value;
+	char __user *data;
 } lmc_t1f_control;
=20
 enum lmc_xilinx_c {
-    lmc_xilinx_reset =3D 1,
-    lmc_xilinx_load_prom =3D 2,
-    lmc_xilinx_load =3D 3
+	lmc_xilinx_reset =3D 1,
+	lmc_xilinx_load_prom =3D 2,
+	lmc_xilinx_load =3D 3
 };
=20
 struct lmc_xilinx_control {
-    enum lmc_xilinx_c command;
-    int len;
-    char __user *data;
+	enum lmc_xilinx_c command;
+	int len;
+	char __user *data;
 };
=20
 /* ------------------ end T1 defs ------------------- */
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_m=
ain.c
index e2c6f7f..3c7f23a 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1,41 +1,41 @@
- /*
-  * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
-  * All rights reserved.  www.lanmedia.com
-  * Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.=
pl>
-  *
-  * This code is written by:
-  * Andrew Stanley-Jones (asj@cban.com)
-  * Rob Braun (bbraun@vix.com),
-  * Michael Graff (explorer@vix.com) and
-  * Matt Thomas (matt@3am-software.com).
-  *
-  * With Help By:
-  * David Boggs
-  * Ron Crane
-  * Alan Cox
-  *
-  * This software may be used and distributed according to the terms
-  * of the GNU General Public License version 2, incorporated herein b=
y reference.
-  *
-  * Driver for the LanMedia LMC5200, LMC5245, LMC1000, LMC1200 cards.
-  *
-  * To control link specific options lmcctl is required.
-  * It can be obtained from ftp.lanmedia.com.
-  *
-  * Linux driver notes:
-  * Linux uses the device struct lmc_private to pass private informati=
on
-  * arround.
-  *
-  * The initialization portion of this driver (the lmc_reset() and the
-  * lmc_dec_reset() functions, as well as the led controls and the
-  * lmc_initcsrs() functions.
-  *
-  * The watchdog function runs every second and checks to see if
-  * we still have link, and that the timing source is what we expected
-  * it to be.  If link is lost, the interface is marked down, and
-  * we no longer can transmit.
-  *
-  */
+/*
+ * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
+ * All rights reserved.  www.lanmedia.com
+ * Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.p=
l>
+ *
+ * This code is written by:
+ * Andrew Stanley-Jones (asj@cban.com)
+ * Rob Braun (bbraun@vix.com),
+ * Michael Graff (explorer@vix.com) and
+ * Matt Thomas (matt@3am-software.com).
+ *
+ * With Help By:
+ * David Boggs
+ * Ron Crane
+ * Alan Cox
+ *
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License version 2, incorporated herein by re=
ference.
+ *
+ * Driver for the LanMedia LMC5200, LMC5245, LMC1000, LMC1200 cards.
+ *
+ * To control link specific options lmcctl is required.
+ * It can be obtained from ftp.lanmedia.com.
+ *
+ * Linux driver notes:
+ * Linux uses the device struct lmc_private to pass private informatio=
n
+ * arround.
+ *
+ * The initialization portion of this driver (the lmc_reset() and the
+ * lmc_dec_reset() functions, as well as the led controls and the
+ * lmc_initcsrs() functions.
+ *
+ * The watchdog function runs every second and checks to see if
+ * we still have link, and that the timing source is what we expected
+ * it to be.  If link is lost, the interface is marked down, and
+ * we no longer can transmit.
+ *
+ */
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -56,12 +56,11 @@
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/inet.h>
+#include <linux/io.h>
 #include <linux/bitops.h>
-#include <asm/processor.h>             /* Processor type for cache ali=
gnment. */
-#include <asm/io.h>
+#include <linux/uaccess.h>
+#include <asm/processor.h>   /* Processor type for cache alignment. */
 #include <asm/dma.h>
-#include <asm/uaccess.h>
-//#include <asm/spinlock.h>
=20
 #define DRIVER_MAJOR_VERSION     1
 #define DRIVER_MINOR_VERSION    34
@@ -88,15 +87,15 @@ static DEFINE_PCI_DEVICE_TABLE(lmc_pci_tbl) =3D {
 MODULE_DEVICE_TABLE(pci, lmc_pci_tbl);
 MODULE_LICENSE("GPL v2");
=20
-
 static netdev_tx_t lmc_start_xmit(struct sk_buff *skb,
 					struct net_device *dev);
-static int lmc_rx (struct net_device *dev);
+static int lmc_rx(struct net_device *dev);
 static int lmc_open(struct net_device *dev);
 static int lmc_close(struct net_device *dev);
 static struct net_device_stats *lmc_get_stats(struct net_device *dev);
 static irqreturn_t lmc_interrupt(int irq, void *dev_instance);
-static void lmc_initcsrs(lmc_softc_t * const sc, lmc_csrptr_t csr_base=
, size_t csr_size);
+static void lmc_initcsrs(lmc_softc_t * const sc, lmc_csrptr_t csr_base=
,
+			 size_t csr_size);
 static void lmc_softreset(lmc_softc_t * const);
 static void lmc_running_reset(struct net_device *dev);
 static int lmc_ifdown(struct net_device * const);
@@ -105,698 +104,652 @@ static void lmc_reset(lmc_softc_t * const sc);
 static void lmc_dec_reset(lmc_softc_t * const sc);
 static void lmc_driver_timeout(struct net_device *dev);
=20
-/*
- * linux reserves 16 device specific IOCTLs.  We call them
- * LMCIOC* to control various bits of our world.
- */
-int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fo=
ld00*/
+/* linux reserves 16 device specific IOCTLs.  We call them
+   LMCIOC* to control various bits of our world. */
+int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-    lmc_softc_t *sc =3D dev_to_sc(dev);
-    lmc_ctl_t ctl;
-    int ret =3D -EOPNOTSUPP;
-    u16 regVal;
-    unsigned long flags;
-
-    lmc_trace(dev, "lmc_ioctl in");
-
-    /*
-     * Most functions mess with the structure
-     * Disable interrupts while we do the polling
-     */
-
-    switch (cmd) {
-        /*
-         * Return current driver state.  Since we keep this up
-         * To date internally, just copy this out to the user.
-         */
-    case LMCIOCGINFO: /*fold01*/
-	if (copy_to_user(ifr->ifr_data, &sc->ictl, sizeof(lmc_ctl_t)))
-		ret =3D -EFAULT;
-	else
+	lmc_softc_t *sc =3D dev_to_sc(dev);
+	lmc_ctl_t ctl;
+	int ret =3D -EOPNOTSUPP;
+	u16 regVal;
+	unsigned long flags;
+
+	lmc_trace(dev, "lmc_ioctl in");
+
+	/* Most functions mess with the structure
+	   Disable interrupts while we do the polling */
+
+	switch (cmd) {
+		/* Return current driver state.  Since we keep this up
+		   To date internally, just copy this out to the user. */
+	case LMCIOCGINFO:
+		if (copy_to_user(ifr->ifr_data, &sc->ictl, sizeof(lmc_ctl_t)))
+			ret =3D -EFAULT;
+		else
+			ret =3D 0;
+		break;
+
+	case LMCIOCSINFO:
+		if (!capable(CAP_NET_ADMIN)) {
+			ret =3D -EPERM;
+			break;
+		}
+
+		if (dev->flags & IFF_UP) {
+			ret =3D -EBUSY;
+			break;
+		}
+
+		if (copy_from_user(&ctl, ifr->ifr_data, sizeof(lmc_ctl_t))) {
+			ret =3D -EFAULT;
+			break;
+		}
+
+		spin_lock_irqsave(&sc->lmc_lock, flags);
+		sc->lmc_media->set_status(sc, &ctl);
+
+		if (ctl.crc_length !=3D sc->ictl.crc_length) {
+			sc->lmc_media->set_crc_length(sc, ctl.crc_length);
+			if (sc->ictl.crc_length =3D=3D LMC_CTL_CRC_LENGTH_16)
+				sc->TxDescriptControlInit |=3D
+					LMC_TDES_ADD_CRC_DISABLE;
+			else
+				sc->TxDescriptControlInit &=3D
+					~LMC_TDES_ADD_CRC_DISABLE;
+		}
+		spin_unlock_irqrestore(&sc->lmc_lock, flags);
 		ret =3D 0;
-        break;
+		break;
+
+	case LMCIOCIFTYPE:
+	{
+		u16 old_type =3D sc->if_type;
+		u16 new_type;
+
+		if (!capable(CAP_NET_ADMIN)) {
+			ret =3D -EPERM;
+			break;
+		}
=20
-    case LMCIOCSINFO: /*fold01*/
-        if (!capable(CAP_NET_ADMIN)) {
-            ret =3D -EPERM;
-            break;
-        }
+		if (copy_from_user(&new_type, ifr->ifr_data, sizeof(u16))) {
+			ret =3D -EFAULT;
+			break;
+		}
=20
-        if(dev->flags & IFF_UP){
-            ret =3D -EBUSY;
-            break;
-        }
+		if (new_type =3D=3D old_type) {
+			ret =3D 0 ;
+			break;				/* no change */
+		}
=20
-	if (copy_from_user(&ctl, ifr->ifr_data, sizeof(lmc_ctl_t))) {
-		ret =3D -EFAULT;
+		spin_lock_irqsave(&sc->lmc_lock, flags);
+		lmc_proto_close(sc);
+
+		sc->if_type =3D new_type;
+		lmc_proto_attach(sc);
+		ret =3D lmc_proto_open(sc);
+		spin_unlock_irqrestore(&sc->lmc_lock, flags);
 		break;
 	}
=20
-	spin_lock_irqsave(&sc->lmc_lock, flags);
-        sc->lmc_media->set_status (sc, &ctl);
-
-        if(ctl.crc_length !=3D sc->ictl.crc_length) {
-            sc->lmc_media->set_crc_length(sc, ctl.crc_length);
-	    if (sc->ictl.crc_length =3D=3D LMC_CTL_CRC_LENGTH_16)
-		sc->TxDescriptControlInit |=3D  LMC_TDES_ADD_CRC_DISABLE;
-	    else
-		sc->TxDescriptControlInit &=3D ~LMC_TDES_ADD_CRC_DISABLE;
-        }
-	spin_unlock_irqrestore(&sc->lmc_lock, flags);
+	case LMCIOCGETXINFO:
+		spin_lock_irqsave(&sc->lmc_lock, flags);
+		sc->lmc_xinfo.Magic0 =3D 0xBEEFCAFE;
+
+		sc->lmc_xinfo.PciCardType =3D sc->lmc_cardtype;
+		sc->lmc_xinfo.PciSlotNumber =3D 0;
+		sc->lmc_xinfo.DriverMajorVersion =3D DRIVER_MAJOR_VERSION;
+		sc->lmc_xinfo.DriverMinorVersion =3D DRIVER_MINOR_VERSION;
+		sc->lmc_xinfo.DriverSubVersion =3D DRIVER_SUB_VERSION;
+		sc->lmc_xinfo.XilinxRevisionNumber =3D
+			lmc_mii_readreg(sc, 0, 3) & 0xf;
+		sc->lmc_xinfo.MaxFrameSize =3D LMC_PKT_BUF_SZ;
+		sc->lmc_xinfo.link_status =3D sc->lmc_media->get_link_status(sc);
+		sc->lmc_xinfo.mii_reg16 =3D lmc_mii_readreg(sc, 0, 16);
+		spin_unlock_irqrestore(&sc->lmc_lock, flags);
+
+		sc->lmc_xinfo.Magic1 =3D 0xDEADBEEF;
+
+		if (copy_to_user(ifr->ifr_data, &sc->lmc_xinfo,
+				 sizeof(struct lmc_xinfo)))
+			ret =3D -EFAULT;
+		else
+			ret =3D 0;
+		break;
=20
-        ret =3D 0;
-        break;
+	case LMCIOCGETLMCSTATS:
+		spin_lock_irqsave(&sc->lmc_lock, flags);
+		if (sc->lmc_cardtype =3D=3D LMC_CARDTYPE_T1) {
+			lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_LSB);
+			sc->extra_stats.framingBitErrorCount +=3D
+				lmc_mii_readreg(sc, 0, 18) & 0xff;
+			lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_MSB);
+			sc->extra_stats.framingBitErrorCount +=3D
+				(lmc_mii_readreg(sc, 0, 18) & 0xff) << 8;
+			lmc_mii_writereg(sc, 0, 17, T1FRAMER_LCV_LSB);
+			sc->extra_stats.lineCodeViolationCount +=3D
+				lmc_mii_readreg(sc, 0, 18) & 0xff;
+			lmc_mii_writereg(sc, 0, 17, T1FRAMER_LCV_MSB);
+			sc->extra_stats.lineCodeViolationCount +=3D
+				(lmc_mii_readreg(sc, 0, 18) & 0xff) << 8;
+			lmc_mii_writereg(sc, 0, 17, T1FRAMER_AERR);
+			regVal =3D lmc_mii_readreg(sc, 0, 18) & 0xff;
+
+			sc->extra_stats.lossOfFrameCount +=3D
+				(regVal & T1FRAMER_LOF_MASK) >> 4;
+			sc->extra_stats.changeOfFrameAlignmentCount +=3D
+				(regVal & T1FRAMER_COFA_MASK) >> 2;
+			sc->extra_stats.severelyErroredFrameCount +=3D
+				regVal & T1FRAMER_SEF_MASK;
+		}
+		spin_unlock_irqrestore(&sc->lmc_lock, flags);
+		if (copy_to_user(ifr->ifr_data, &sc->lmc_device->stats,
+				 sizeof(sc->lmc_device->stats)) ||
+		    copy_to_user(ifr->ifr_data + sizeof(sc->lmc_device->stats),
+				 &sc->extra_stats, sizeof(sc->extra_stats)))
+			ret =3D -EFAULT;
+		else
+			ret =3D 0;
+		break;
=20
-    case LMCIOCIFTYPE: /*fold01*/
-        {
-	    u16 old_type =3D sc->if_type;
-	    u16	new_type;
+	case LMCIOCCLEARLMCSTATS:
+		if (!capable(CAP_NET_ADMIN)) {
+			ret =3D -EPERM;
+			break;
+		}
=20
-	    if (!capable(CAP_NET_ADMIN)) {
-		ret =3D -EPERM;
+		spin_lock_irqsave(&sc->lmc_lock, flags);
+		memset(&sc->lmc_device->stats, 0,
+		       sizeof(sc->lmc_device->stats));
+		memset(&sc->extra_stats, 0, sizeof(sc->extra_stats));
+		sc->extra_stats.check =3D STATCHECK;
+		sc->extra_stats.version_size =3D (DRIVER_VERSION << 16) +
+			sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
+		sc->extra_stats.lmc_cardtype =3D sc->lmc_cardtype;
+		spin_unlock_irqrestore(&sc->lmc_lock, flags);
+		ret =3D 0;
 		break;
-	    }
=20
-	    if (copy_from_user(&new_type, ifr->ifr_data, sizeof(u16))) {
-		ret =3D -EFAULT;
-		break;
-	    }
-
-           =20
-	    if (new_type =3D=3D old_type)
-	    {
-		ret =3D 0 ;
-		break;				/* no change */
-            }
-           =20
-	    spin_lock_irqsave(&sc->lmc_lock, flags);
-            lmc_proto_close(sc);
-
-            sc->if_type =3D new_type;
-            lmc_proto_attach(sc);
-	    ret =3D lmc_proto_open(sc);
-	    spin_unlock_irqrestore(&sc->lmc_lock, flags);
-	    break;
-	}
+	case LMCIOCSETCIRCUIT:
+		if (!capable(CAP_NET_ADMIN)) {
+			ret =3D -EPERM;
+			break;
+		}
=20
-    case LMCIOCGETXINFO: /*fold01*/
-	spin_lock_irqsave(&sc->lmc_lock, flags);
-        sc->lmc_xinfo.Magic0 =3D 0xBEEFCAFE;
-
-        sc->lmc_xinfo.PciCardType =3D sc->lmc_cardtype;
-        sc->lmc_xinfo.PciSlotNumber =3D 0;
-        sc->lmc_xinfo.DriverMajorVersion =3D DRIVER_MAJOR_VERSION;
-        sc->lmc_xinfo.DriverMinorVersion =3D DRIVER_MINOR_VERSION;
-        sc->lmc_xinfo.DriverSubVersion =3D DRIVER_SUB_VERSION;
-        sc->lmc_xinfo.XilinxRevisionNumber =3D
-            lmc_mii_readreg (sc, 0, 3) & 0xf;
-        sc->lmc_xinfo.MaxFrameSize =3D LMC_PKT_BUF_SZ;
-        sc->lmc_xinfo.link_status =3D sc->lmc_media->get_link_status (=
sc);
-        sc->lmc_xinfo.mii_reg16 =3D lmc_mii_readreg (sc, 0, 16);
-	spin_unlock_irqrestore(&sc->lmc_lock, flags);
+		if (dev->flags & IFF_UP) {
+			ret =3D -EBUSY;
+			break;
+		}
=20
-        sc->lmc_xinfo.Magic1 =3D 0xDEADBEEF;
+		if (copy_from_user(&ctl, ifr->ifr_data, sizeof(lmc_ctl_t))) {
+			ret =3D -EFAULT;
+			break;
+		}
+		spin_lock_irqsave(&sc->lmc_lock, flags);
+		sc->lmc_media->set_circuit_type(sc, ctl.circuit_type);
+		sc->ictl.circuit_type =3D ctl.circuit_type;
+		spin_unlock_irqrestore(&sc->lmc_lock, flags);
+		ret =3D 0;
+		break;
+
+	case LMCIOCRESET:
+		if (!capable(CAP_NET_ADMIN)) {
+			ret =3D -EPERM;
+			break;
+		}
=20
-        if (copy_to_user(ifr->ifr_data, &sc->lmc_xinfo,
-			 sizeof(struct lmc_xinfo)))
-		ret =3D -EFAULT;
-	else
+		spin_lock_irqsave(&sc->lmc_lock, flags);
+		/* Reset driver and bring back to current state */
+		printk(KERN_DEBUG " REG16 before reset +%04x\n",
+		       lmc_mii_readreg(sc, 0, 16));
+		lmc_running_reset(dev);
+		printk(KERN_DEBUG " REG16 after reset +%04x\n",
+		       lmc_mii_readreg(sc, 0, 16));
+
+		LMC_EVENT_LOG(LMC_EVENT_FORCEDRESET,
+			      LMC_CSR_READ(sc, csr_status),
+			      lmc_mii_readreg(sc, 0, 16));
+		spin_unlock_irqrestore(&sc->lmc_lock, flags);
 		ret =3D 0;
+		break;
+
+#ifdef DEBUG
+	case LMCIOCDUMPEVENTLOG:
+		if (copy_to_user(ifr->ifr_data, &lmcEventLogIndex,
+				 sizeof(u32))) {
+			ret =3D -EFAULT;
+			break;
+		}
+		if (copy_to_user(ifr->ifr_data + sizeof(u32), lmcEventLogBuf,
+				 sizeof(lmcEventLogBuf)))
+			ret =3D -EFAULT;
+		else
+			ret =3D 0;
=20
-        break;
-
-    case LMCIOCGETLMCSTATS:
-	    spin_lock_irqsave(&sc->lmc_lock, flags);
-	    if (sc->lmc_cardtype =3D=3D LMC_CARDTYPE_T1) {
-		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_LSB);
-		    sc->extra_stats.framingBitErrorCount +=3D
-			    lmc_mii_readreg(sc, 0, 18) & 0xff;
-		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_MSB);
-		    sc->extra_stats.framingBitErrorCount +=3D
-			    (lmc_mii_readreg(sc, 0, 18) & 0xff) << 8;
-		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_LCV_LSB);
-		    sc->extra_stats.lineCodeViolationCount +=3D
-			    lmc_mii_readreg(sc, 0, 18) & 0xff;
-		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_LCV_MSB);
-		    sc->extra_stats.lineCodeViolationCount +=3D
-			    (lmc_mii_readreg(sc, 0, 18) & 0xff) << 8;
-		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_AERR);
-		    regVal =3D lmc_mii_readreg(sc, 0, 18) & 0xff;
-
-		    sc->extra_stats.lossOfFrameCount +=3D
-			    (regVal & T1FRAMER_LOF_MASK) >> 4;
-		    sc->extra_stats.changeOfFrameAlignmentCount +=3D
-			    (regVal & T1FRAMER_COFA_MASK) >> 2;
-		    sc->extra_stats.severelyErroredFrameCount +=3D
-			    regVal & T1FRAMER_SEF_MASK;
-	    }
-	    spin_unlock_irqrestore(&sc->lmc_lock, flags);
-	    if (copy_to_user(ifr->ifr_data, &sc->lmc_device->stats,
-			     sizeof(sc->lmc_device->stats)) ||
-		copy_to_user(ifr->ifr_data + sizeof(sc->lmc_device->stats),
-			     &sc->extra_stats, sizeof(sc->extra_stats)))
-		    ret =3D -EFAULT;
-	    else
-		    ret =3D 0;
-	    break;
-
-    case LMCIOCCLEARLMCSTATS:
-	    if (!capable(CAP_NET_ADMIN)) {
-		    ret =3D -EPERM;
-		    break;
-	    }
-
-	    spin_lock_irqsave(&sc->lmc_lock, flags);
-	    memset(&sc->lmc_device->stats, 0, sizeof(sc->lmc_device->stats));
-	    memset(&sc->extra_stats, 0, sizeof(sc->extra_stats));
-	    sc->extra_stats.check =3D STATCHECK;
-	    sc->extra_stats.version_size =3D (DRIVER_VERSION << 16) +
-		    sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
-	    sc->extra_stats.lmc_cardtype =3D sc->lmc_cardtype;
-	    spin_unlock_irqrestore(&sc->lmc_lock, flags);
-	    ret =3D 0;
-	    break;
-
-    case LMCIOCSETCIRCUIT: /*fold01*/
-        if (!capable(CAP_NET_ADMIN)){
-            ret =3D -EPERM;
-            break;
-        }
-
-        if(dev->flags & IFF_UP){
-            ret =3D -EBUSY;
-            break;
-        }
-
-	if (copy_from_user(&ctl, ifr->ifr_data, sizeof(lmc_ctl_t))) {
-		ret =3D -EFAULT;
 		break;
-	}
-	spin_lock_irqsave(&sc->lmc_lock, flags);
-        sc->lmc_media->set_circuit_type(sc, ctl.circuit_type);
-        sc->ictl.circuit_type =3D ctl.circuit_type;
-	spin_unlock_irqrestore(&sc->lmc_lock, flags);
-        ret =3D 0;
+#endif /* end ifdef _DBG_EVENTLOG */
+	case LMCIOCT1CONTROL:
+		if (sc->lmc_cardtype !=3D LMC_CARDTYPE_T1) {
+			ret =3D -EOPNOTSUPP;
+			break;
+		}
+		break;
+	case LMCIOCXILINX:
+	{
+		struct lmc_xilinx_control xc;
=20
-        break;
+		if (!capable(CAP_NET_ADMIN)) {
+			ret =3D -EPERM;
+			break;
+		}
=20
-    case LMCIOCRESET: /*fold01*/
-        if (!capable(CAP_NET_ADMIN)){
-            ret =3D -EPERM;
-            break;
-        }
+		/* Stop the xwitter whlie we restart the hardware */
+		netif_stop_queue(dev);
=20
-	spin_lock_irqsave(&sc->lmc_lock, flags);
-        /* Reset driver and bring back to current state */
-        printk (" REG16 before reset +%04x\n", lmc_mii_readreg (sc, 0,=
 16));
-        lmc_running_reset (dev);
-        printk (" REG16 after reset +%04x\n", lmc_mii_readreg (sc, 0, =
16));
+		if (copy_from_user(&xc, ifr->ifr_data,
+				   sizeof(struct lmc_xilinx_control))) {
+			ret =3D -EFAULT;
+			break;
+		}
+		switch (xc.command) {
+		case lmc_xilinx_reset:
+		{
+			u16 mii;
+			spin_lock_irqsave(&sc->lmc_lock, flags);
+			mii =3D lmc_mii_readreg(sc, 0, 16);
+
+			/* Make all of them 0 and make */
+			lmc_gpio_mkinput(sc, 0xff);
+
+			/* make the reset output */
+			lmc_gpio_mkoutput(sc, LMC_GEP_RESET);
+
+			/* RESET low to force configuration.  This also forces
+			   the transmitter clock to be internal, but we expect
+			   to reset that later anyway. */
+
+			sc->lmc_gpio &=3D ~LMC_GEP_RESET;
+			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+			/* hold for more than 10 microseconds */
+			udelay(50);
+
+			sc->lmc_gpio |=3D LMC_GEP_RESET;
+			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+			/* stop driving Xilinx-related signals */
+			lmc_gpio_mkinput(sc, 0xff);
+
+			/* Reset the frammer hardware */
+			sc->lmc_media->set_link_status(sc, 1);
+			sc->lmc_media->set_status(sc, NULL);
+			/* lmc_softreset(sc); */
+
+			{
+				int i;
+				for (i =3D 0; i < 5; i++) {
+					lmc_led_on(sc, LMC_DS3_LED0);
+					mdelay(100);
+					lmc_led_off(sc, LMC_DS3_LED0);
+					lmc_led_on(sc, LMC_DS3_LED1);
+					mdelay(100);
+					lmc_led_off(sc, LMC_DS3_LED1);
+					lmc_led_on(sc, LMC_DS3_LED3);
+					mdelay(100);
+					lmc_led_off(sc, LMC_DS3_LED3);
+					lmc_led_on(sc, LMC_DS3_LED2);
+					mdelay(100);
+					lmc_led_off(sc, LMC_DS3_LED2);
+				}
+			}
+			spin_unlock_irqrestore(&sc->lmc_lock, flags);
+			ret =3D 0x0;
+		}
+		break;
=20
-        LMC_EVENT_LOG(LMC_EVENT_FORCEDRESET, LMC_CSR_READ (sc, csr_sta=
tus), lmc_mii_readreg (sc, 0, 16));
-	spin_unlock_irqrestore(&sc->lmc_lock, flags);
+		case lmc_xilinx_load_prom:
+		{
+			u16 mii;
+			int timeout =3D 500000;
+			spin_lock_irqsave(&sc->lmc_lock, flags);
+			mii =3D lmc_mii_readreg(sc, 0, 16);
=20
-        ret =3D 0;
-        break;
+			/* Make all of them 0 and make input */
+			lmc_gpio_mkinput(sc, 0xff);
=20
-#ifdef DEBUG
-    case LMCIOCDUMPEVENTLOG:
-	if (copy_to_user(ifr->ifr_data, &lmcEventLogIndex, sizeof(u32))) {
-		ret =3D -EFAULT;
+			/* make the reset output */
+			lmc_gpio_mkoutput(sc,  LMC_GEP_DP | LMC_GEP_RESET);
+
+			/* RESET low to force configuration.  This also forces
+			   the transmitter clock to be internal, but we expect
+			   to reset that later anyway. */
+
+			sc->lmc_gpio &=3D ~(LMC_GEP_RESET | LMC_GEP_DP);
+			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+			/* hold for more than 10 microseconds */
+			udelay(50);
+
+			sc->lmc_gpio |=3D LMC_GEP_DP | LMC_GEP_RESET;
+			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+			/* busy wait for the chip to reset */
+			while ((LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) =3D=3D 0 &&
+			       (timeout-- > 0))
+				cpu_relax();
+
+			/* stop driving Xilinx-related signals */
+			lmc_gpio_mkinput(sc, 0xff);
+			spin_unlock_irqrestore(&sc->lmc_lock, flags);
+			ret =3D 0x0;
+			break;
+		}
+
+		case lmc_xilinx_load:
+		{
+			char *data;
+			int pos;
+			int timeout =3D 500000;
+
+			if (!xc.data) {
+				ret =3D -EINVAL;
+				break;
+			}
+
+			data =3D kmalloc(xc.len, GFP_KERNEL);
+			if (!data) {
+				printk(KERN_WARNING
+				       "%s: Failed to allocate memory for copy\n",
+				       dev->name);
+				ret =3D -ENOMEM;
+				break;
+			}
+
+			if (copy_from_user(data, xc.data, xc.len)) {
+				kfree(data);
+				ret =3D -ENOMEM;
+				break;
+			}
+
+			printk(KERN_DEBUG
+			       "%s: Starting load of data Len: %d at 0x%p =3D=3D 0x%p\n",
+			       dev->name, xc.len, xc.data, data);
+
+			spin_lock_irqsave(&sc->lmc_lock, flags);
+			lmc_gpio_mkinput(sc, 0xff);
+
+			/* Clear the Xilinx and start programming from
+			   the DEC */
+
+			/* Set ouput as:
+			   Reset: 0 (active)
+			   DP:    0 (active)
+			   Mode:  1 */
+			sc->lmc_gpio =3D 0x00;
+			sc->lmc_gpio &=3D ~LMC_GEP_DP;
+			sc->lmc_gpio &=3D ~LMC_GEP_RESET;
+			sc->lmc_gpio |=3D  LMC_GEP_MODE;
+			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+			lmc_gpio_mkoutput(sc, LMC_GEP_MODE | LMC_GEP_DP |
+					  LMC_GEP_RESET);
+
+			/*
+			 * Wait at least 10 us 20 to be safe
+			 */
+			udelay(50);
+
+			/*
+			 * Clear reset and activate programming lines
+			 * Reset: Input
+			 * DP:    Input
+			 * Clock: Output
+			 * Data:  Output
+			 * Mode:  Output
+			 */
+			lmc_gpio_mkinput(sc, LMC_GEP_DP | LMC_GEP_RESET);
+
+			/*
+			 * Set LOAD, DATA, Clock to 1
+			 */
+			sc->lmc_gpio =3D 0x00;
+			sc->lmc_gpio |=3D LMC_GEP_MODE;
+			sc->lmc_gpio |=3D LMC_GEP_DATA;
+			sc->lmc_gpio |=3D LMC_GEP_CLK;
+			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+			lmc_gpio_mkoutput(sc, LMC_GEP_DATA | LMC_GEP_CLK |
+					  LMC_GEP_MODE);
+
+			/* busy wait for the chip to reset */
+			while ((LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) =3D=3D 0 &&
+			       (timeout-- > 0))
+				cpu_relax();
+
+			printk(KERN_DEBUG
+			       "%s: Waited %d for the Xilinx to clear it's memory\n",
+			       dev->name, 500000-timeout);
+
+			for (pos =3D 0; pos < xc.len; pos++) {
+				switch (data[pos]) {
+				case 0:
+					/* Data is 0 */
+					sc->lmc_gpio &=3D ~LMC_GEP_DATA;
+					break;
+				case 1:
+					/* Data is 1 */
+					sc->lmc_gpio |=3D LMC_GEP_DATA;
+					break;
+				default:
+					printk(KERN_WARNING
+					       "%s Bad data in xilinx programming data at %d, got %d want=
ed 0 or 1\n",
+					       dev->name, pos, data[pos]);
+					/* Assume it's 1 */
+					sc->lmc_gpio |=3D LMC_GEP_DATA;
+				}
+				/* Clock to zero */
+				sc->lmc_gpio &=3D ~LMC_GEP_CLK;
+				sc->lmc_gpio |=3D LMC_GEP_MODE;
+				LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+				udelay(1);
+
+				/* Put the clack back to one */
+				sc->lmc_gpio |=3D LMC_GEP_CLK;
+				sc->lmc_gpio |=3D LMC_GEP_MODE;
+				LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+				udelay(1);
+			}
+			if ((LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) =3D=3D 0) {
+				printk(KERN_WARNING
+				       "%s: Reprogramming FAILED. Needs to be reprogrammed. (corru=
pted data)\n",
+				       dev->name);
+			} else if ((LMC_CSR_READ(sc, csr_gp) &
+				    LMC_GEP_DP) =3D=3D 0){
+				printk(KERN_WARNING "%s: Reprogramming FAILED. Needs to be reprogr=
ammed. (done)\n",
+				       dev->name);
+			} else
+				printk(KERN_DEBUG
+				       "%s: Done reprogramming Xilinx, %d bits, good luck!\n",
+				       dev->name, pos);
+
+			lmc_gpio_mkinput(sc, 0xff);
+
+			sc->lmc_miireg16 |=3D LMC_MII16_FIFO_RESET;
+			lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+
+			sc->lmc_miireg16 &=3D ~LMC_MII16_FIFO_RESET;
+			lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+			spin_unlock_irqrestore(&sc->lmc_lock, flags);
+
+			kfree(data);
+			ret =3D 0;
+			break;
+		}
+		default:
+			ret =3D -EBADE;
+			break;
+		}
+
+		netif_wake_queue(dev);
+		sc->lmc_txfull =3D 0;
+	}
+	break;
+	default:
+		/* If we don't know what to do, give the protocol a shot. */
+		ret =3D lmc_proto_ioctl(sc, ifr, cmd);
 		break;
 	}
-	if (copy_to_user(ifr->ifr_data + sizeof(u32), lmcEventLogBuf,
-			 sizeof(lmcEventLogBuf)))
-		ret =3D -EFAULT;
-	else
-		ret =3D 0;
=20
-        break;
-#endif /* end ifdef _DBG_EVENTLOG */
-    case LMCIOCT1CONTROL: /*fold01*/
-        if (sc->lmc_cardtype !=3D LMC_CARDTYPE_T1){
-            ret =3D -EOPNOTSUPP;
-            break;
-        }
-        break;
-    case LMCIOCXILINX: /*fold01*/
-        {
-            struct lmc_xilinx_control xc; /*fold02*/
-
-            if (!capable(CAP_NET_ADMIN)){
-                ret =3D -EPERM;
-                break;
-            }
-
-            /*
-             * Stop the xwitter whlie we restart the hardware
-             */
-            netif_stop_queue(dev);
-
-	    if (copy_from_user(&xc, ifr->ifr_data, sizeof(struct lmc_xilinx_c=
ontrol))) {
-		ret =3D -EFAULT;
-		break;
-	    }
-            switch(xc.command){
-            case lmc_xilinx_reset: /*fold02*/
-                {
-                    u16 mii;
-		    spin_lock_irqsave(&sc->lmc_lock, flags);
-                    mii =3D lmc_mii_readreg (sc, 0, 16);
-
-                    /*
-                     * Make all of them 0 and make input
-                     */
-                    lmc_gpio_mkinput(sc, 0xff);
-
-                    /*
-                     * make the reset output
-                     */
-                    lmc_gpio_mkoutput(sc, LMC_GEP_RESET);
-
-                    /*
-                     * RESET low to force configuration.  This also fo=
rces
-                     * the transmitter clock to be internal, but we ex=
pect to reset
-                     * that later anyway.
-                     */
-
-                    sc->lmc_gpio &=3D ~LMC_GEP_RESET;
-                    LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-
-
-                    /*
-                     * hold for more than 10 microseconds
-                     */
-                    udelay(50);
-
-                    sc->lmc_gpio |=3D LMC_GEP_RESET;
-                    LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-
-
-                    /*
-                     * stop driving Xilinx-related signals
-                     */
-                    lmc_gpio_mkinput(sc, 0xff);
-
-                    /* Reset the frammer hardware */
-                    sc->lmc_media->set_link_status (sc, 1);
-                    sc->lmc_media->set_status (sc, NULL);
-//                    lmc_softreset(sc);
-
-                    {
-                        int i;
-                        for(i =3D 0; i < 5; i++){
-                            lmc_led_on(sc, LMC_DS3_LED0);
-                            mdelay(100);
-                            lmc_led_off(sc, LMC_DS3_LED0);
-                            lmc_led_on(sc, LMC_DS3_LED1);
-                            mdelay(100);
-                            lmc_led_off(sc, LMC_DS3_LED1);
-                            lmc_led_on(sc, LMC_DS3_LED3);
-                            mdelay(100);
-                            lmc_led_off(sc, LMC_DS3_LED3);
-                            lmc_led_on(sc, LMC_DS3_LED2);
-                            mdelay(100);
-                            lmc_led_off(sc, LMC_DS3_LED2);
-                        }
-                    }
-		    spin_unlock_irqrestore(&sc->lmc_lock, flags);
-                   =20
-                   =20
-
-                    ret =3D 0x0;
-
-                }
-
-                break;
-            case lmc_xilinx_load_prom: /*fold02*/
-                {
-                    u16 mii;
-                    int timeout =3D 500000;
-		    spin_lock_irqsave(&sc->lmc_lock, flags);
-                    mii =3D lmc_mii_readreg (sc, 0, 16);
-
-                    /*
-                     * Make all of them 0 and make input
-                     */
-                    lmc_gpio_mkinput(sc, 0xff);
-
-                    /*
-                     * make the reset output
-                     */
-                    lmc_gpio_mkoutput(sc,  LMC_GEP_DP | LMC_GEP_RESET)=
;
-
-                    /*
-                     * RESET low to force configuration.  This also fo=
rces
-                     * the transmitter clock to be internal, but we ex=
pect to reset
-                     * that later anyway.
-                     */
-
-                    sc->lmc_gpio &=3D ~(LMC_GEP_RESET | LMC_GEP_DP);
-                    LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-
-
-                    /*
-                     * hold for more than 10 microseconds
-                     */
-                    udelay(50);
-
-                    sc->lmc_gpio |=3D LMC_GEP_DP | LMC_GEP_RESET;
-                    LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-
-                    /*
-                     * busy wait for the chip to reset
-                     */
-                    while( (LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) =3D=
=3D 0 &&
-                           (timeout-- > 0))
-                        cpu_relax();
-
-
-                    /*
-                     * stop driving Xilinx-related signals
-                     */
-                    lmc_gpio_mkinput(sc, 0xff);
-		    spin_unlock_irqrestore(&sc->lmc_lock, flags);
-
-                    ret =3D 0x0;
-                   =20
-
-                    break;
-
-                }
-
-            case lmc_xilinx_load: /*fold02*/
-                {
-                    char *data;
-                    int pos;
-                    int timeout =3D 500000;
-
-                    if (!xc.data) {
-                            ret =3D -EINVAL;
-                            break;
-                    }
-
-                    data =3D kmalloc(xc.len, GFP_KERNEL);
-                    if (!data) {
-                            printk(KERN_WARNING "%s: Failed to allocat=
e memory for copy\n", dev->name);
-                            ret =3D -ENOMEM;
-                            break;
-                    }
-                   =20
-                    if(copy_from_user(data, xc.data, xc.len))
-                    {
-                    	kfree(data);
-                    	ret =3D -ENOMEM;
-                    	break;
-                    }
-
-                    printk("%s: Starting load of data Len: %d at 0x%p =
=3D=3D 0x%p\n", dev->name, xc.len, xc.data, data);
-
-		    spin_lock_irqsave(&sc->lmc_lock, flags);
-                    lmc_gpio_mkinput(sc, 0xff);
-
-                    /*
-                     * Clear the Xilinx and start prgramming from the =
DEC
-                     */
-
-                    /*
-                     * Set ouput as:
-                     * Reset: 0 (active)
-                     * DP:    0 (active)
-                     * Mode:  1
-                     *
-                     */
-                    sc->lmc_gpio =3D 0x00;
-                    sc->lmc_gpio &=3D ~LMC_GEP_DP;
-                    sc->lmc_gpio &=3D ~LMC_GEP_RESET;
-                    sc->lmc_gpio |=3D  LMC_GEP_MODE;
-                    LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-
-                    lmc_gpio_mkoutput(sc, LMC_GEP_MODE | LMC_GEP_DP | =
LMC_GEP_RESET);
-
-                    /*
-                     * Wait at least 10 us 20 to be safe
-                     */
-                    udelay(50);
-
-                    /*
-                     * Clear reset and activate programming lines
-                     * Reset: Input
-                     * DP:    Input
-                     * Clock: Output
-                     * Data:  Output
-                     * Mode:  Output
-                     */
-                    lmc_gpio_mkinput(sc, LMC_GEP_DP | LMC_GEP_RESET);
-
-                    /*
-                     * Set LOAD, DATA, Clock to 1
-                     */
-                    sc->lmc_gpio =3D 0x00;
-                    sc->lmc_gpio |=3D LMC_GEP_MODE;
-                    sc->lmc_gpio |=3D LMC_GEP_DATA;
-                    sc->lmc_gpio |=3D LMC_GEP_CLK;
-                    LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-                   =20
-                    lmc_gpio_mkoutput(sc, LMC_GEP_DATA | LMC_GEP_CLK |=
 LMC_GEP_MODE );
-
-                    /*
-                     * busy wait for the chip to reset
-                     */
-                    while( (LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) =3D=
=3D 0 &&
-                           (timeout-- > 0))
-                        cpu_relax();
-
-                    printk(KERN_DEBUG "%s: Waited %d for the Xilinx to=
 clear it's memory\n", dev->name, 500000-timeout);
-
-                    for(pos =3D 0; pos < xc.len; pos++){
-                        switch(data[pos]){
-                        case 0:
-                            sc->lmc_gpio &=3D ~LMC_GEP_DATA; /* Data i=
s 0 */
-                            break;
-                        case 1:
-                            sc->lmc_gpio |=3D LMC_GEP_DATA; /* Data is=
 1 */
-                            break;
-                        default:
-                            printk(KERN_WARNING "%s Bad data in xilinx=
 programming data at %d, got %d wanted 0 or 1\n", dev->name, pos, data[=
pos]);
-                            sc->lmc_gpio |=3D LMC_GEP_DATA; /* Assume =
it's 1 */
-                        }
-                        sc->lmc_gpio &=3D ~LMC_GEP_CLK; /* Clock to ze=
ro */
-                        sc->lmc_gpio |=3D LMC_GEP_MODE;
-                        LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-                        udelay(1);
-                       =20
-                        sc->lmc_gpio |=3D LMC_GEP_CLK; /* Put the clac=
k back to one */
-                        sc->lmc_gpio |=3D LMC_GEP_MODE;
-                        LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-                        udelay(1);
-                    }
-                    if((LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) =3D=3D=
 0){
-                        printk(KERN_WARNING "%s: Reprogramming FAILED.=
 Needs to be reprogrammed. (corrupted data)\n", dev->name);
-                    }
-                    else if((LMC_CSR_READ(sc, csr_gp) & LMC_GEP_DP) =3D=
=3D 0){
-                        printk(KERN_WARNING "%s: Reprogramming FAILED.=
 Needs to be reprogrammed. (done)\n", dev->name);
-                    }
-                    else {
-                        printk(KERN_DEBUG "%s: Done reprogramming Xili=
nx, %d bits, good luck!\n", dev->name, pos);
-                    }
-
-                    lmc_gpio_mkinput(sc, 0xff);
-                   =20
-                    sc->lmc_miireg16 |=3D LMC_MII16_FIFO_RESET;
-                    lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-
-                    sc->lmc_miireg16 &=3D ~LMC_MII16_FIFO_RESET;
-                    lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-		    spin_unlock_irqrestore(&sc->lmc_lock, flags);
-
-                    kfree(data);
-                   =20
-                    ret =3D 0;
-                   =20
-                    break;
-                }
-            default: /*fold02*/
-                ret =3D -EBADE;
-                break;
-            }
-
-            netif_wake_queue(dev);
-            sc->lmc_txfull =3D 0;
-
-        }
-        break;
-    default: /*fold01*/
-        /* If we don't know what to do, give the protocol a shot. */
-        ret =3D lmc_proto_ioctl (sc, ifr, cmd);
-        break;
-    }
-
-    lmc_trace(dev, "lmc_ioctl out");
-
-    return ret;
+	lmc_trace(dev, "lmc_ioctl out");
+	return ret;
 }
=20
=20
 /* the watchdog process that cruises around */
-static void lmc_watchdog (unsigned long data) /*fold00*/
+static void lmc_watchdog(unsigned long data)
 {
-    struct net_device *dev =3D (struct net_device *)data;
-    lmc_softc_t *sc =3D dev_to_sc(dev);
-    int link_status;
-    u32 ticks;
-    unsigned long flags;
+	struct net_device *dev =3D (struct net_device *)data;
+	lmc_softc_t *sc =3D dev_to_sc(dev);
+	int link_status;
+	u32 ticks;
+	unsigned long flags;
=20
-    lmc_trace(dev, "lmc_watchdog in");
+	lmc_trace(dev, "lmc_watchdog in");
=20
-    spin_lock_irqsave(&sc->lmc_lock, flags);
+	spin_lock_irqsave(&sc->lmc_lock, flags);
=20
-    if(sc->check !=3D 0xBEAFCAFE){
-        printk("LMC: Corrupt net_device struct, breaking out\n");
-	spin_unlock_irqrestore(&sc->lmc_lock, flags);
-        return;
-    }
-
-
-    /* Make sure the tx jabber and rx watchdog are off,
-     * and the transmit and receive processes are running.
-     */
-
-    LMC_CSR_WRITE (sc, csr_15, 0x00000011);
-    sc->lmc_cmdmode |=3D TULIP_CMD_TXRUN | TULIP_CMD_RXRUN;
-    LMC_CSR_WRITE (sc, csr_command, sc->lmc_cmdmode);
-
-    if (sc->lmc_ok =3D=3D 0)
-        goto kick_timer;
-
-    LMC_EVENT_LOG(LMC_EVENT_WATCHDOG, LMC_CSR_READ (sc, csr_status), l=
mc_mii_readreg (sc, 0, 16));
-
-    /* --- begin time out check -----------------------------------
-     * check for a transmit interrupt timeout
-     * Has the packet xmt vs xmt serviced threshold been exceeded */
-    if (sc->lmc_taint_tx =3D=3D sc->lastlmc_taint_tx &&
-	sc->lmc_device->stats.tx_packets > sc->lasttx_packets &&
-	sc->tx_TimeoutInd =3D=3D 0)
-    {
-
-        /* wait for the watchdog to come around again */
-        sc->tx_TimeoutInd =3D 1;
-    }
-    else if (sc->lmc_taint_tx =3D=3D sc->lastlmc_taint_tx &&
-	     sc->lmc_device->stats.tx_packets > sc->lasttx_packets &&
-	     sc->tx_TimeoutInd)
-    {
-
-        LMC_EVENT_LOG(LMC_EVENT_XMTINTTMO, LMC_CSR_READ (sc, csr_statu=
s), 0);
-
-        sc->tx_TimeoutDisplay =3D 1;
-	sc->extra_stats.tx_TimeoutCnt++;
-
-        /* DEC chip is stuck, hit it with a RESET!!!! */
-        lmc_running_reset (dev);
-
-
-        /* look at receive & transmit process state to make sure they =
are running */
-        LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ (sc, csr_status),=
 0);
-
-        /* look at: DSR - 02  for Reg 16
-         *                  CTS - 08
-         *                  DCD - 10
-         *                  RI  - 20
-         * for Reg 17
-         */
-        LMC_EVENT_LOG(LMC_EVENT_RESET2, lmc_mii_readreg (sc, 0, 16), l=
mc_mii_readreg (sc, 0, 17));
-
-        /* reset the transmit timeout detection flag */
-        sc->tx_TimeoutInd =3D 0;
-        sc->lastlmc_taint_tx =3D sc->lmc_taint_tx;
-	sc->lasttx_packets =3D sc->lmc_device->stats.tx_packets;
-    } else {
-        sc->tx_TimeoutInd =3D 0;
-        sc->lastlmc_taint_tx =3D sc->lmc_taint_tx;
-	sc->lasttx_packets =3D sc->lmc_device->stats.tx_packets;
-    }
-
-    /* --- end time out check ----------------------------------- */
-
-
-    link_status =3D sc->lmc_media->get_link_status (sc);
-
-    /*
-     * hardware level link lost, but the interface is marked as up.
-     * Mark it as down.
-     */
-    if ((link_status =3D=3D 0) && (sc->last_link_status !=3D 0)) {
-        printk(KERN_WARNING "%s: hardware/physical link down\n", dev->=
name);
-        sc->last_link_status =3D 0;
-        /* lmc_reset (sc); Why reset??? The link can go down ok */
-
-        /* Inform the world that link has been lost */
-	netif_carrier_off(dev);
-    }
-
-    /*
-     * hardware link is up, but the interface is marked as down.
-     * Bring it back up again.
-     */
-     if (link_status !=3D 0 && sc->last_link_status =3D=3D 0) {
-         printk(KERN_WARNING "%s: hardware/physical link up\n", dev->n=
ame);
-         sc->last_link_status =3D 1;
-         /* lmc_reset (sc); Again why reset??? */
-
-	 netif_carrier_on(dev);
-     }
-
-    /* Call media specific watchdog functions */
-    sc->lmc_media->watchdog(sc);
-
-    /*
-     * Poke the transmitter to make sure it
-     * never stops, even if we run out of mem
-     */
-    LMC_CSR_WRITE(sc, csr_rxpoll, 0);
-
-    /*
-     * Check for code that failed
-     * and try and fix it as appropriate
-     */
-    if(sc->failed_ring =3D=3D 1){
-        /*
-         * Failed to setup the recv/xmit rin
-         * Try again
-         */
-        sc->failed_ring =3D 0;
-        lmc_softreset(sc);
-    }
-    if(sc->failed_recv_alloc =3D=3D 1){
-        /*
-         * We failed to alloc mem in the
-         * interrupt handler, go through the rings
-         * and rebuild them
-         */
-        sc->failed_recv_alloc =3D 0;
-        lmc_softreset(sc);
-    }
-
-
-    /*
-     * remember the timer value
-     */
-kick_timer:
+	if (sc->check !=3D 0xBEAFCAFE) {
+		printk(KERN_ERR
+		       "LMC: Corrupt net_device struct, breaking out\n");
+		spin_unlock_irqrestore(&sc->lmc_lock, flags);
+		return;
+	}
+
+
+	/* Make sure the tx jabber and rx watchdog are off,
+	 * and the transmit and receive processes are running.
+	 */
+
+	LMC_CSR_WRITE(sc, csr_15, 0x00000011);
+	sc->lmc_cmdmode |=3D TULIP_CMD_TXRUN | TULIP_CMD_RXRUN;
+	LMC_CSR_WRITE(sc, csr_command, sc->lmc_cmdmode);
+
+	if (sc->lmc_ok =3D=3D 0)
+		goto kick_timer;
+
+	LMC_EVENT_LOG(LMC_EVENT_WATCHDOG, LMC_CSR_READ(sc, csr_status),
+		      lmc_mii_readreg(sc, 0, 16));
+
+	/* --- begin time out check -----------------------------------
+	 * check for a transmit interrupt timeout
+	 * Has the packet xmt vs xmt serviced threshold been exceeded */
+	if (sc->lmc_taint_tx =3D=3D sc->lastlmc_taint_tx &&
+	    sc->lmc_device->stats.tx_packets > sc->lasttx_packets &&
+	    sc->tx_TimeoutInd =3D=3D 0) {
+
+		/* wait for the watchdog to come around again */
+		sc->tx_TimeoutInd =3D 1;
+	} else if (sc->lmc_taint_tx =3D=3D sc->lastlmc_taint_tx &&
+		   sc->lmc_device->stats.tx_packets > sc->lasttx_packets &&
+		   sc->tx_TimeoutInd) {
+
+		LMC_EVENT_LOG(LMC_EVENT_XMTINTTMO,
+			      LMC_CSR_READ(sc, csr_status), 0);
+
+		sc->tx_TimeoutDisplay =3D 1;
+		sc->extra_stats.tx_TimeoutCnt++;
+
+		/* DEC chip is stuck, hit it with a RESET!!!! */
+		lmc_running_reset(dev);
+
+
+		/* look at receive & transmit process state to make sure
+		   they are running */
+		LMC_EVENT_LOG(LMC_EVENT_RESET1,
+			      LMC_CSR_READ(sc, csr_status), 0);
+
+		/* look at: DSR - 02  for Reg 16
+		 *          CTS - 08
+		 *          DCD - 10
+		 *          RI  - 20
+		 * for Reg 17
+		 */
+		LMC_EVENT_LOG(LMC_EVENT_RESET2, lmc_mii_readreg(sc, 0, 16),
+			      lmc_mii_readreg(sc, 0, 17));
+
+		/* reset the transmit timeout detection flag */
+		sc->tx_TimeoutInd =3D 0;
+		sc->lastlmc_taint_tx =3D sc->lmc_taint_tx;
+		sc->lasttx_packets =3D sc->lmc_device->stats.tx_packets;
+	} else {
+		sc->tx_TimeoutInd =3D 0;
+		sc->lastlmc_taint_tx =3D sc->lmc_taint_tx;
+		sc->lasttx_packets =3D sc->lmc_device->stats.tx_packets;
+	}
+
+	/* --- end time out check ----------------------------------- */
+
+	link_status =3D sc->lmc_media->get_link_status(sc);
+
+	/* Hardware level link lost, but the interface is marked as up.
+	   Mark it as down. */
+	if ((link_status =3D=3D 0) && (sc->last_link_status !=3D 0)) {
+		printk(KERN_WARNING "%s: hardware/physical link down\n",
+		       dev->name);
+		sc->last_link_status =3D 0;
+		/* lmc_reset(sc); Why reset??? The link can go down ok */
+
+		/* Inform the world that link has been lost */
+		netif_carrier_off(dev);
+	}
+
+	/* Hardware link is up, but the interface is marked as down.
+	   Bring it back up again. */
+	if (link_status !=3D 0 && sc->last_link_status =3D=3D 0) {
+		printk(KERN_WARNING "%s: hardware/physical link up\n",
+		       dev->name);
+		sc->last_link_status =3D 1;
+		/* lmc_reset(sc); Again why reset??? */
+
+		netif_carrier_on(dev);
+	}
+
+	/* Call media specific watchdog functions */
+	sc->lmc_media->watchdog(sc);
+
+	/* Poke the transmitter to make sure it never stops, even if we run
+	   out of mem */
+	LMC_CSR_WRITE(sc, csr_rxpoll, 0);
+
+	/* Check for code that failed and try and fix it as appropriate */
+	if (sc->failed_ring =3D=3D 1) {
+		/* Failed to setup the recv/xmit rin. Try again */
+		sc->failed_ring =3D 0;
+		lmc_softreset(sc);
+	}
=20
-    ticks =3D LMC_CSR_READ (sc, csr_gp_timer);
-    LMC_CSR_WRITE (sc, csr_gp_timer, 0xffffffffUL);
-    sc->ictl.ticks =3D 0x0000ffff - (ticks & 0x0000ffff);
+	if (sc->failed_recv_alloc =3D=3D 1) {
+		/*
+		 * We failed to alloc mem in the
+		 * interrupt handler, go through the rings
+		 * and rebuild them
+		 */
+		sc->failed_recv_alloc =3D 0;
+		lmc_softreset(sc);
+	}
=20
-    /*
-     * restart this timer.
-     */
-    sc->timer.expires =3D jiffies + (HZ);
-    add_timer (&sc->timer);
+	/* remember the timer value */
+kick_timer:
+	ticks =3D LMC_CSR_READ(sc, csr_gp_timer);
+	LMC_CSR_WRITE(sc, csr_gp_timer, 0xffffffffUL);
+	sc->ictl.ticks =3D 0x0000ffff - (ticks & 0x0000ffff);
=20
-    spin_unlock_irqrestore(&sc->lmc_lock, flags);
+	/* restart this timer. */
+	sc->timer.expires =3D jiffies + HZ;
+	add_timer(&sc->timer);
=20
-    lmc_trace(dev, "lmc_watchdog out");
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
=20
+	lmc_trace(dev, "lmc_watchdog out");
 }
=20
 static int lmc_attach(struct net_device *dev, unsigned short encoding,
@@ -893,86 +846,82 @@ static int __devinit lmc_init_one(struct pci_dev =
*pdev,
 		goto err_hdlcdev;
 	}
=20
-    sc->lmc_cardtype =3D LMC_CARDTYPE_UNKNOWN;
-    sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
-
-    /*
-     *
-     * Check either the subvendor or the subdevice, some systems rever=
se
-     * the setting in the bois, seems to be version and arch dependent=
?
-     * Fix the error, exchange the two values=20
-     */
-    if ((subdevice =3D pdev->subsystem_device) =3D=3D PCI_VENDOR_ID_LM=
C)
-	    subdevice =3D pdev->subsystem_vendor;
-
-    switch (subdevice) {
-    case PCI_DEVICE_ID_LMC_HSSI:
-	printk(KERN_INFO "%s: LMC HSSI\n", dev->name);
-        sc->lmc_cardtype =3D LMC_CARDTYPE_HSSI;
-        sc->lmc_media =3D &lmc_hssi_media;
-        break;
-    case PCI_DEVICE_ID_LMC_DS3:
-	printk(KERN_INFO "%s: LMC DS3\n", dev->name);
-        sc->lmc_cardtype =3D LMC_CARDTYPE_DS3;
-        sc->lmc_media =3D &lmc_ds3_media;
-        break;
-    case PCI_DEVICE_ID_LMC_SSI:
-	printk(KERN_INFO "%s: LMC SSI\n", dev->name);
-        sc->lmc_cardtype =3D LMC_CARDTYPE_SSI;
-        sc->lmc_media =3D &lmc_ssi_media;
-        break;
-    case PCI_DEVICE_ID_LMC_T1:
-	printk(KERN_INFO "%s: LMC T1\n", dev->name);
-        sc->lmc_cardtype =3D LMC_CARDTYPE_T1;
-        sc->lmc_media =3D &lmc_t1_media;
-        break;
-    default:
-	printk(KERN_WARNING "%s: LMC UNKNOWN CARD!\n", dev->name);
-        break;
-    }
-
-    lmc_initcsrs (sc, dev->base_addr, 8);
-
-    lmc_gpio_mkinput (sc, 0xff);
-    sc->lmc_gpio =3D 0;		/* drive no signals yet */
-
-    sc->lmc_media->defaults (sc);
-
-    sc->lmc_media->set_link_status (sc, LMC_LINK_UP);
-
-    /* verify that the PCI Sub System ID matches the Adapter Model num=
ber
-     * from the MII register
-     */
-    AdapModelNum =3D (lmc_mii_readreg (sc, 0, 3) & 0x3f0) >> 4;
-
-    if ((AdapModelNum !=3D LMC_ADAP_T1 || /* detect LMC1200 */
-	 subdevice !=3D PCI_DEVICE_ID_LMC_T1) &&
-	(AdapModelNum !=3D LMC_ADAP_SSI || /* detect LMC1000 */
-	 subdevice !=3D PCI_DEVICE_ID_LMC_SSI) &&
-	(AdapModelNum !=3D LMC_ADAP_DS3 || /* detect LMC5245 */
-	 subdevice !=3D PCI_DEVICE_ID_LMC_DS3) &&
-	(AdapModelNum !=3D LMC_ADAP_HSSI || /* detect LMC5200 */
-	 subdevice !=3D PCI_DEVICE_ID_LMC_HSSI))
-	    printk(KERN_WARNING "%s: Model number (%d) miscompare for PCI"
-		   " Subsystem ID =3D 0x%04x\n",
-		   dev->name, AdapModelNum, subdevice);
-
-    /*
-     * reset clock
-     */
-    LMC_CSR_WRITE (sc, csr_gp_timer, 0xFFFFFFFFUL);
-
-    sc->board_idx =3D cards_found++;
-    sc->extra_stats.check =3D STATCHECK;
-    sc->extra_stats.version_size =3D (DRIVER_VERSION << 16) +
-	    sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
-    sc->extra_stats.lmc_cardtype =3D sc->lmc_cardtype;
-
-    sc->lmc_ok =3D 0;
-    sc->last_link_status =3D 0;
-
-    lmc_trace(dev, "lmc_init_one out");
-    return 0;
+	sc->lmc_cardtype =3D LMC_CARDTYPE_UNKNOWN;
+	sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
+
+	/*
+	 * Check either the subvendor or the subdevice, some systems reverse
+	 * the setting in the bois, seems to be version and arch dependent?
+	 * Fix the error, exchange the two values
+	 */
+	if ((subdevice =3D pdev->subsystem_device) =3D=3D PCI_VENDOR_ID_LMC)
+		subdevice =3D pdev->subsystem_vendor;
+
+	switch (subdevice) {
+	case PCI_DEVICE_ID_LMC_HSSI:
+		printk(KERN_INFO "%s: LMC HSSI\n", dev->name);
+		sc->lmc_cardtype =3D LMC_CARDTYPE_HSSI;
+		sc->lmc_media =3D &lmc_hssi_media;
+		break;
+	case PCI_DEVICE_ID_LMC_DS3:
+		printk(KERN_INFO "%s: LMC DS3\n", dev->name);
+		sc->lmc_cardtype =3D LMC_CARDTYPE_DS3;
+		sc->lmc_media =3D &lmc_ds3_media;
+		break;
+	case PCI_DEVICE_ID_LMC_SSI:
+		printk(KERN_INFO "%s: LMC SSI\n", dev->name);
+		sc->lmc_cardtype =3D LMC_CARDTYPE_SSI;
+		sc->lmc_media =3D &lmc_ssi_media;
+		break;
+	case PCI_DEVICE_ID_LMC_T1:
+		printk(KERN_INFO "%s: LMC T1\n", dev->name);
+		sc->lmc_cardtype =3D LMC_CARDTYPE_T1;
+		sc->lmc_media =3D &lmc_t1_media;
+		break;
+	default:
+		printk(KERN_WARNING "%s: LMC UNKNOWN CARD!\n", dev->name);
+		break;
+	}
+
+	lmc_initcsrs(sc, dev->base_addr, 8);
+
+	lmc_gpio_mkinput(sc, 0xff);
+	sc->lmc_gpio =3D 0;		/* drive no signals yet */
+
+	sc->lmc_media->defaults(sc);
+
+	sc->lmc_media->set_link_status(sc, LMC_LINK_UP);
+
+	/* verify that the PCI Sub System ID matches the Adapter Model number
+	   from the MII register */
+	AdapModelNum =3D (lmc_mii_readreg(sc, 0, 3) & 0x3f0) >> 4;
+
+	if ((AdapModelNum !=3D LMC_ADAP_T1 || /* detect LMC1200 */
+	     subdevice !=3D PCI_DEVICE_ID_LMC_T1) &&
+	    (AdapModelNum !=3D LMC_ADAP_SSI || /* detect LMC1000 */
+	     subdevice !=3D PCI_DEVICE_ID_LMC_SSI) &&
+	    (AdapModelNum !=3D LMC_ADAP_DS3 || /* detect LMC5245 */
+	     subdevice !=3D PCI_DEVICE_ID_LMC_DS3) &&
+	    (AdapModelNum !=3D LMC_ADAP_HSSI || /* detect LMC5200 */
+	     subdevice !=3D PCI_DEVICE_ID_LMC_HSSI))
+		printk(KERN_WARNING "%s: Model number (%d) miscompare for PCI"
+		       " Subsystem ID =3D 0x%04x\n",
+		       dev->name, AdapModelNum, subdevice);
+
+	/* reset clock */
+	LMC_CSR_WRITE(sc, csr_gp_timer, 0xFFFFFFFFUL);
+
+	sc->board_idx =3D cards_found++;
+	sc->extra_stats.check =3D STATCHECK;
+	sc->extra_stats.version_size =3D (DRIVER_VERSION << 16) +
+		sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
+	sc->extra_stats.lmc_cardtype =3D sc->lmc_cardtype;
+
+	sc->lmc_ok =3D 0;
+	sc->last_link_status =3D 0;
+
+	lmc_trace(dev, "lmc_init_one out");
+	return 0;
=20
 err_hdlcdev:
 	pci_set_drvdata(pdev, NULL);
@@ -984,9 +933,7 @@ err_req_io:
 	return err;
 }
=20
-/*
- * Called from pci when removing module.
- */
+/* Called from pci when removing module. */
 static void __devexit lmc_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
@@ -1001,733 +948,678 @@ static void __devexit lmc_remove_one(struct pc=
i_dev *pdev)
 	}
 }
=20
-/* After this is called, packets can be sent.
- * Does not initialize the addresses
- */
+/* After this is called, packets can be sent. Does not initialize
+   the addresses */
 static int lmc_open(struct net_device *dev)
 {
-    lmc_softc_t *sc =3D dev_to_sc(dev);
-    int err;
-
-    lmc_trace(dev, "lmc_open in");
-
-    lmc_led_on(sc, LMC_DS3_LED0);
-
-    lmc_dec_reset(sc);
-    lmc_reset(sc);
-
-    LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ(sc, csr_status), 0);
-    LMC_EVENT_LOG(LMC_EVENT_RESET2, lmc_mii_readreg(sc, 0, 16),
-		  lmc_mii_readreg(sc, 0, 17));
-
-    if (sc->lmc_ok){
-        lmc_trace(dev, "lmc_open lmc_ok out");
-        return (0);
-    }
-
-    lmc_softreset (sc);
-
-    /* Since we have to use PCI bus, this should work on x86,alpha,ppc=
 */
-    if (request_irq (dev->irq, lmc_interrupt, IRQF_SHARED, dev->name, =
dev)){
-        printk(KERN_WARNING "%s: could not get irq: %d\n", dev->name, =
dev->irq);
-        lmc_trace(dev, "lmc_open irq failed out");
-        return -EAGAIN;
-    }
-    sc->got_irq =3D 1;
-
-    /* Assert Terminal Active */
-    sc->lmc_miireg16 |=3D LMC_MII16_LED_ALL;
-    sc->lmc_media->set_link_status (sc, LMC_LINK_UP);
-
-    /*
-     * reset to last state.
-     */
-    sc->lmc_media->set_status (sc, NULL);
-
-    /* setup default bits to be used in tulip_desc_t transmit descript=
or
-     * -baz */
-    sc->TxDescriptControlInit =3D (
-                                 LMC_TDES_INTERRUPT_ON_COMPLETION
-                                 | LMC_TDES_FIRST_SEGMENT
-                                 | LMC_TDES_LAST_SEGMENT
-                                 | LMC_TDES_SECOND_ADDR_CHAINED
-                                 | LMC_TDES_DISABLE_PADDING
-                                );
-
-    if (sc->ictl.crc_length =3D=3D LMC_CTL_CRC_LENGTH_16) {
-        /* disable 32 bit CRC generated by ASIC */
-        sc->TxDescriptControlInit |=3D LMC_TDES_ADD_CRC_DISABLE;
-    }
-    sc->lmc_media->set_crc_length(sc, sc->ictl.crc_length);
-    /* Acknoledge the Terminal Active and light LEDs */
-
-    /* dev->flags |=3D IFF_UP; */
-
-    if ((err =3D lmc_proto_open(sc)) !=3D 0)
-	    return err;
-
-    netif_start_queue(dev);
-    sc->extra_stats.tx_tbusy0++;
-
-    /*
-     * select what interrupts we want to get
-     */
-    sc->lmc_intrmask =3D 0;
-    /* Should be using the default interrupt mask defined in the .h fi=
le. */
-    sc->lmc_intrmask |=3D (TULIP_STS_NORMALINTR
-                         | TULIP_STS_RXINTR
-                         | TULIP_STS_TXINTR
-                         | TULIP_STS_ABNRMLINTR
-                         | TULIP_STS_SYSERROR
-                         | TULIP_STS_TXSTOPPED
-                         | TULIP_STS_TXUNDERFLOW
-                         | TULIP_STS_RXSTOPPED
-		         | TULIP_STS_RXNOBUF
-                        );
-    LMC_CSR_WRITE (sc, csr_intr, sc->lmc_intrmask);
-
-    sc->lmc_cmdmode |=3D TULIP_CMD_TXRUN;
-    sc->lmc_cmdmode |=3D TULIP_CMD_RXRUN;
-    LMC_CSR_WRITE (sc, csr_command, sc->lmc_cmdmode);
-
-    sc->lmc_ok =3D 1; /* Run watchdog */
-
-    /*
-     * Set the if up now - pfb
-     */
-
-    sc->last_link_status =3D 1;
-
-    /*
-     * Setup a timer for the watchdog on probe, and start it running.
-     * Since lmc_ok =3D=3D 0, it will be a NOP for now.
-     */
-    init_timer (&sc->timer);
-    sc->timer.expires =3D jiffies + HZ;
-    sc->timer.data =3D (unsigned long) dev;
-    sc->timer.function =3D &lmc_watchdog;
-    add_timer (&sc->timer);
-
-    lmc_trace(dev, "lmc_open out");
-
-    return (0);
+	lmc_softc_t *sc =3D dev_to_sc(dev);
+	int err;
+
+	lmc_trace(dev, "lmc_open in");
+
+	lmc_led_on(sc, LMC_DS3_LED0);
+
+	lmc_dec_reset(sc);
+	lmc_reset(sc);
+
+	LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ(sc, csr_status), 0);
+	LMC_EVENT_LOG(LMC_EVENT_RESET2, lmc_mii_readreg(sc, 0, 16),
+		      lmc_mii_readreg(sc, 0, 17));
+
+	if (sc->lmc_ok) {
+		lmc_trace(dev, "lmc_open lmc_ok out");
+		return 0;
+	}
+
+	lmc_softreset(sc);
+
+	/* Since we have to use PCI bus, this should work on x86, alpha, ppc =
*/
+	if (request_irq(dev->irq, lmc_interrupt, IRQF_SHARED,
+			dev->name, dev)) {
+		printk(KERN_WARNING "%s: could not get irq: %d\n",
+		       dev->name, dev->irq);
+		lmc_trace(dev, "lmc_open irq failed out");
+		return -EAGAIN;
+	}
+	sc->got_irq =3D 1;
+
+	/* Assert Terminal Active */
+	sc->lmc_miireg16 |=3D LMC_MII16_LED_ALL;
+	sc->lmc_media->set_link_status(sc, LMC_LINK_UP);
+
+	/*
+	 * reset to last state.
+	 */
+	sc->lmc_media->set_status(sc, NULL);
+
+	/* setup default bits to be used in tulip_desc_t transmit descriptor =
*/
+	sc->TxDescriptControlInit =3D (LMC_TDES_INTERRUPT_ON_COMPLETION |
+				     LMC_TDES_FIRST_SEGMENT |
+				     LMC_TDES_LAST_SEGMENT |
+				     LMC_TDES_SECOND_ADDR_CHAINED |
+				     LMC_TDES_DISABLE_PADDING);
+
+	if (sc->ictl.crc_length =3D=3D LMC_CTL_CRC_LENGTH_16)
+		/* disable 32 bit CRC generated by ASIC */
+		sc->TxDescriptControlInit |=3D LMC_TDES_ADD_CRC_DISABLE;
+
+	sc->lmc_media->set_crc_length(sc, sc->ictl.crc_length);
+	/* Acknowledge the Terminal Active and light LEDs */
+
+	/* dev->flags |=3D IFF_UP; */
+
+	if ((err =3D lmc_proto_open(sc)) !=3D 0)
+		return err;
+
+	netif_start_queue(dev);
+	sc->extra_stats.tx_tbusy0++;
+
+	/* select what interrupts we want to get */
+	sc->lmc_intrmask =3D 0;
+	/* Should be using the default interrupt mask defined in the .h file.=
 */
+	sc->lmc_intrmask |=3D (TULIP_STS_NORMALINTR | TULIP_STS_RXINTR |
+			     TULIP_STS_TXINTR | TULIP_STS_ABNRMLINTR |
+			     TULIP_STS_SYSERROR | TULIP_STS_TXSTOPPED |
+			     TULIP_STS_TXUNDERFLOW | TULIP_STS_RXSTOPPED |
+			     TULIP_STS_RXNOBUF);
+	LMC_CSR_WRITE(sc, csr_intr, sc->lmc_intrmask);
+
+	sc->lmc_cmdmode |=3D TULIP_CMD_TXRUN;
+	sc->lmc_cmdmode |=3D TULIP_CMD_RXRUN;
+	LMC_CSR_WRITE(sc, csr_command, sc->lmc_cmdmode);
+
+	sc->lmc_ok =3D 1; /* Run watchdog */
+
+	/* Set the if up now */
+	sc->last_link_status =3D 1;
+
+	/* Setup a timer for the watchdog on probe, and start it running.
+	   Since lmc_ok =3D=3D 0, it will be a NOP for now. */
+	init_timer(&sc->timer);
+	sc->timer.expires =3D jiffies + HZ;
+	sc->timer.data =3D (unsigned long) dev;
+	sc->timer.function =3D &lmc_watchdog;
+	add_timer(&sc->timer);
+
+	lmc_trace(dev, "lmc_open out");
+	return 0;
 }
=20
-/* Total reset to compensate for the AdTran DSU doing bad things
- *  under heavy load
- */
+/* Total reset to compensate for the AdTran DSU doing bad things under
+   heavy load */
=20
-static void lmc_running_reset (struct net_device *dev) /*fold00*/
+static void lmc_running_reset(struct net_device *dev)
 {
-    lmc_softc_t *sc =3D dev_to_sc(dev);
+	lmc_softc_t *sc =3D dev_to_sc(dev);
=20
-    lmc_trace(dev, "lmc_runnig_reset in");
+	lmc_trace(dev, "lmc_runnig_reset in");
=20
-    /* stop interrupts */
-    /* Clear the interrupt mask */
-    LMC_CSR_WRITE (sc, csr_intr, 0x00000000);
+	/* stop interrupts */
+	/* Clear the interrupt mask */
+	LMC_CSR_WRITE(sc, csr_intr, 0x00000000);
=20
-    lmc_dec_reset (sc);
-    lmc_reset (sc);
-    lmc_softreset (sc);
-    /* sc->lmc_miireg16 |=3D LMC_MII16_LED_ALL; */
-    sc->lmc_media->set_link_status (sc, 1);
-    sc->lmc_media->set_status (sc, NULL);
+	lmc_dec_reset(sc);
+	lmc_reset(sc);
+	lmc_softreset(sc);
+	/* sc->lmc_miireg16 |=3D LMC_MII16_LED_ALL; */
+	sc->lmc_media->set_link_status(sc, 1);
+	sc->lmc_media->set_status(sc, NULL);
=20
-    netif_wake_queue(dev);
+	netif_wake_queue(dev);
=20
-    sc->lmc_txfull =3D 0;
-    sc->extra_stats.tx_tbusy0++;
+	sc->lmc_txfull =3D 0;
+	sc->extra_stats.tx_tbusy0++;
=20
-    sc->lmc_intrmask =3D TULIP_DEFAULT_INTR_MASK;
-    LMC_CSR_WRITE (sc, csr_intr, sc->lmc_intrmask);
+	sc->lmc_intrmask =3D TULIP_DEFAULT_INTR_MASK;
+	LMC_CSR_WRITE(sc, csr_intr, sc->lmc_intrmask);
=20
-    sc->lmc_cmdmode |=3D (TULIP_CMD_TXRUN | TULIP_CMD_RXRUN);
-    LMC_CSR_WRITE (sc, csr_command, sc->lmc_cmdmode);
+	sc->lmc_cmdmode |=3D (TULIP_CMD_TXRUN | TULIP_CMD_RXRUN);
+	LMC_CSR_WRITE(sc, csr_command, sc->lmc_cmdmode);
=20
-    lmc_trace(dev, "lmc_runnin_reset_out");
+	lmc_trace(dev, "lmc_runnin_reset_out");
 }
=20
=20
-/* This is what is called when you ifconfig down a device.
- * This disables the timer for the watchdog and keepalives,
- * and disables the irq for dev.
- */
+/* This is what is called when you ifconfig down a device. This disabl=
es
+   the timer for the watchdog and keepalives, and disables the irq for=
 dev. */
 static int lmc_close(struct net_device *dev)
 {
-    /* not calling release_region() as we should */
-    lmc_softc_t *sc =3D dev_to_sc(dev);
+	/* not calling release_region() as we should */
+	lmc_softc_t *sc =3D dev_to_sc(dev);
=20
-    lmc_trace(dev, "lmc_close in");
+	lmc_trace(dev, "lmc_close in");
=20
-    sc->lmc_ok =3D 0;
-    sc->lmc_media->set_link_status (sc, 0);
-    del_timer (&sc->timer);
-    lmc_proto_close(sc);
-    lmc_ifdown (dev);
+	sc->lmc_ok =3D 0;
+	sc->lmc_media->set_link_status(sc, 0);
+	del_timer(&sc->timer);
+	lmc_proto_close(sc);
+	lmc_ifdown(dev);
=20
-    lmc_trace(dev, "lmc_close out");
+	lmc_trace(dev, "lmc_close out");
=20
-    return 0;
+	return 0;
 }
=20
-/* Ends the transfer of packets */
-/* When the interface goes down, this is called */
-static int lmc_ifdown (struct net_device *dev) /*fold00*/
+/* Ends the transfer of packets.
+   When the interface goes down, this is called */
+static int lmc_ifdown(struct net_device *dev)
 {
-    lmc_softc_t *sc =3D dev_to_sc(dev);
-    u32 csr6;
-    int i;
-
-    lmc_trace(dev, "lmc_ifdown in");
-
-    /* Don't let anything else go on right now */
-    //    dev->start =3D 0;
-    netif_stop_queue(dev);
-    sc->extra_stats.tx_tbusy1++;
-
-    /* stop interrupts */
-    /* Clear the interrupt mask */
-    LMC_CSR_WRITE (sc, csr_intr, 0x00000000);
-
-    /* Stop Tx and Rx on the chip */
-    csr6 =3D LMC_CSR_READ (sc, csr_command);
-    csr6 &=3D ~LMC_DEC_ST;		/* Turn off the Transmission bit */
-    csr6 &=3D ~LMC_DEC_SR;		/* Turn off the Receive bit */
-    LMC_CSR_WRITE (sc, csr_command, csr6);
-
-    sc->lmc_device->stats.rx_missed_errors +=3D
-	    LMC_CSR_READ(sc, csr_missed_frames) & 0xffff;
-
-    /* release the interrupt */
-    if(sc->got_irq =3D=3D 1){
-        free_irq (dev->irq, dev);
-        sc->got_irq =3D 0;
-    }
-
-    /* free skbuffs in the Rx queue */
-    for (i =3D 0; i < LMC_RXDESCS; i++)
-    {
-        struct sk_buff *skb =3D sc->lmc_rxq[i];
-        sc->lmc_rxq[i] =3D NULL;
-        sc->lmc_rxring[i].status =3D 0;
-        sc->lmc_rxring[i].length =3D 0;
-        sc->lmc_rxring[i].buffer1 =3D 0xDEADBEEF;
-        if (skb !=3D NULL)
-            dev_kfree_skb(skb);
-        sc->lmc_rxq[i] =3D NULL;
-    }
-
-    for (i =3D 0; i < LMC_TXDESCS; i++)
-    {
-        if (sc->lmc_txq[i] !=3D NULL)
-            dev_kfree_skb(sc->lmc_txq[i]);
-        sc->lmc_txq[i] =3D NULL;
-    }
-
-    lmc_led_off (sc, LMC_MII16_LED_ALL);
-
-    netif_wake_queue(dev);
-    sc->extra_stats.tx_tbusy0++;
-
-    lmc_trace(dev, "lmc_ifdown out");
-
-    return 0;
+	lmc_softc_t *sc =3D dev_to_sc(dev);
+	u32 csr6;
+	int i;
+
+	lmc_trace(dev, "lmc_ifdown in");
+
+	/* Don't let anything else go on right now */
+	/* dev->start =3D 0; */
+	netif_stop_queue(dev);
+	sc->extra_stats.tx_tbusy1++;
+
+	/* stop interrupts */
+	/* Clear the interrupt mask */
+	LMC_CSR_WRITE(sc, csr_intr, 0x00000000);
+
+	/* Stop Tx and Rx on the chip */
+	csr6 =3D LMC_CSR_READ(sc, csr_command);
+	csr6 &=3D ~LMC_DEC_ST;		/* Turn off the Transmission bit */
+	csr6 &=3D ~LMC_DEC_SR;		/* Turn off the Receive bit */
+	LMC_CSR_WRITE(sc, csr_command, csr6);
+
+	sc->lmc_device->stats.rx_missed_errors +=3D
+		LMC_CSR_READ(sc, csr_missed_frames) & 0xffff;
+
+	/* release the interrupt */
+	if (sc->got_irq =3D=3D 1) {
+		free_irq(dev->irq, dev);
+		sc->got_irq =3D 0;
+	}
+
+	/* free skbuffs in the Rx queue */
+	for (i =3D 0; i < LMC_RXDESCS; i++) {
+		struct sk_buff *skb =3D sc->lmc_rxq[i];
+		sc->lmc_rxq[i] =3D NULL;
+		sc->lmc_rxring[i].status =3D 0;
+		sc->lmc_rxring[i].length =3D 0;
+		sc->lmc_rxring[i].buffer1 =3D 0xDEADBEEF;
+		if (skb !=3D NULL)
+			dev_kfree_skb(skb);
+		sc->lmc_rxq[i] =3D NULL;
+	}
+
+	for (i =3D 0; i < LMC_TXDESCS; i++) {
+		if (sc->lmc_txq[i] !=3D NULL)
+			dev_kfree_skb(sc->lmc_txq[i]);
+		sc->lmc_txq[i] =3D NULL;
+	}
+
+	lmc_led_off(sc, LMC_MII16_LED_ALL);
+
+	netif_wake_queue(dev);
+	sc->extra_stats.tx_tbusy0++;
+
+	lmc_trace(dev, "lmc_ifdown out");
+
+	return 0;
 }
=20
 /* Interrupt handling routine.  This will take an incoming packet, or =
clean
- * up after a trasmit.
- */
-static irqreturn_t lmc_interrupt (int irq, void *dev_instance) /*fold0=
0*/
+   up after a trasmit. */
+static irqreturn_t lmc_interrupt(int irq, void *dev_instance)
 {
-    struct net_device *dev =3D (struct net_device *) dev_instance;
-    lmc_softc_t *sc =3D dev_to_sc(dev);
-    u32 csr;
-    int i;
-    s32 stat;
-    unsigned int badtx;
-    u32 firstcsr;
-    int max_work =3D LMC_RXDESCS;
-    int handled =3D 0;
-
-    lmc_trace(dev, "lmc_interrupt in");
-
-    spin_lock(&sc->lmc_lock);
-
-    /*
-     * Read the csr to find what interrupts we have (if any)
-     */
-    csr =3D LMC_CSR_READ (sc, csr_status);
-
-    /*
-     * Make sure this is our interrupt
-     */
-    if ( ! (csr & sc->lmc_intrmask)) {
-        goto lmc_int_fail_out;
-    }
-
-    firstcsr =3D csr;
-
-    /* always go through this loop at least once */
-    while (csr & sc->lmc_intrmask) {
-	handled =3D 1;
-
-        /*
-         * Clear interrupt bits, we handle all case below
-         */
-        LMC_CSR_WRITE (sc, csr_status, csr);
-
-        /*
-         * One of
-         *  - Transmit process timed out CSR5<1>
-         *  - Transmit jabber timeout    CSR5<3>
-         *  - Transmit underflow         CSR5<5>
-         *  - Transmit Receiver buffer unavailable CSR5<7>
-         *  - Receive process stopped    CSR5<8>
-         *  - Receive watchdog timeout   CSR5<9>
-         *  - Early transmit interrupt   CSR5<10>
-         *
-         * Is this really right? Should we do a running reset for jabb=
er?
-         * (being a WAN card and all)
-         */
-        if (csr & TULIP_STS_ABNRMLINTR){
-            lmc_running_reset (dev);
-            break;
-        }
-       =20
-        if (csr & TULIP_STS_RXINTR){
-            lmc_trace(dev, "rx interrupt");
-            lmc_rx (dev);
-           =20
-        }
-        if (csr & (TULIP_STS_TXINTR | TULIP_STS_TXNOBUF | TULIP_STS_TX=
STOPPED)) {
-
-	    int		n_compl =3D 0 ;
-            /* reset the transmit timeout detection flag -baz */
-	    sc->extra_stats.tx_NoCompleteCnt =3D 0;
-
-            badtx =3D sc->lmc_taint_tx;
-            i =3D badtx % LMC_TXDESCS;
-
-            while ((badtx < sc->lmc_next_tx)) {
-                stat =3D sc->lmc_txring[i].status;
-
-                LMC_EVENT_LOG (LMC_EVENT_XMTINT, stat,
-						 sc->lmc_txring[i].length);
-                /*
-                 * If bit 31 is 1 the tulip owns it break out of the l=
oop
-                 */
-                if (stat & 0x80000000)
-                    break;
-
-		n_compl++ ;		/* i.e., have an empty slot in ring */
-                /*
-                 * If we have no skbuff or have cleared it
-                 * Already continue to the next buffer
-                 */
-                if (sc->lmc_txq[i] =3D=3D NULL)
-                    continue;
+	struct net_device *dev =3D (struct net_device *) dev_instance;
+	lmc_softc_t *sc =3D dev_to_sc(dev);
+	u32 csr;
+	int i;
+	s32 stat;
+	unsigned int badtx;
+	u32 firstcsr;
+	int max_work =3D LMC_RXDESCS;
+	int handled =3D 0;
=20
-		/*
-		 * Check the total error summary to look for any errors
-		 */
-		if (stat & 0x8000) {
-			sc->lmc_device->stats.tx_errors++;
-			if (stat & 0x4104)
-				sc->lmc_device->stats.tx_aborted_errors++;
-			if (stat & 0x0C00)
-				sc->lmc_device->stats.tx_carrier_errors++;
-			if (stat & 0x0200)
-				sc->lmc_device->stats.tx_window_errors++;
-			if (stat & 0x0002)
-				sc->lmc_device->stats.tx_fifo_errors++;
-		} else {
-			sc->lmc_device->stats.tx_bytes +=3D sc->lmc_txring[i].length & 0x7f=
f;
+	lmc_trace(dev, "lmc_interrupt in");
=20
-			sc->lmc_device->stats.tx_packets++;
-                }
+	spin_lock(&sc->lmc_lock);
=20
-                //                dev_kfree_skb(sc->lmc_txq[i]);
-                dev_kfree_skb_irq(sc->lmc_txq[i]);
-                sc->lmc_txq[i] =3D NULL;
+	/* Read the csr to find what interrupts we have (if any) */
+	csr =3D LMC_CSR_READ(sc, csr_status);
=20
-                badtx++;
-                i =3D badtx % LMC_TXDESCS;
-            }
+	/* Make sure this is our interrupt */
+	if (!(csr & sc->lmc_intrmask))
+		goto lmc_int_fail_out;
=20
-            if (sc->lmc_next_tx - badtx > LMC_TXDESCS)
-            {
-                printk ("%s: out of sync pointer\n", dev->name);
-                badtx +=3D LMC_TXDESCS;
-            }
-            LMC_EVENT_LOG(LMC_EVENT_TBUSY0, n_compl, 0);
-            sc->lmc_txfull =3D 0;
-            netif_wake_queue(dev);
-	    sc->extra_stats.tx_tbusy0++;
+	firstcsr =3D csr;
=20
+	/* always go through this loop at least once */
+	while (csr & sc->lmc_intrmask) {
+		handled =3D 1;
+
+		/* Clear interrupt bits, we handle all case below */
+		LMC_CSR_WRITE(sc, csr_status, csr);
+
+		/*
+		 * One of
+		 *  - Transmit process timed out CSR5<1>
+		 *  - Transmit jabber timeout    CSR5<3>
+		 *  - Transmit underflow         CSR5<5>
+		 *  - Transmit Receiver buffer unavailable CSR5<7>
+		 *  - Receive process stopped    CSR5<8>
+		 *  - Receive watchdog timeout   CSR5<9>
+		 *  - Early transmit interrupt   CSR5<10>
+
+		 Is this really right? Should we do a running reset for
+		 jabber? (being a WAN card and all) */
+		if (csr & TULIP_STS_ABNRMLINTR) {
+			lmc_running_reset(dev);
+			break;
+		}
=20
+		if (csr & TULIP_STS_RXINTR) {
+			lmc_trace(dev, "rx interrupt");
+			lmc_rx(dev);
+
+		}
+		if (csr & (TULIP_STS_TXINTR | TULIP_STS_TXNOBUF |
+			   TULIP_STS_TXSTOPPED)) {
+
+			int n_compl =3D 0 ;
+			/* reset the transmit timeout detection flag */
+			sc->extra_stats.tx_NoCompleteCnt =3D 0;
+
+			badtx =3D sc->lmc_taint_tx;
+			i =3D badtx % LMC_TXDESCS;
+
+			while ((badtx < sc->lmc_next_tx)) {
+				stat =3D sc->lmc_txring[i].status;
+
+				LMC_EVENT_LOG(LMC_EVENT_XMTINT, stat,
+					      sc->lmc_txring[i].length);
+				/* If bit 31 is 1 the tulip owns it break out
+				   of the loop */
+				if (stat & 0x80000000)
+					break;
+
+				/* i.e., have an empty slot in ring */
+				n_compl++;
+				/* If we have no skbuff or have cleared it
+				   already. Continue to the next buffer */
+				if (sc->lmc_txq[i] =3D=3D NULL)
+					continue;
+
+				/* Check the total error summary to look for
+				   any errors */
+				if (stat & 0x8000) {
+					sc->lmc_device->stats.tx_errors++;
+					if (stat & 0x4104)
+						sc->lmc_device->stats.tx_aborted_errors++;
+					if (stat & 0x0C00)
+						sc->lmc_device->stats.tx_carrier_errors++;
+					if (stat & 0x0200)
+						sc->lmc_device->stats.tx_window_errors++;
+					if (stat & 0x0002)
+						sc->lmc_device->stats.tx_fifo_errors++;
+				} else {
+					sc->lmc_device->stats.tx_bytes +=3D
+						sc->lmc_txring[i].length & 0x7ff;
+
+					sc->lmc_device->stats.tx_packets++;
+				}
+
+				dev_kfree_skb_irq(sc->lmc_txq[i]);
+				sc->lmc_txq[i] =3D NULL;
+
+				badtx++;
+				i =3D badtx % LMC_TXDESCS;
+			}
+
+			if (sc->lmc_next_tx - badtx > LMC_TXDESCS) {
+				printk(KERN_WARNING "%s: out of sync pointer\n",
+				       dev->name);
+				badtx +=3D LMC_TXDESCS;
+			}
+			LMC_EVENT_LOG(LMC_EVENT_TBUSY0, n_compl, 0);
+			sc->lmc_txfull =3D 0;
+			netif_wake_queue(dev);
+			sc->extra_stats.tx_tbusy0++;
 #ifdef DEBUG
-	    sc->extra_stats.dirtyTx =3D badtx;
-	    sc->extra_stats.lmc_next_tx =3D sc->lmc_next_tx;
-	    sc->extra_stats.lmc_txfull =3D sc->lmc_txfull;
+			sc->extra_stats.dirtyTx =3D badtx;
+			sc->extra_stats.lmc_next_tx =3D sc->lmc_next_tx;
+			sc->extra_stats.lmc_txfull =3D sc->lmc_txfull;
 #endif
-            sc->lmc_taint_tx =3D badtx;
-
-            /*
-             * Why was there a break here???
-             */
-        }			/* end handle transmit interrupt */
-
-        if (csr & TULIP_STS_SYSERROR) {
-            u32 error;
-            printk (KERN_WARNING "%s: system bus error csr: %#8.8x\n",=
 dev->name, csr);
-            error =3D csr>>23 & 0x7;
-            switch(error){
-            case 0x000:
-                printk(KERN_WARNING "%s: Parity Fault (bad)\n", dev->n=
ame);
-                break;
-            case 0x001:
-                printk(KERN_WARNING "%s: Master Abort (naughty)\n", de=
v->name);
-                break;
-            case 0x010:
-                printk(KERN_WARNING "%s: Target Abort (not so naughty)=
\n", dev->name);
-                break;
-            default:
-                printk(KERN_WARNING "%s: This bus error code was suppo=
sed to be reserved!\n", dev->name);
-            }
-            lmc_dec_reset (sc);
-            lmc_reset (sc);
-            LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ (sc, csr_stat=
us), 0);
-            LMC_EVENT_LOG(LMC_EVENT_RESET2,
-                          lmc_mii_readreg (sc, 0, 16),
-                          lmc_mii_readreg (sc, 0, 17));
-
-        }
-
-       =20
-        if(max_work-- <=3D 0)
-            break;
-       =20
-        /*
-         * Get current csr status to make sure
-         * we've cleared all interrupts
-         */
-        csr =3D LMC_CSR_READ (sc, csr_status);
-    }				/* end interrupt loop */
-    LMC_EVENT_LOG(LMC_EVENT_INT, firstcsr, csr);
+			sc->lmc_taint_tx =3D badtx;
+		} /* end handle transmit interrupt */
+
+		if (csr & TULIP_STS_SYSERROR) {
+			u32 error;
+			printk(KERN_WARNING
+				"%s: system bus error csr: %#8.8x\n",
+				dev->name, csr);
+			error =3D csr>>23 & 0x7;
+			switch (error) {
+			case 0x000:
+				printk(KERN_WARNING
+				       "%s: Parity Fault (bad)\n", dev->name);
+				break;
+			case 0x001:
+				printk(KERN_WARNING
+				       "%s: Master Abort (naughty)\n",
+				       dev->name);
+				break;
+			case 0x010:
+				printk(KERN_WARNING
+				       "%s: Target Abort (not so naughty)\n",
+				       dev->name);
+				break;
+			default:
+				printk(KERN_WARNING
+				       "%s: This bus error code was supposed to be reserved!\n",
+				       dev->name);
+			}
+			lmc_dec_reset(sc);
+			lmc_reset(sc);
+			LMC_EVENT_LOG(LMC_EVENT_RESET1,
+				      LMC_CSR_READ(sc, csr_status), 0);
+			LMC_EVENT_LOG(LMC_EVENT_RESET2,
+				      lmc_mii_readreg(sc, 0, 16),
+				      lmc_mii_readreg(sc, 0, 17));
=20
-lmc_int_fail_out:
+		}
=20
-    spin_unlock(&sc->lmc_lock);
+		if (max_work-- <=3D 0)
+			break;
=20
-    lmc_trace(dev, "lmc_interrupt out");
-    return IRQ_RETVAL(handled);
+		/* Get current csr status to make sure we've cleared all
+		   interrupts */
+		csr =3D LMC_CSR_READ(sc, csr_status);
+	} /* end interrupt loop */
+	LMC_EVENT_LOG(LMC_EVENT_INT, firstcsr, csr);
+
+lmc_int_fail_out:
+	spin_unlock(&sc->lmc_lock);
+	lmc_trace(dev, "lmc_interrupt out");
+	return IRQ_RETVAL(handled);
 }
=20
 static netdev_tx_t lmc_start_xmit(struct sk_buff *skb,
 					struct net_device *dev)
 {
-    lmc_softc_t *sc =3D dev_to_sc(dev);
-    u32 flag;
-    int entry;
-    unsigned long flags;
+	lmc_softc_t *sc =3D dev_to_sc(dev);
+	u32 flag;
+	int entry;
+	unsigned long flags;
=20
-    lmc_trace(dev, "lmc_start_xmit in");
+	lmc_trace(dev, "lmc_start_xmit in");
=20
-    spin_lock_irqsave(&sc->lmc_lock, flags);
+	spin_lock_irqsave(&sc->lmc_lock, flags);
=20
-    /* normal path, tbusy known to be zero */
+	/* normal path, tbusy known to be zero */
=20
-    entry =3D sc->lmc_next_tx % LMC_TXDESCS;
+	entry =3D sc->lmc_next_tx % LMC_TXDESCS;
=20
-    sc->lmc_txq[entry] =3D skb;
-    sc->lmc_txring[entry].buffer1 =3D virt_to_bus (skb->data);
+	sc->lmc_txq[entry] =3D skb;
+	sc->lmc_txring[entry].buffer1 =3D virt_to_bus(skb->data);
=20
-    LMC_CONSOLE_LOG("xmit", skb->data, skb->len);
+	LMC_CONSOLE_LOG("xmit", skb->data, skb->len);
=20
 #ifndef GCOM
-    /* If the queue is less than half full, don't interrupt */
-    if (sc->lmc_next_tx - sc->lmc_taint_tx < LMC_TXDESCS / 2)
-    {
-        /* Do not interrupt on completion of this packet */
-        flag =3D 0x60000000;
-        netif_wake_queue(dev);
-    }
-    else if (sc->lmc_next_tx - sc->lmc_taint_tx =3D=3D LMC_TXDESCS / 2=
)
-    {
-        /* This generates an interrupt on completion of this packet */
-        flag =3D 0xe0000000;
-        netif_wake_queue(dev);
-    }
-    else if (sc->lmc_next_tx - sc->lmc_taint_tx < LMC_TXDESCS - 1)
-    {
-        /* Do not interrupt on completion of this packet */
-        flag =3D 0x60000000;
-        netif_wake_queue(dev);
-    }
-    else
-    {
-        /* This generates an interrupt on completion of this packet */
-        flag =3D 0xe0000000;
-        sc->lmc_txfull =3D 1;
-        netif_stop_queue(dev);
-    }
+	/* If the queue is less than half full, don't interrupt */
+	if (sc->lmc_next_tx - sc->lmc_taint_tx < LMC_TXDESCS / 2) {
+		/* Do not interrupt on completion of this packet */
+		flag =3D 0x60000000;
+		netif_wake_queue(dev);
+	} else if (sc->lmc_next_tx - sc->lmc_taint_tx =3D=3D LMC_TXDESCS / 2)=
 {
+		/* This generates an interrupt on completion of this packet */
+		flag =3D 0xe0000000;
+		netif_wake_queue(dev);
+	} else if (sc->lmc_next_tx - sc->lmc_taint_tx < LMC_TXDESCS - 1) {
+		/* Do not interrupt on completion of this packet */
+		flag =3D 0x60000000;
+		netif_wake_queue(dev);
+	} else {
+		/* This generates an interrupt on completion of this packet */
+		flag =3D 0xe0000000;
+		sc->lmc_txfull =3D 1;
+		netif_stop_queue(dev);
+	}
 #else
-    flag =3D LMC_TDES_INTERRUPT_ON_COMPLETION;
-
-    if (sc->lmc_next_tx - sc->lmc_taint_tx >=3D LMC_TXDESCS - 1)
-    {				/* ring full, go busy */
-        sc->lmc_txfull =3D 1;
-	netif_stop_queue(dev);
-	sc->extra_stats.tx_tbusy1++;
-        LMC_EVENT_LOG(LMC_EVENT_TBUSY1, entry, 0);
-    }
+	flag =3D LMC_TDES_INTERRUPT_ON_COMPLETION;
+
+	if (sc->lmc_next_tx - sc->lmc_taint_tx >=3D LMC_TXDESCS - 1) {
+		/* ring full, go busy */
+		sc->lmc_txfull =3D 1;
+		netif_stop_queue(dev);
+		sc->extra_stats.tx_tbusy1++;
+		LMC_EVENT_LOG(LMC_EVENT_TBUSY1, entry, 0);
+	}
 #endif
=20
+	if (entry =3D=3D LMC_TXDESCS - 1)	/* last descriptor in ring */
+		flag |=3D LMC_TDES_END_OF_RING;	/* flag as such for Tulip */
=20
-    if (entry =3D=3D LMC_TXDESCS - 1)	/* last descriptor in ring */
-	flag |=3D LMC_TDES_END_OF_RING;	/* flag as such for Tulip */
-
-    /* don't pad small packets either */
-    flag =3D sc->lmc_txring[entry].length =3D (skb->len) | flag |
-						sc->TxDescriptControlInit;
+	/* don't pad small packets either */
+	flag =3D sc->lmc_txring[entry].length =3D (skb->len) | flag |
+		sc->TxDescriptControlInit;
=20
-    /* set the transmit timeout flag to be checked in
-     * the watchdog timer handler. -baz
-     */
+	/* set the transmit timeout flag to be checked in the watchdog timer
+	   handler. */
=20
-    sc->extra_stats.tx_NoCompleteCnt++;
-    sc->lmc_next_tx++;
+	sc->extra_stats.tx_NoCompleteCnt++;
+	sc->lmc_next_tx++;
=20
-    /* give ownership to the chip */
-    LMC_EVENT_LOG(LMC_EVENT_XMT, flag, entry);
-    sc->lmc_txring[entry].status =3D 0x80000000;
+	/* give ownership to the chip */
+	LMC_EVENT_LOG(LMC_EVENT_XMT, flag, entry);
+	sc->lmc_txring[entry].status =3D 0x80000000;
=20
-    /* send now! */
-    LMC_CSR_WRITE (sc, csr_txpoll, 0);
+	/* send now! */
+	LMC_CSR_WRITE(sc, csr_txpoll, 0);
=20
-    spin_unlock_irqrestore(&sc->lmc_lock, flags);
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
=20
-    lmc_trace(dev, "lmc_start_xmit_out");
-    return NETDEV_TX_OK;
+	lmc_trace(dev, "lmc_start_xmit_out");
+	return NETDEV_TX_OK;
 }
=20
=20
 static int lmc_rx(struct net_device *dev)
 {
-    lmc_softc_t *sc =3D dev_to_sc(dev);
-    int i;
-    int rx_work_limit =3D LMC_RXDESCS;
-    unsigned int next_rx;
-    int rxIntLoopCnt;		/* debug -baz */
-    int localLengthErrCnt =3D 0;
-    long stat;
-    struct sk_buff *skb, *nsb;
-    u16 len;
-
-    lmc_trace(dev, "lmc_rx in");
-
-    lmc_led_on(sc, LMC_DS3_LED3);
-
-    rxIntLoopCnt =3D 0;		/* debug -baz */
-
-    i =3D sc->lmc_next_rx % LMC_RXDESCS;
-    next_rx =3D sc->lmc_next_rx;
-
-    while (((stat =3D sc->lmc_rxring[i].status) & LMC_RDES_OWN_BIT) !=3D=
 DESC_OWNED_BY_DC21X4)
-    {
-        rxIntLoopCnt++;		/* debug -baz */
-        len =3D ((stat & LMC_RDES_FRAME_LENGTH) >> RDES_FRAME_LENGTH_B=
IT_NUMBER);
-        if ((stat & 0x0300) !=3D 0x0300) {  /* Check first segment and=
 last segment */
-		if ((stat & 0x0000ffff) !=3D 0x7fff) {
-			/* Oversized frame */
+	lmc_softc_t *sc =3D dev_to_sc(dev);
+	int i;
+	int rx_work_limit =3D LMC_RXDESCS;
+	unsigned int next_rx;
+	int rxIntLoopCnt;		/* debug */
+	int localLengthErrCnt =3D 0;
+	long stat;
+	struct sk_buff *skb, *nsb;
+	u16 len;
+
+	lmc_trace(dev, "lmc_rx in");
+
+	lmc_led_on(sc, LMC_DS3_LED3);
+
+	rxIntLoopCnt =3D 0;		/* debug */
+
+	i =3D sc->lmc_next_rx % LMC_RXDESCS;
+	next_rx =3D sc->lmc_next_rx;
+
+	while (((stat =3D sc->lmc_rxring[i].status) & LMC_RDES_OWN_BIT) !=3D
+	       DESC_OWNED_BY_DC21X4) {
+		rxIntLoopCnt++;		/* debug */
+		len =3D ((stat & LMC_RDES_FRAME_LENGTH) >>
+		       RDES_FRAME_LENGTH_BIT_NUMBER);
+		if ((stat & 0x0300) !=3D 0x0300) {
+			/* Check first segment and last segment */
+			if ((stat & 0x0000ffff) !=3D 0x7fff) {
+				/* Oversized frame */
+				sc->lmc_device->stats.rx_length_errors++;
+				goto skip_packet;
+			}
+		}
+
+		if (stat & 0x00000008) { /* Catch a dribbling bit error */
+			sc->lmc_device->stats.rx_errors++;
+			sc->lmc_device->stats.rx_frame_errors++;
+			goto skip_packet;
+		}
+
+
+		if (stat & 0x00000004) { /* Catch a CRC error by the Xilinx */
+			sc->lmc_device->stats.rx_errors++;
+			sc->lmc_device->stats.rx_crc_errors++;
+			goto skip_packet;
+		}
+
+		if (len > LMC_PKT_BUF_SZ) {
 			sc->lmc_device->stats.rx_length_errors++;
+			localLengthErrCnt++;
 			goto skip_packet;
 		}
-	}
=20
-	if (stat & 0x00000008) { /* Catch a dribbling bit error */
-		sc->lmc_device->stats.rx_errors++;
-		sc->lmc_device->stats.rx_frame_errors++;
-		goto skip_packet;
-	}
+		if (len < sc->lmc_crcSize + 2) {
+			sc->lmc_device->stats.rx_length_errors++;
+			sc->extra_stats.rx_SmallPktCnt++;
+			localLengthErrCnt++;
+			goto skip_packet;
+		}
=20
+		if (stat & 0x00004000) {
+			printk(KERN_WARNING
+			       "%s: Receiver descriptor error, receiver out of sync?\n",
+			       dev->name);
+		}
=20
-	if (stat & 0x00000004) { /* Catch a CRC error by the Xilinx */
-		sc->lmc_device->stats.rx_errors++;
-		sc->lmc_device->stats.rx_crc_errors++;
-		goto skip_packet;
-	}
+		len -=3D sc->lmc_crcSize;
=20
-	if (len > LMC_PKT_BUF_SZ) {
-		sc->lmc_device->stats.rx_length_errors++;
-		localLengthErrCnt++;
-		goto skip_packet;
+		skb =3D sc->lmc_rxq[i];
+
+		/* We ran out of memory at some point just allocate an skb buff
+		   and continue. */
+
+		if (!skb) {
+			nsb =3D dev_alloc_skb(LMC_PKT_BUF_SZ + 2);
+			if (nsb) {
+				sc->lmc_rxq[i] =3D nsb;
+				nsb->dev =3D dev;
+				sc->lmc_rxring[i].buffer1 =3D
+					virt_to_bus(skb_tail_pointer(nsb));
+			}
+			sc->failed_recv_alloc =3D 1;
+			goto skip_packet;
+		}
+
+		sc->lmc_device->stats.rx_packets++;
+		sc->lmc_device->stats.rx_bytes +=3D len;
+
+		LMC_CONSOLE_LOG("recv", skb->data, len);
+
+		/* I'm not sure of the sanity of this. Packets could be arriving
+		   at a constant 44.210mbits/sec and we're going to copy them
+		   into a new buffer?? */
+
+		if (len > (LMC_MTU - (LMC_MTU>>2))) { /* len > LMC_MTU * 0.75 */
+			/* If it's a large packet don't copy it just hand it
+			   up */
+give_it_anyways:
+			sc->lmc_rxq[i] =3D NULL;
+			sc->lmc_rxring[i].buffer1 =3D 0x0;
+
+			skb_put(skb, len);
+			skb->protocol =3D lmc_proto_type(sc, skb);
+			skb_reset_mac_header(skb);
+			/* skb_reset_network_header(skb); */
+			skb->dev =3D dev;
+			lmc_proto_netif(sc, skb);
+
+			/* This skb will be destroyed by the upper layers,
+			   make a new one */
+			nsb =3D dev_alloc_skb(LMC_PKT_BUF_SZ + 2);
+			if (nsb) {
+				sc->lmc_rxq[i] =3D nsb;
+				nsb->dev =3D dev;
+				sc->lmc_rxring[i].buffer1 =3D
+					virt_to_bus(skb_tail_pointer(nsb));
+				/* Transferred to 21140 below */
+			} else {
+				/* We've run out of memory, stop trying to
+				   allocate memory and exit the interrupt
+				   handler The chip may run out of receivers
+				   and stop in which care we'll try to allocate
+				   the buffer again (once a second). */
+				sc->extra_stats.rx_BuffAllocErr++;
+				LMC_EVENT_LOG(LMC_EVENT_RCVINT, stat, len);
+				sc->failed_recv_alloc =3D 1;
+				goto skip_out_of_mem;
+			}
+		} else {
+			nsb =3D dev_alloc_skb(len);
+			if (!nsb)
+				goto give_it_anyways;
+			skb_copy_from_linear_data(skb, skb_put(nsb, len), len);
+			nsb->protocol =3D lmc_proto_type(sc, nsb);
+			skb_reset_mac_header(nsb);
+			/* skb_reset_network_header(nsb); */
+			nsb->dev =3D dev;
+			lmc_proto_netif(sc, nsb);
+		}
+
+skip_packet:
+		LMC_EVENT_LOG(LMC_EVENT_RCVINT, stat, len);
+		sc->lmc_rxring[i].status =3D DESC_OWNED_BY_DC21X4;
+
+		sc->lmc_next_rx++;
+		i =3D sc->lmc_next_rx % LMC_RXDESCS;
+		rx_work_limit--;
+		if (rx_work_limit < 0)
+			break;
 	}
=20
-	if (len < sc->lmc_crcSize + 2) {
-		sc->lmc_device->stats.rx_length_errors++;
-		sc->extra_stats.rx_SmallPktCnt++;
-		localLengthErrCnt++;
-		goto skip_packet;
+#if 0
+	/* detect condition for LMC1000 where DSU cable attaches and fills
+	   descriptors with bogus packets */
+
+	if (localLengthErrCnt > LMC_RXDESCS - 3) {
+		sc->extra_stats.rx_BadPktSurgeCnt++;
+		LMC_EVENT_LOG(LMC_EVENT_BADPKTSURGE, localLengthErrCnt,
+			      sc->extra_stats.rx_BadPktSurgeCnt);
 	}
+#endif
=20
-        if(stat & 0x00004000){
-            printk(KERN_WARNING "%s: Receiver descriptor error, receiv=
er out of sync?\n", dev->name);
-        }
-
-        len -=3D sc->lmc_crcSize;
-
-        skb =3D sc->lmc_rxq[i];
-
-        /*
-         * We ran out of memory at some point
-         * just allocate an skb buff and continue.
-         */
-       =20
-        if (!skb) {
-            nsb =3D dev_alloc_skb (LMC_PKT_BUF_SZ + 2);
-            if (nsb) {
-                sc->lmc_rxq[i] =3D nsb;
-                nsb->dev =3D dev;
-                sc->lmc_rxring[i].buffer1 =3D virt_to_bus(skb_tail_poi=
nter(nsb));
-            }
-            sc->failed_recv_alloc =3D 1;
-            goto skip_packet;
-        }
-       =20
-	sc->lmc_device->stats.rx_packets++;
-	sc->lmc_device->stats.rx_bytes +=3D len;
-
-        LMC_CONSOLE_LOG("recv", skb->data, len);
-
-        /*
-         * I'm not sure of the sanity of this
-         * Packets could be arriving at a constant
-         * 44.210mbits/sec and we're going to copy
-         * them into a new buffer??
-         */
-       =20
-        if(len > (LMC_MTU - (LMC_MTU>>2))){ /* len > LMC_MTU * 0.75 */
-            /*
-             * If it's a large packet don't copy it just hand it up
-             */
-        give_it_anyways:
-
-            sc->lmc_rxq[i] =3D NULL;
-            sc->lmc_rxring[i].buffer1 =3D 0x0;
-
-            skb_put (skb, len);
-            skb->protocol =3D lmc_proto_type(sc, skb);
-            skb_reset_mac_header(skb);
-            /* skb_reset_network_header(skb); */
-            skb->dev =3D dev;
-            lmc_proto_netif(sc, skb);
-
-            /*
-             * This skb will be destroyed by the upper layers, make a =
new one
-             */
-            nsb =3D dev_alloc_skb (LMC_PKT_BUF_SZ + 2);
-            if (nsb) {
-                sc->lmc_rxq[i] =3D nsb;
-                nsb->dev =3D dev;
-                sc->lmc_rxring[i].buffer1 =3D virt_to_bus(skb_tail_poi=
nter(nsb));
-                /* Transferred to 21140 below */
-            }
-            else {
-                /*
-                 * We've run out of memory, stop trying to allocate
-                 * memory and exit the interrupt handler
-                 *
-                 * The chip may run out of receivers and stop
-                 * in which care we'll try to allocate the buffer
-                 * again.  (once a second)
-                 */
-		sc->extra_stats.rx_BuffAllocErr++;
-                LMC_EVENT_LOG(LMC_EVENT_RCVINT, stat, len);
-                sc->failed_recv_alloc =3D 1;
-                goto skip_out_of_mem;
-            }
-        }
-        else {
-            nsb =3D dev_alloc_skb(len);
-            if(!nsb) {
-                goto give_it_anyways;
-            }
-            skb_copy_from_linear_data(skb, skb_put(nsb, len), len);
-           =20
-            nsb->protocol =3D lmc_proto_type(sc, nsb);
-            skb_reset_mac_header(nsb);
-            /* skb_reset_network_header(nsb); */
-            nsb->dev =3D dev;
-            lmc_proto_netif(sc, nsb);
-        }
-
-    skip_packet:
-        LMC_EVENT_LOG(LMC_EVENT_RCVINT, stat, len);
-        sc->lmc_rxring[i].status =3D DESC_OWNED_BY_DC21X4;
-
-        sc->lmc_next_rx++;
-        i =3D sc->lmc_next_rx % LMC_RXDESCS;
-        rx_work_limit--;
-        if (rx_work_limit < 0)
-            break;
-    }
-
-    /* detect condition for LMC1000 where DSU cable attaches and fills
-     * descriptors with bogus packets
-     *
-    if (localLengthErrCnt > LMC_RXDESCS - 3) {
-	sc->extra_stats.rx_BadPktSurgeCnt++;
-	LMC_EVENT_LOG(LMC_EVENT_BADPKTSURGE, localLengthErrCnt,
-		      sc->extra_stats.rx_BadPktSurgeCnt);
-    } */
-
-    /* save max count of receive descriptors serviced */
-    if (rxIntLoopCnt > sc->extra_stats.rxIntLoopCnt)
-	    sc->extra_stats.rxIntLoopCnt =3D rxIntLoopCnt; /* debug -baz */
+	/* save max count of receive descriptors serviced */
+	if (rxIntLoopCnt > sc->extra_stats.rxIntLoopCnt)
+		sc->extra_stats.rxIntLoopCnt =3D rxIntLoopCnt; /* debug */
=20
 #ifdef DEBUG
-    if (rxIntLoopCnt =3D=3D 0)
-    {
-        for (i =3D 0; i < LMC_RXDESCS; i++)
-        {
-            if ((sc->lmc_rxring[i].status & LMC_RDES_OWN_BIT)
-                !=3D DESC_OWNED_BY_DC21X4)
-            {
-                rxIntLoopCnt++;
-            }
-        }
-        LMC_EVENT_LOG(LMC_EVENT_RCVEND, rxIntLoopCnt, 0);
-    }
+	if (rxIntLoopCnt =3D=3D 0) {
+		for (i =3D 0; i < LMC_RXDESCS; i++) {
+			if ((sc->lmc_rxring[i].status & LMC_RDES_OWN_BIT)
+			    !=3D DESC_OWNED_BY_DC21X4)
+				rxIntLoopCnt++;
+		}
+		LMC_EVENT_LOG(LMC_EVENT_RCVEND, rxIntLoopCnt, 0);
+	}
 #endif
=20
-
-    lmc_led_off(sc, LMC_DS3_LED3);
+	lmc_led_off(sc, LMC_DS3_LED3);
=20
 skip_out_of_mem:
-
-    lmc_trace(dev, "lmc_rx out");
-
-    return 0;
+	lmc_trace(dev, "lmc_rx out");
+	return 0;
 }
=20
 static struct net_device_stats *lmc_get_stats(struct net_device *dev)
 {
-    lmc_softc_t *sc =3D dev_to_sc(dev);
-    unsigned long flags;
-
-    lmc_trace(dev, "lmc_get_stats in");
+	lmc_softc_t *sc =3D dev_to_sc(dev);
+	unsigned long flags;
=20
-    spin_lock_irqsave(&sc->lmc_lock, flags);
+	lmc_trace(dev, "lmc_get_stats in");
=20
-    sc->lmc_device->stats.rx_missed_errors +=3D LMC_CSR_READ(sc, csr_m=
issed_frames) & 0xffff;
+	spin_lock_irqsave(&sc->lmc_lock, flags);
=20
-    spin_unlock_irqrestore(&sc->lmc_lock, flags);
+	sc->lmc_device->stats.rx_missed_errors +=3D
+		LMC_CSR_READ(sc, csr_missed_frames) & 0xffff;
=20
-    lmc_trace(dev, "lmc_get_stats out");
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
=20
-    return &sc->lmc_device->stats;
+	lmc_trace(dev, "lmc_get_stats out");
+	return &sc->lmc_device->stats;
 }
=20
 static struct pci_driver lmc_driver =3D {
@@ -1739,407 +1631,365 @@ static struct pci_driver lmc_driver =3D {
=20
 static int __init init_lmc(void)
 {
-    return pci_register_driver(&lmc_driver);
+	return pci_register_driver(&lmc_driver);
 }
=20
 static void __exit exit_lmc(void)
 {
-    pci_unregister_driver(&lmc_driver);
+	pci_unregister_driver(&lmc_driver);
 }
=20
 module_init(init_lmc);
 module_exit(exit_lmc);
=20
-unsigned lmc_mii_readreg (lmc_softc_t * const sc, unsigned devaddr, un=
signed regno) /*fold00*/
+unsigned lmc_mii_readreg(lmc_softc_t * const sc, unsigned devaddr,
+			 unsigned regno)
 {
-    int i;
-    int command =3D (0xf6 << 10) | (devaddr << 5) | regno;
-    int retval =3D 0;
+	int i;
+	int command =3D (0xf6 << 10) | (devaddr << 5) | regno;
+	int retval =3D 0;
=20
-    lmc_trace(sc->lmc_device, "lmc_mii_readreg in");
+	lmc_trace(sc->lmc_device, "lmc_mii_readreg in");
=20
-    LMC_MII_SYNC (sc);
+	LMC_MII_SYNC(sc);
=20
-    lmc_trace(sc->lmc_device, "lmc_mii_readreg: done sync");
+	lmc_trace(sc->lmc_device, "lmc_mii_readreg: done sync");
=20
-    for (i =3D 15; i >=3D 0; i--)
-    {
-        int dataval =3D (command & (1 << i)) ? 0x20000 : 0;
+	for (i =3D 15; i >=3D 0; i--) {
+		int dataval =3D (command & (1 << i)) ? 0x20000 : 0;
=20
-        LMC_CSR_WRITE (sc, csr_9, dataval);
-        lmc_delay ();
-        /* __SLOW_DOWN_IO; */
-        LMC_CSR_WRITE (sc, csr_9, dataval | 0x10000);
-        lmc_delay ();
-        /* __SLOW_DOWN_IO; */
-    }
-
-    lmc_trace(sc->lmc_device, "lmc_mii_readreg: done1");
+		LMC_CSR_WRITE(sc, csr_9, dataval);
+		lmc_delay();
+		/* __SLOW_DOWN_IO; */
+		LMC_CSR_WRITE(sc, csr_9, dataval | 0x10000);
+		lmc_delay();
+		/* __SLOW_DOWN_IO; */
+	}
=20
-    for (i =3D 19; i > 0; i--)
-    {
-        LMC_CSR_WRITE (sc, csr_9, 0x40000);
-        lmc_delay ();
-        /* __SLOW_DOWN_IO; */
-        retval =3D (retval << 1) | ((LMC_CSR_READ (sc, csr_9) & 0x8000=
0) ? 1 : 0);
-        LMC_CSR_WRITE (sc, csr_9, 0x40000 | 0x10000);
-        lmc_delay ();
-        /* __SLOW_DOWN_IO; */
-    }
+	lmc_trace(sc->lmc_device, "lmc_mii_readreg: done1");
+
+	for (i =3D 19; i > 0; i--) {
+		LMC_CSR_WRITE(sc, csr_9, 0x40000);
+		lmc_delay();
+		/* __SLOW_DOWN_IO; */
+		retval =3D (retval << 1) |
+			((LMC_CSR_READ(sc, csr_9) & 0x80000) ? 1 : 0);
+		LMC_CSR_WRITE(sc, csr_9, 0x40000 | 0x10000);
+		lmc_delay();
+		/* __SLOW_DOWN_IO; */
+	}
=20
-    lmc_trace(sc->lmc_device, "lmc_mii_readreg out");
+	lmc_trace(sc->lmc_device, "lmc_mii_readreg out");
=20
-    return (retval >> 1) & 0xffff;
+	return (retval >> 1) & 0xffff;
 }
=20
-void lmc_mii_writereg (lmc_softc_t * const sc, unsigned devaddr, unsig=
ned regno, unsigned data) /*fold00*/
+void lmc_mii_writereg(lmc_softc_t * const sc, unsigned devaddr, unsign=
ed regno,
+		      unsigned data)
 {
-    int i =3D 32;
-    int command =3D (0x5002 << 16) | (devaddr << 23) | (regno << 18) |=
 data;
-
-    lmc_trace(sc->lmc_device, "lmc_mii_writereg in");
-
-    LMC_MII_SYNC (sc);
-
-    i =3D 31;
-    while (i >=3D 0)
-    {
-        int datav;
-
-        if (command & (1 << i))
-            datav =3D 0x20000;
-        else
-            datav =3D 0x00000;
-
-        LMC_CSR_WRITE (sc, csr_9, datav);
-        lmc_delay ();
-        /* __SLOW_DOWN_IO; */
-        LMC_CSR_WRITE (sc, csr_9, (datav | 0x10000));
-        lmc_delay ();
-        /* __SLOW_DOWN_IO; */
-        i--;
-    }
-
-    i =3D 2;
-    while (i > 0)
-    {
-        LMC_CSR_WRITE (sc, csr_9, 0x40000);
-        lmc_delay ();
-        /* __SLOW_DOWN_IO; */
-        LMC_CSR_WRITE (sc, csr_9, 0x50000);
-        lmc_delay ();
-        /* __SLOW_DOWN_IO; */
-        i--;
-    }
-
-    lmc_trace(sc->lmc_device, "lmc_mii_writereg out");
+	int i =3D 32;
+	int command =3D (0x5002 << 16) | (devaddr << 23) | (regno << 18) | da=
ta;
+
+	lmc_trace(sc->lmc_device, "lmc_mii_writereg in");
+
+	LMC_MII_SYNC(sc);
+
+	i =3D 31;
+	while (i >=3D 0) {
+		int datav;
+
+		if (command & (1 << i))
+			datav =3D 0x20000;
+		else
+			datav =3D 0x00000;
+
+		LMC_CSR_WRITE(sc, csr_9, datav);
+		lmc_delay();
+		/* __SLOW_DOWN_IO; */
+		LMC_CSR_WRITE(sc, csr_9, (datav | 0x10000));
+		lmc_delay();
+		/* __SLOW_DOWN_IO; */
+		i--;
+	}
+
+	i =3D 2;
+	while (i > 0) {
+		LMC_CSR_WRITE(sc, csr_9, 0x40000);
+		lmc_delay();
+		/* __SLOW_DOWN_IO; */
+		LMC_CSR_WRITE(sc, csr_9, 0x50000);
+		lmc_delay();
+		/* __SLOW_DOWN_IO; */
+		i--;
+	}
+
+	lmc_trace(sc->lmc_device, "lmc_mii_writereg out");
 }
=20
-static void lmc_softreset (lmc_softc_t * const sc) /*fold00*/
+static void lmc_softreset(lmc_softc_t * const sc)
 {
-    int i;
-
-    lmc_trace(sc->lmc_device, "lmc_softreset in");
-
-    /* Initialize the receive rings and buffers. */
-    sc->lmc_txfull =3D 0;
-    sc->lmc_next_rx =3D 0;
-    sc->lmc_next_tx =3D 0;
-    sc->lmc_taint_rx =3D 0;
-    sc->lmc_taint_tx =3D 0;
-
-    /*
-     * Setup each one of the receiver buffers
-     * allocate an skbuff for each one, setup the descriptor table
-     * and point each buffer at the next one
-     */
-
-    for (i =3D 0; i < LMC_RXDESCS; i++)
-    {
-        struct sk_buff *skb;
-
-        if (sc->lmc_rxq[i] =3D=3D NULL)
-        {
-            skb =3D dev_alloc_skb (LMC_PKT_BUF_SZ + 2);
-            if(skb =3D=3D NULL){
-                printk(KERN_WARNING "%s: Failed to allocate receiver r=
ing, will try again\n", sc->name);
-                sc->failed_ring =3D 1;
-                break;
-            }
-            else{
-                sc->lmc_rxq[i] =3D skb;
-            }
-        }
-        else
-        {
-            skb =3D sc->lmc_rxq[i];
-        }
-
-        skb->dev =3D sc->lmc_device;
-
-        /* owned by 21140 */
-        sc->lmc_rxring[i].status =3D 0x80000000;
-
-        /* used to be PKT_BUF_SZ now uses skb since we lose some to he=
ad room */
-        sc->lmc_rxring[i].length =3D skb_tailroom(skb);
-
-        /* use to be tail which is dumb since you're thinking why writ=
e
-         * to the end of the packj,et but since there's nothing there =
tail =3D=3D data
-         */
-        sc->lmc_rxring[i].buffer1 =3D virt_to_bus (skb->data);
-
-        /* This is fair since the structure is static and we have the =
next address */
-        sc->lmc_rxring[i].buffer2 =3D virt_to_bus (&sc->lmc_rxring[i +=
 1]);
-
-    }
-
-    /*
-     * Sets end of ring
-     */
-    if (i !=3D 0) {
-        sc->lmc_rxring[i - 1].length |=3D 0x02000000; /* Set end of bu=
ffers flag */
-        sc->lmc_rxring[i - 1].buffer2 =3D virt_to_bus(&sc->lmc_rxring[=
0]); /* Point back to the start */
-    }
-    LMC_CSR_WRITE (sc, csr_rxlist, virt_to_bus (sc->lmc_rxring)); /* w=
rite base address */
-
-    /* Initialize the transmit rings and buffers */
-    for (i =3D 0; i < LMC_TXDESCS; i++)
-    {
-        if (sc->lmc_txq[i] !=3D NULL){		/* have buffer */
-            dev_kfree_skb(sc->lmc_txq[i]);	/* free it */
-	    sc->lmc_device->stats.tx_dropped++;	/* We just dropped a packet *=
/
-        }
-        sc->lmc_txq[i] =3D NULL;
-        sc->lmc_txring[i].status =3D 0x00000000;
-        sc->lmc_txring[i].buffer2 =3D virt_to_bus (&sc->lmc_txring[i +=
 1]);
-    }
-    sc->lmc_txring[i - 1].buffer2 =3D virt_to_bus (&sc->lmc_txring[0])=
;
-    LMC_CSR_WRITE (sc, csr_txlist, virt_to_bus (sc->lmc_txring));
-
-    lmc_trace(sc->lmc_device, "lmc_softreset out");
+	int i;
+
+	lmc_trace(sc->lmc_device, "lmc_softreset in");
+
+	/* Initialize the receive rings and buffers. */
+	sc->lmc_txfull =3D 0;
+	sc->lmc_next_rx =3D 0;
+	sc->lmc_next_tx =3D 0;
+	sc->lmc_taint_rx =3D 0;
+	sc->lmc_taint_tx =3D 0;
+
+	/* Setup each one of the receiver buffers allocate an skbuff for
+	   each one, setup the descriptor table and point each buffer at
+	   the next one */
+
+	for (i =3D 0; i < LMC_RXDESCS; i++) {
+		struct sk_buff *skb;
+
+		if (sc->lmc_rxq[i] =3D=3D NULL) {
+			skb =3D dev_alloc_skb(LMC_PKT_BUF_SZ + 2);
+			if (skb =3D=3D NULL) {
+				printk(KERN_WARNING
+				       "%s: Failed to allocate receiver ring, will try again\n",
+				       sc->name);
+				sc->failed_ring =3D 1;
+				break;
+			} else
+				sc->lmc_rxq[i] =3D skb;
+		} else
+			skb =3D sc->lmc_rxq[i];
+
+		skb->dev =3D sc->lmc_device;
+
+		/* owned by 21140 */
+		sc->lmc_rxring[i].status =3D 0x80000000;
+
+		/* used to be PKT_BUF_SZ now uses skb since we lose some
+		   to head room */
+		sc->lmc_rxring[i].length =3D skb_tailroom(skb);
+
+		/* use to be tail which is dumb since you're thinking why write
+		   to the end of the packet but since there's nothing there
+		   tail =3D=3D data */
+		sc->lmc_rxring[i].buffer1 =3D virt_to_bus(skb->data);
+
+		/* This is fair since the structure is static and we have
+		   the next address */
+		sc->lmc_rxring[i].buffer2 =3D virt_to_bus(&sc->lmc_rxring[i + 1]);
+	}
+
+	/* Sets end of ring */
+	if (i !=3D 0) {
+		/* Set end of buffers flag */
+		sc->lmc_rxring[i - 1].length |=3D 0x02000000;
+		/* Point back to the start */
+		sc->lmc_rxring[i - 1].buffer2 =3D virt_to_bus(&sc->lmc_rxring[0]);
+	}
+	/* write base address */
+	LMC_CSR_WRITE(sc, csr_rxlist, virt_to_bus(sc->lmc_rxring));
+
+	/* Initialize the transmit rings and buffers */
+	for (i =3D 0; i < LMC_TXDESCS; i++) {
+		if (sc->lmc_txq[i] !=3D NULL) {		/* have buffer */
+			dev_kfree_skb(sc->lmc_txq[i]);	/* free it */
+			/* We just dropped a packet */
+			sc->lmc_device->stats.tx_dropped++;
+		}
+		sc->lmc_txq[i] =3D NULL;
+		sc->lmc_txring[i].status =3D 0x00000000;
+		sc->lmc_txring[i].buffer2 =3D virt_to_bus(&sc->lmc_txring[i + 1]);
+	}
+	sc->lmc_txring[i - 1].buffer2 =3D virt_to_bus(&sc->lmc_txring[0]);
+	LMC_CSR_WRITE(sc, csr_txlist, virt_to_bus(sc->lmc_txring));
+
+	lmc_trace(sc->lmc_device, "lmc_softreset out");
 }
=20
-void lmc_gpio_mkinput(lmc_softc_t * const sc, u32 bits) /*fold00*/
+void lmc_gpio_mkinput(lmc_softc_t * const sc, u32 bits)
 {
-    lmc_trace(sc->lmc_device, "lmc_gpio_mkinput in");
-    sc->lmc_gpio_io &=3D ~bits;
-    LMC_CSR_WRITE(sc, csr_gp, TULIP_GP_PINSET | (sc->lmc_gpio_io));
-    lmc_trace(sc->lmc_device, "lmc_gpio_mkinput out");
+	lmc_trace(sc->lmc_device, "lmc_gpio_mkinput in");
+	sc->lmc_gpio_io &=3D ~bits;
+	LMC_CSR_WRITE(sc, csr_gp, TULIP_GP_PINSET | (sc->lmc_gpio_io));
+	lmc_trace(sc->lmc_device, "lmc_gpio_mkinput out");
 }
=20
-void lmc_gpio_mkoutput(lmc_softc_t * const sc, u32 bits) /*fold00*/
+void lmc_gpio_mkoutput(lmc_softc_t * const sc, u32 bits)
 {
-    lmc_trace(sc->lmc_device, "lmc_gpio_mkoutput in");
-    sc->lmc_gpio_io |=3D bits;
-    LMC_CSR_WRITE(sc, csr_gp, TULIP_GP_PINSET | (sc->lmc_gpio_io));
-    lmc_trace(sc->lmc_device, "lmc_gpio_mkoutput out");
+	lmc_trace(sc->lmc_device, "lmc_gpio_mkoutput in");
+	sc->lmc_gpio_io |=3D bits;
+	LMC_CSR_WRITE(sc, csr_gp, TULIP_GP_PINSET | (sc->lmc_gpio_io));
+	lmc_trace(sc->lmc_device, "lmc_gpio_mkoutput out");
 }
=20
-void lmc_led_on(lmc_softc_t * const sc, u32 led) /*fold00*/
+void lmc_led_on(lmc_softc_t * const sc, u32 led)
 {
-    lmc_trace(sc->lmc_device, "lmc_led_on in");
-    if((~sc->lmc_miireg16) & led){ /* Already on! */
-        lmc_trace(sc->lmc_device, "lmc_led_on aon out");
-        return;
-    }
-   =20
-    sc->lmc_miireg16 &=3D ~led;
-    lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-    lmc_trace(sc->lmc_device, "lmc_led_on out");
+	lmc_trace(sc->lmc_device, "lmc_led_on in");
+	if ((~sc->lmc_miireg16) & led) { /* Already on! */
+		lmc_trace(sc->lmc_device, "lmc_led_on aon out");
+		return;
+	}
+
+	sc->lmc_miireg16 &=3D ~led;
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_trace(sc->lmc_device, "lmc_led_on out");
 }
=20
-void lmc_led_off(lmc_softc_t * const sc, u32 led) /*fold00*/
+void lmc_led_off(lmc_softc_t * const sc, u32 led)
 {
-    lmc_trace(sc->lmc_device, "lmc_led_off in");
-    if(sc->lmc_miireg16 & led){ /* Already set don't do anything */
-        lmc_trace(sc->lmc_device, "lmc_led_off aoff out");
-        return;
-    }
-   =20
-    sc->lmc_miireg16 |=3D led;
-    lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-    lmc_trace(sc->lmc_device, "lmc_led_off out");
+	lmc_trace(sc->lmc_device, "lmc_led_off in");
+	if (sc->lmc_miireg16 & led) { /* Already set don't do anything */
+		lmc_trace(sc->lmc_device, "lmc_led_off aoff out");
+		return;
+	}
+
+	sc->lmc_miireg16 |=3D led;
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_trace(sc->lmc_device, "lmc_led_off out");
 }
=20
-static void lmc_reset(lmc_softc_t * const sc) /*fold00*/
+static void lmc_reset(lmc_softc_t * const sc)
 {
-    lmc_trace(sc->lmc_device, "lmc_reset in");
-    sc->lmc_miireg16 |=3D LMC_MII16_FIFO_RESET;
-    lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-
-    sc->lmc_miireg16 &=3D ~LMC_MII16_FIFO_RESET;
-    lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-
-    /*
-     * make some of the GPIO pins be outputs
-     */
-    lmc_gpio_mkoutput(sc, LMC_GEP_RESET);
-
-    /*
-     * RESET low to force state reset.  This also forces
-     * the transmitter clock to be internal, but we expect to reset
-     * that later anyway.
-     */
-    sc->lmc_gpio &=3D ~(LMC_GEP_RESET);
-    LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-
-    /*
-     * hold for more than 10 microseconds
-     */
-    udelay(50);
-
-    /*
-     * stop driving Xilinx-related signals
-     */
-    lmc_gpio_mkinput(sc, LMC_GEP_RESET);
-
-    /*
-     * Call media specific init routine
-     */
-    sc->lmc_media->init(sc);
-
-    sc->extra_stats.resetCount++;
-    lmc_trace(sc->lmc_device, "lmc_reset out");
+	lmc_trace(sc->lmc_device, "lmc_reset in");
+	sc->lmc_miireg16 |=3D LMC_MII16_FIFO_RESET;
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+
+	sc->lmc_miireg16 &=3D ~LMC_MII16_FIFO_RESET;
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+
+	/* make some of the GPIO pins be outputs */
+	lmc_gpio_mkoutput(sc, LMC_GEP_RESET);
+
+	/* RESET low to force state reset.  This also forces the transmitter
+	   clock to be internal, but we expect to reset that later anyway. */
+	sc->lmc_gpio &=3D ~(LMC_GEP_RESET);
+	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+	/* hold for more than 10 microseconds */
+	udelay(50);
+
+	/* stop driving Xilinx-related signals */
+	lmc_gpio_mkinput(sc, LMC_GEP_RESET);
+
+	/* Call media specific init routine */
+	sc->lmc_media->init(sc);
+
+	sc->extra_stats.resetCount++;
+	lmc_trace(sc->lmc_device, "lmc_reset out");
 }
=20
-static void lmc_dec_reset(lmc_softc_t * const sc) /*fold00*/
+static void lmc_dec_reset(lmc_softc_t * const sc)
 {
-    u32 val;
-    lmc_trace(sc->lmc_device, "lmc_dec_reset in");
-
-    /*
-     * disable all interrupts
-     */
-    sc->lmc_intrmask =3D 0;
-    LMC_CSR_WRITE(sc, csr_intr, sc->lmc_intrmask);
-
-    /*
-     * Reset the chip with a software reset command.
-     * Wait 10 microseconds (actually 50 PCI cycles but at
-     * 33MHz that comes to two microseconds but wait a
-     * bit longer anyways)
-     */
-    LMC_CSR_WRITE(sc, csr_busmode, TULIP_BUSMODE_SWRESET);
-    udelay(25);
+	u32 val;
+	lmc_trace(sc->lmc_device, "lmc_dec_reset in");
+
+	/* disable all interrupts */
+	sc->lmc_intrmask =3D 0;
+	LMC_CSR_WRITE(sc, csr_intr, sc->lmc_intrmask);
+
+	/* Reset the chip with a software reset command. Wait 10 microseconds
+	   (actually 50 PCI cycles but at 33MHz that comes to two microsecond=
s
+	   but wait a bit longer anyways) */
+	LMC_CSR_WRITE(sc, csr_busmode, TULIP_BUSMODE_SWRESET);
+	udelay(25);
 #ifdef __sparc__
-    sc->lmc_busmode =3D LMC_CSR_READ(sc, csr_busmode);
-    sc->lmc_busmode =3D 0x00100000;
-    sc->lmc_busmode &=3D ~TULIP_BUSMODE_SWRESET;
-    LMC_CSR_WRITE(sc, csr_busmode, sc->lmc_busmode);
+	sc->lmc_busmode =3D LMC_CSR_READ(sc, csr_busmode);
+	sc->lmc_busmode =3D 0x00100000;
+	sc->lmc_busmode &=3D ~TULIP_BUSMODE_SWRESET;
+	LMC_CSR_WRITE(sc, csr_busmode, sc->lmc_busmode);
 #endif
-    sc->lmc_cmdmode =3D LMC_CSR_READ(sc, csr_command);
-
-    /*
-     * We want:
-     *   no ethernet address in frames we write
-     *   disable padding (txdesc, padding disable)
-     *   ignore runt frames (rdes0 bit 15)
-     *   no receiver watchdog or transmitter jabber timer
-     *       (csr15 bit 0,14 =3D=3D 1)
-     *   if using 16-bit CRC, turn off CRC (trans desc, crc disable)
-     */
-
-    sc->lmc_cmdmode |=3D ( TULIP_CMD_PROMISCUOUS
-                         | TULIP_CMD_FULLDUPLEX
-                         | TULIP_CMD_PASSBADPKT
-                         | TULIP_CMD_NOHEARTBEAT
-                         | TULIP_CMD_PORTSELECT
-                         | TULIP_CMD_RECEIVEALL
-                         | TULIP_CMD_MUSTBEONE
-                       );
-    sc->lmc_cmdmode &=3D ~( TULIP_CMD_OPERMODE
-                          | TULIP_CMD_THRESHOLDCTL
-                          | TULIP_CMD_STOREFWD
-                          | TULIP_CMD_TXTHRSHLDCTL
-                        );
-
-    LMC_CSR_WRITE(sc, csr_command, sc->lmc_cmdmode);
-
-    /*
-     * disable receiver watchdog and transmit jabber
-     */
-    val =3D LMC_CSR_READ(sc, csr_sia_general);
-    val |=3D (TULIP_WATCHDOG_TXDISABLE | TULIP_WATCHDOG_RXDISABLE);
-    LMC_CSR_WRITE(sc, csr_sia_general, val);
-
-    lmc_trace(sc->lmc_device, "lmc_dec_reset out");
+	sc->lmc_cmdmode =3D LMC_CSR_READ(sc, csr_command);
+
+	/*
+	 * We want:
+	 *   no ethernet address in frames we write
+	 *   disable padding (txdesc, padding disable)
+	 *   ignore runt frames (rdes0 bit 15)
+	 *   no receiver watchdog or transmitter jabber timer
+	 *       (csr15 bit 0,14 =3D=3D 1)
+	 *   if using 16-bit CRC, turn off CRC (trans desc, crc disable)
+	 */
+
+	sc->lmc_cmdmode |=3D (TULIP_CMD_PROMISCUOUS | TULIP_CMD_FULLDUPLEX |
+			    TULIP_CMD_PASSBADPKT | TULIP_CMD_NOHEARTBEAT |
+			    TULIP_CMD_PORTSELECT | TULIP_CMD_RECEIVEALL |
+			    TULIP_CMD_MUSTBEONE);
+	sc->lmc_cmdmode &=3D ~(TULIP_CMD_OPERMODE | TULIP_CMD_THRESHOLDCTL |
+			     TULIP_CMD_STOREFWD | TULIP_CMD_TXTHRSHLDCTL);
+
+	LMC_CSR_WRITE(sc, csr_command, sc->lmc_cmdmode);
+
+	/* disable receiver watchdog and transmit jabber */
+	val =3D LMC_CSR_READ(sc, csr_sia_general);
+	val |=3D (TULIP_WATCHDOG_TXDISABLE | TULIP_WATCHDOG_RXDISABLE);
+	LMC_CSR_WRITE(sc, csr_sia_general, val);
+
+	lmc_trace(sc->lmc_device, "lmc_dec_reset out");
 }
=20
-static void lmc_initcsrs(lmc_softc_t * const sc, lmc_csrptr_t csr_base=
, /*fold00*/
-                         size_t csr_size)
+static void lmc_initcsrs(lmc_softc_t * const sc, lmc_csrptr_t csr_base=
,
+			 size_t csr_size)
 {
-    lmc_trace(sc->lmc_device, "lmc_initcsrs in");
-    sc->lmc_csrs.csr_busmode	        =3D csr_base +  0 * csr_size;
-    sc->lmc_csrs.csr_txpoll		=3D csr_base +  1 * csr_size;
-    sc->lmc_csrs.csr_rxpoll		=3D csr_base +  2 * csr_size;
-    sc->lmc_csrs.csr_rxlist		=3D csr_base +  3 * csr_size;
-    sc->lmc_csrs.csr_txlist		=3D csr_base +  4 * csr_size;
-    sc->lmc_csrs.csr_status		=3D csr_base +  5 * csr_size;
-    sc->lmc_csrs.csr_command	        =3D csr_base +  6 * csr_size;
-    sc->lmc_csrs.csr_intr		=3D csr_base +  7 * csr_size;
-    sc->lmc_csrs.csr_missed_frames	=3D csr_base +  8 * csr_size;
-    sc->lmc_csrs.csr_9		        =3D csr_base +  9 * csr_size;
-    sc->lmc_csrs.csr_10		        =3D csr_base + 10 * csr_size;
-    sc->lmc_csrs.csr_11		        =3D csr_base + 11 * csr_size;
-    sc->lmc_csrs.csr_12		        =3D csr_base + 12 * csr_size;
-    sc->lmc_csrs.csr_13		        =3D csr_base + 13 * csr_size;
-    sc->lmc_csrs.csr_14		        =3D csr_base + 14 * csr_size;
-    sc->lmc_csrs.csr_15		        =3D csr_base + 15 * csr_size;
-    lmc_trace(sc->lmc_device, "lmc_initcsrs out");
+	lmc_trace(sc->lmc_device, "lmc_initcsrs in");
+	sc->lmc_csrs.csr_busmode	=3D csr_base +  0 * csr_size;
+	sc->lmc_csrs.csr_txpoll		=3D csr_base +  1 * csr_size;
+	sc->lmc_csrs.csr_rxpoll		=3D csr_base +  2 * csr_size;
+	sc->lmc_csrs.csr_rxlist		=3D csr_base +  3 * csr_size;
+	sc->lmc_csrs.csr_txlist		=3D csr_base +  4 * csr_size;
+	sc->lmc_csrs.csr_status		=3D csr_base +  5 * csr_size;
+	sc->lmc_csrs.csr_command	=3D csr_base +  6 * csr_size;
+	sc->lmc_csrs.csr_intr		=3D csr_base +  7 * csr_size;
+	sc->lmc_csrs.csr_missed_frames	=3D csr_base +  8 * csr_size;
+	sc->lmc_csrs.csr_9		=3D csr_base +  9 * csr_size;
+	sc->lmc_csrs.csr_10		=3D csr_base + 10 * csr_size;
+	sc->lmc_csrs.csr_11		=3D csr_base + 11 * csr_size;
+	sc->lmc_csrs.csr_12		=3D csr_base + 12 * csr_size;
+	sc->lmc_csrs.csr_13		=3D csr_base + 13 * csr_size;
+	sc->lmc_csrs.csr_14		=3D csr_base + 14 * csr_size;
+	sc->lmc_csrs.csr_15		=3D csr_base + 15 * csr_size;
+	lmc_trace(sc->lmc_device, "lmc_initcsrs out");
 }
=20
 static void lmc_driver_timeout(struct net_device *dev)
 {
-    lmc_softc_t *sc =3D dev_to_sc(dev);
-    u32 csr6;
-    unsigned long flags;
-
-    lmc_trace(dev, "lmc_driver_timeout in");
+	lmc_softc_t *sc =3D dev_to_sc(dev);
+	u32 csr6;
+	unsigned long flags;
=20
-    spin_lock_irqsave(&sc->lmc_lock, flags);
+	lmc_trace(dev, "lmc_driver_timeout in");
=20
-    printk("%s: Xmitter busy|\n", dev->name);
+	spin_lock_irqsave(&sc->lmc_lock, flags);
=20
-    sc->extra_stats.tx_tbusy_calls++;
-    if (jiffies - dev_trans_start(dev) < TX_TIMEOUT)
-	    goto bug_out;
+	printk(KERN_DEBUG "%s: Xmitter busy|\n", dev->name);
=20
-    /*
-     * Chip seems to have locked up
-     * Reset it
-     * This whips out all our decriptor
-     * table and starts from scartch
-     */
+	sc->extra_stats.tx_tbusy_calls++;
+	if (jiffies - dev_trans_start(dev) < TX_TIMEOUT)
+		goto bug_out;
=20
-    LMC_EVENT_LOG(LMC_EVENT_XMTPRCTMO,
-                  LMC_CSR_READ (sc, csr_status),
-		  sc->extra_stats.tx_ProcTimeout);
+	/* Chip seems to have locked up. Reset it. This whips out all our
+	   decriptor table and starts from scartch. */
=20
-    lmc_running_reset (dev);
+	LMC_EVENT_LOG(LMC_EVENT_XMTPRCTMO, LMC_CSR_READ(sc, csr_status),
+		      sc->extra_stats.tx_ProcTimeout);
=20
-    LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ (sc, csr_status), 0);
-    LMC_EVENT_LOG(LMC_EVENT_RESET2,
-                  lmc_mii_readreg (sc, 0, 16),
-                  lmc_mii_readreg (sc, 0, 17));
+	lmc_running_reset(dev);
=20
-    /* restart the tx processes */
-    csr6 =3D LMC_CSR_READ (sc, csr_command);
-    LMC_CSR_WRITE (sc, csr_command, csr6 | 0x0002);
-    LMC_CSR_WRITE (sc, csr_command, csr6 | 0x2002);
+	LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ(sc, csr_status), 0);
+	LMC_EVENT_LOG(LMC_EVENT_RESET2, lmc_mii_readreg(sc, 0, 16),
+		      lmc_mii_readreg(sc, 0, 17));
=20
-    /* immediate transmit */
-    LMC_CSR_WRITE (sc, csr_txpoll, 0);
+	/* restart the tx processes */
+	csr6 =3D LMC_CSR_READ(sc, csr_command);
+	LMC_CSR_WRITE(sc, csr_command, csr6 | 0x0002);
+	LMC_CSR_WRITE(sc, csr_command, csr6 | 0x2002);
=20
-    sc->lmc_device->stats.tx_errors++;
-    sc->extra_stats.tx_ProcTimeout++; /* -baz */
+	/* immediate transmit */
+	LMC_CSR_WRITE(sc, csr_txpoll, 0);
=20
-    dev->trans_start =3D jiffies; /* prevent tx timeout */
+	sc->lmc_device->stats.tx_errors++;
+	sc->extra_stats.tx_ProcTimeout++;
+	dev->trans_start =3D jiffies; /* prevent tx timeout */
=20
 bug_out:
-
-    spin_unlock_irqrestore(&sc->lmc_lock, flags);
-
-    lmc_trace(dev, "lmc_driver_timout out");
-
-
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
+	lmc_trace(dev, "lmc_driver_timout out");
 }
diff --git a/drivers/net/wan/lmc/lmc_media.c b/drivers/net/wan/lmc/lmc_=
media.c
index 5920c99..a3aa2a0 100644
--- a/drivers/net/wan/lmc/lmc_media.c
+++ b/drivers/net/wan/lmc/lmc_media.c
@@ -1,5 +1,3 @@
-/* $Id: lmc_media.c,v 1.13 2000/04/11 05:25:26 asj Exp $ */
-
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
@@ -8,19 +6,16 @@
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
 #include <linux/in.h>
+#include <linux/io.h>
 #include <linux/if_arp.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/inet.h>
 #include <linux/bitops.h>
-
-#include <asm/processor.h>             /* Processor type for cache ali=
gnment. */
-#include <asm/io.h>
+#include <linux/uaccess.h>
+#include <asm/processor.h>   /* Processor type for cache alignment. */
 #include <asm/dma.h>
-
-#include <asm/uaccess.h>
-
 #include "lmc.h"
 #include "lmc_var.h"
 #include "lmc_ioctl.h"
@@ -28,513 +23,440 @@
=20
 #define CONFIG_LMC_IGNORE_HARDWARE_HANDSHAKE 1
=20
- /*
-  * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
-  * All rights reserved.  www.lanmedia.com
-  *
-  * This code is written by:
-  * Andrew Stanley-Jones (asj@cban.com)
-  * Rob Braun (bbraun@vix.com),
-  * Michael Graff (explorer@vix.com) and
-  * Matt Thomas (matt@3am-software.com).
-  *
-  * This software may be used and distributed according to the terms
-  * of the GNU General Public License version 2, incorporated herein b=
y reference.
-  */
-
 /*
- * protocol independent method.
+ * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
+ * All rights reserved.  www.lanmedia.com
+ *
+ * This code is written by:
+ * Andrew Stanley-Jones (asj@cban.com)
+ * Rob Braun (bbraun@vix.com),
+ * Michael Graff (explorer@vix.com) and
+ * Matt Thomas (matt@3am-software.com).
+ *
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License version 2, incorporated herein by re=
ference.
  */
-static void lmc_set_protocol (lmc_softc_t * const, lmc_ctl_t *);
=20
-/*
- * media independent methods to check on media status, link, light LED=
s,
- * etc.
- */
-static void lmc_ds3_init (lmc_softc_t * const);
-static void lmc_ds3_default (lmc_softc_t * const);
-static void lmc_ds3_set_status (lmc_softc_t * const, lmc_ctl_t *);
-static void lmc_ds3_set_100ft (lmc_softc_t * const, int);
-static int lmc_ds3_get_link_status (lmc_softc_t * const);
-static void lmc_ds3_set_crc_length (lmc_softc_t * const, int);
-static void lmc_ds3_set_scram (lmc_softc_t * const, int);
-static void lmc_ds3_watchdog (lmc_softc_t * const);
-
-static void lmc_hssi_init (lmc_softc_t * const);
-static void lmc_hssi_default (lmc_softc_t * const);
-static void lmc_hssi_set_status (lmc_softc_t * const, lmc_ctl_t *);
-static void lmc_hssi_set_clock (lmc_softc_t * const, int);
-static int lmc_hssi_get_link_status (lmc_softc_t * const);
-static void lmc_hssi_set_link_status (lmc_softc_t * const, int);
-static void lmc_hssi_set_crc_length (lmc_softc_t * const, int);
-static void lmc_hssi_watchdog (lmc_softc_t * const);
-
-static void lmc_ssi_init (lmc_softc_t * const);
-static void lmc_ssi_default (lmc_softc_t * const);
-static void lmc_ssi_set_status (lmc_softc_t * const, lmc_ctl_t *);
-static void lmc_ssi_set_clock (lmc_softc_t * const, int);
-static void lmc_ssi_set_speed (lmc_softc_t * const, lmc_ctl_t *);
-static int lmc_ssi_get_link_status (lmc_softc_t * const);
-static void lmc_ssi_set_link_status (lmc_softc_t * const, int);
-static void lmc_ssi_set_crc_length (lmc_softc_t * const, int);
-static void lmc_ssi_watchdog (lmc_softc_t * const);
-
-static void lmc_t1_init (lmc_softc_t * const);
-static void lmc_t1_default (lmc_softc_t * const);
-static void lmc_t1_set_status (lmc_softc_t * const, lmc_ctl_t *);
-static int lmc_t1_get_link_status (lmc_softc_t * const);
-static void lmc_t1_set_circuit_type (lmc_softc_t * const, int);
-static void lmc_t1_set_crc_length (lmc_softc_t * const, int);
-static void lmc_t1_set_clock (lmc_softc_t * const, int);
-static void lmc_t1_watchdog (lmc_softc_t * const);
-
-static void lmc_dummy_set_1 (lmc_softc_t * const, int);
-static void lmc_dummy_set2_1 (lmc_softc_t * const, lmc_ctl_t *);
-
-static inline void write_av9110_bit (lmc_softc_t *, int);
+/* protocol independent method. */
+static void lmc_set_protocol(lmc_softc_t * const, lmc_ctl_t *);
+
+/* media independent methods to check on media status, link, light LED=
s, etc. */
+static void lmc_ds3_init(lmc_softc_t * const);
+static void lmc_ds3_default(lmc_softc_t * const);
+static void lmc_ds3_set_status(lmc_softc_t * const, lmc_ctl_t *);
+static void lmc_ds3_set_100ft(lmc_softc_t * const, int);
+static int lmc_ds3_get_link_status(lmc_softc_t * const);
+static void lmc_ds3_set_crc_length(lmc_softc_t * const, int);
+static void lmc_ds3_set_scram(lmc_softc_t * const, int);
+static void lmc_ds3_watchdog(lmc_softc_t * const);
+
+static void lmc_hssi_init(lmc_softc_t * const);
+static void lmc_hssi_default(lmc_softc_t * const);
+static void lmc_hssi_set_status(lmc_softc_t * const, lmc_ctl_t *);
+static void lmc_hssi_set_clock(lmc_softc_t * const, int);
+static int lmc_hssi_get_link_status(lmc_softc_t * const);
+static void lmc_hssi_set_link_status(lmc_softc_t * const, int);
+static void lmc_hssi_set_crc_length(lmc_softc_t * const, int);
+static void lmc_hssi_watchdog(lmc_softc_t * const);
+
+static void lmc_ssi_init(lmc_softc_t * const);
+static void lmc_ssi_default(lmc_softc_t * const);
+static void lmc_ssi_set_status(lmc_softc_t * const, lmc_ctl_t *);
+static void lmc_ssi_set_clock(lmc_softc_t * const, int);
+static void lmc_ssi_set_speed(lmc_softc_t * const, lmc_ctl_t *);
+static int lmc_ssi_get_link_status(lmc_softc_t * const);
+static void lmc_ssi_set_link_status(lmc_softc_t * const, int);
+static void lmc_ssi_set_crc_length(lmc_softc_t * const, int);
+static void lmc_ssi_watchdog(lmc_softc_t * const);
+
+static void lmc_t1_init(lmc_softc_t * const);
+static void lmc_t1_default(lmc_softc_t * const);
+static void lmc_t1_set_status(lmc_softc_t * const, lmc_ctl_t *);
+static int lmc_t1_get_link_status(lmc_softc_t * const);
+static void lmc_t1_set_circuit_type(lmc_softc_t * const, int);
+static void lmc_t1_set_crc_length(lmc_softc_t * const, int);
+static void lmc_t1_set_clock(lmc_softc_t * const, int);
+static void lmc_t1_watchdog(lmc_softc_t * const);
+
+static void lmc_dummy_set_1(lmc_softc_t * const, int);
+static void lmc_dummy_set2_1(lmc_softc_t * const, lmc_ctl_t *);
+
+static inline void write_av9110_bit(lmc_softc_t *, int);
 static void write_av9110(lmc_softc_t *, u32, u32, u32, u32, u32);
=20
 lmc_media_t lmc_ds3_media =3D {
-  lmc_ds3_init,			/* special media init stuff */
-  lmc_ds3_default,		/* reset to default state */
-  lmc_ds3_set_status,		/* reset status to state provided */
-  lmc_dummy_set_1,		/* set clock source */
-  lmc_dummy_set2_1,		/* set line speed */
-  lmc_ds3_set_100ft,		/* set cable length */
-  lmc_ds3_set_scram,		/* set scrambler */
-  lmc_ds3_get_link_status,	/* get link status */
-  lmc_dummy_set_1,		/* set link status */
-  lmc_ds3_set_crc_length,	/* set CRC length */
-  lmc_dummy_set_1,		/* set T1 or E1 circuit type */
-  lmc_ds3_watchdog
+	lmc_ds3_init,		/* special media init stuff */
+	lmc_ds3_default,	/* reset to default state */
+	lmc_ds3_set_status,	/* reset status to state provided */
+	lmc_dummy_set_1,	/* set clock source */
+	lmc_dummy_set2_1,	/* set line speed */
+	lmc_ds3_set_100ft,	/* set cable length */
+	lmc_ds3_set_scram,	/* set scrambler */
+	lmc_ds3_get_link_status, /* get link status */
+	lmc_dummy_set_1,	/* set link status */
+	lmc_ds3_set_crc_length,	/* set CRC length */
+	lmc_dummy_set_1,	/* set T1 or E1 circuit type */
+	lmc_ds3_watchdog
 };
=20
 lmc_media_t lmc_hssi_media =3D {
-  lmc_hssi_init,		/* special media init stuff */
-  lmc_hssi_default,		/* reset to default state */
-  lmc_hssi_set_status,		/* reset status to state provided */
-  lmc_hssi_set_clock,		/* set clock source */
-  lmc_dummy_set2_1,		/* set line speed */
-  lmc_dummy_set_1,		/* set cable length */
-  lmc_dummy_set_1,		/* set scrambler */
-  lmc_hssi_get_link_status,	/* get link status */
-  lmc_hssi_set_link_status,	/* set link status */
-  lmc_hssi_set_crc_length,	/* set CRC length */
-  lmc_dummy_set_1,		/* set T1 or E1 circuit type */
-  lmc_hssi_watchdog
+	lmc_hssi_init,		/* special media init stuff */
+	lmc_hssi_default,	/* reset to default state */
+	lmc_hssi_set_status,	/* reset status to state provided */
+	lmc_hssi_set_clock,	/* set clock source */
+	lmc_dummy_set2_1,	/* set line speed */
+	lmc_dummy_set_1,	/* set cable length */
+	lmc_dummy_set_1,	/* set scrambler */
+	lmc_hssi_get_link_status, /* get link status */
+	lmc_hssi_set_link_status, /* set link status */
+	lmc_hssi_set_crc_length, /* set CRC length */
+	lmc_dummy_set_1,	/* set T1 or E1 circuit type */
+	lmc_hssi_watchdog
 };
=20
-lmc_media_t lmc_ssi_media =3D { lmc_ssi_init,	/* special media init st=
uff */
-  lmc_ssi_default,		/* reset to default state */
-  lmc_ssi_set_status,		/* reset status to state provided */
-  lmc_ssi_set_clock,		/* set clock source */
-  lmc_ssi_set_speed,		/* set line speed */
-  lmc_dummy_set_1,		/* set cable length */
-  lmc_dummy_set_1,		/* set scrambler */
-  lmc_ssi_get_link_status,	/* get link status */
-  lmc_ssi_set_link_status,	/* set link status */
-  lmc_ssi_set_crc_length,	/* set CRC length */
-  lmc_dummy_set_1,		/* set T1 or E1 circuit type */
-  lmc_ssi_watchdog
+lmc_media_t lmc_ssi_media =3D {
+	lmc_ssi_init,		/* special media init stuff */
+	lmc_ssi_default,	/* reset to default state */
+	lmc_ssi_set_status,	/* reset status to state provided */
+	lmc_ssi_set_clock,	/* set clock source */
+	lmc_ssi_set_speed,	/* set line speed */
+	lmc_dummy_set_1,	/* set cable length */
+	lmc_dummy_set_1,	/* set scrambler */
+	lmc_ssi_get_link_status, /* get link status */
+	lmc_ssi_set_link_status, /* set link status */
+	lmc_ssi_set_crc_length,	/* set CRC length */
+	lmc_dummy_set_1,	/* set T1 or E1 circuit type */
+	lmc_ssi_watchdog
 };
=20
 lmc_media_t lmc_t1_media =3D {
-  lmc_t1_init,			/* special media init stuff */
-  lmc_t1_default,		/* reset to default state */
-  lmc_t1_set_status,		/* reset status to state provided */
-  lmc_t1_set_clock,		/* set clock source */
-  lmc_dummy_set2_1,		/* set line speed */
-  lmc_dummy_set_1,		/* set cable length */
-  lmc_dummy_set_1,		/* set scrambler */
-  lmc_t1_get_link_status,	/* get link status */
-  lmc_dummy_set_1,		/* set link status */
-  lmc_t1_set_crc_length,	/* set CRC length */
-  lmc_t1_set_circuit_type,	/* set T1 or E1 circuit type */
-  lmc_t1_watchdog
+	lmc_t1_init,		/* special media init stuff */
+	lmc_t1_default,		/* reset to default state */
+	lmc_t1_set_status,	/* reset status to state provided */
+	lmc_t1_set_clock,	/* set clock source */
+	lmc_dummy_set2_1,	/* set line speed */
+	lmc_dummy_set_1,	/* set cable length */
+	lmc_dummy_set_1,	/* set scrambler */
+	lmc_t1_get_link_status,	/* get link status */
+	lmc_dummy_set_1,	/* set link status */
+	lmc_t1_set_crc_length,	/* set CRC length */
+	lmc_t1_set_circuit_type, /* set T1 or E1 circuit type */
+	lmc_t1_watchdog
 };
=20
-static void
-lmc_dummy_set_1 (lmc_softc_t * const sc, int a)
+static void lmc_dummy_set_1(lmc_softc_t * const sc, int a)
 {
 }
=20
-static void
-lmc_dummy_set2_1 (lmc_softc_t * const sc, lmc_ctl_t * a)
+static void lmc_dummy_set2_1(lmc_softc_t * const sc, lmc_ctl_t * a)
 {
 }
=20
-/*
- *  HSSI methods
- */
+/* HSSI methods */
=20
-static void
-lmc_hssi_init (lmc_softc_t * const sc)
+static void lmc_hssi_init(lmc_softc_t * const sc)
 {
-  sc->ictl.cardtype =3D LMC_CTL_CARDTYPE_LMC5200;
-
-  lmc_gpio_mkoutput (sc, LMC_GEP_HSSI_CLOCK);
+	sc->ictl.cardtype =3D LMC_CTL_CARDTYPE_LMC5200;
+	lmc_gpio_mkoutput(sc, LMC_GEP_HSSI_CLOCK);
 }
=20
-static void
-lmc_hssi_default (lmc_softc_t * const sc)
+static void lmc_hssi_default(lmc_softc_t * const sc)
 {
-  sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
+	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
=20
-  sc->lmc_media->set_link_status (sc, LMC_LINK_DOWN);
-  sc->lmc_media->set_clock_source (sc, LMC_CTL_CLOCK_SOURCE_EXT);
-  sc->lmc_media->set_crc_length (sc, LMC_CTL_CRC_LENGTH_16);
+	sc->lmc_media->set_link_status(sc, LMC_LINK_DOWN);
+	sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_EXT);
+	sc->lmc_media->set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
 }
=20
-/*
- * Given a user provided state, set ourselves up to match it.  This wi=
ll
- * always reset the card if needed.
- */
-static void
-lmc_hssi_set_status (lmc_softc_t * const sc, lmc_ctl_t * ctl)
+/* Given a user provided state, set ourselves up to match it.
+   This will always reset the card if needed. */
+static void lmc_hssi_set_status(lmc_softc_t * const sc, lmc_ctl_t * ct=
l)
 {
-  if (ctl =3D=3D NULL)
-    {
-      sc->lmc_media->set_clock_source (sc, sc->ictl.clock_source);
-      lmc_set_protocol (sc, NULL);
-
-      return;
-    }
-
-  /*
-   * check for change in clock source
-   */
-  if (ctl->clock_source && !sc->ictl.clock_source)
-    {
-      sc->lmc_media->set_clock_source (sc, LMC_CTL_CLOCK_SOURCE_INT);
-      sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_INT;
-    }
-  else if (!ctl->clock_source && sc->ictl.clock_source)
-    {
-      sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
-      sc->lmc_media->set_clock_source (sc, LMC_CTL_CLOCK_SOURCE_EXT);
-    }
-
-  lmc_set_protocol (sc, ctl);
+	if (ctl =3D=3D NULL) {
+		sc->lmc_media->set_clock_source(sc, sc->ictl.clock_source);
+		lmc_set_protocol(sc, NULL);
+
+		return;
+	}
+
+	/* check for change in clock source */
+	if (ctl->clock_source && !sc->ictl.clock_source) {
+		sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_INT);
+		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_INT;
+	} else if (!ctl->clock_source && sc->ictl.clock_source) {
+		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
+		sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_EXT);
+	}
+
+	lmc_set_protocol(sc, ctl);
 }
=20
-/*
- * 1 =3D=3D internal, 0 =3D=3D external
- */
-static void
-lmc_hssi_set_clock (lmc_softc_t * const sc, int ie)
+/* 1 =3D=3D internal, 0 =3D=3D external */
+static void lmc_hssi_set_clock(lmc_softc_t * const sc, int ie)
 {
-  int old;
-  old =3D sc->ictl.clock_source;
-  if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT)
-    {
-      sc->lmc_gpio |=3D LMC_GEP_HSSI_CLOCK;
-      LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
-      sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
-      if(old !=3D ie)
-        printk (LMC_PRINTF_FMT ": clock external\n", LMC_PRINTF_ARGS);
-    }
-  else
-    {
-      sc->lmc_gpio &=3D ~(LMC_GEP_HSSI_CLOCK);
-      LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
-      sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
-      if(old !=3D ie)
-        printk (LMC_PRINTF_FMT ": clock internal\n", LMC_PRINTF_ARGS);
-    }
+	int old;
+	old =3D sc->ictl.clock_source;
+	if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
+		sc->lmc_gpio |=3D LMC_GEP_HSSI_CLOCK;
+		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
+		if (old !=3D ie)
+			printk(LMC_PRINTF_FMT ": clock external\n",
+			       LMC_PRINTF_ARGS);
+	} else {
+		sc->lmc_gpio &=3D ~(LMC_GEP_HSSI_CLOCK);
+		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
+		if (old !=3D ie)
+			printk(LMC_PRINTF_FMT ": clock internal\n",
+			       LMC_PRINTF_ARGS);
+	}
 }
=20
-/*
- * return hardware link status.
- * 0 =3D=3D link is down, 1 =3D=3D link is up.
- */
-static int
-lmc_hssi_get_link_status (lmc_softc_t * const sc)
+/* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
+static int lmc_hssi_get_link_status(lmc_softc_t * const sc)
 {
-    /*
-     * We're using the same code as SSI since
-     * they're practically the same
-     */
-    return lmc_ssi_get_link_status(sc);
+	/* We're using the same code as SSI since they're practically
+	   the same */
+	return lmc_ssi_get_link_status(sc);
 }
=20
-static void
-lmc_hssi_set_link_status (lmc_softc_t * const sc, int state)
+static void lmc_hssi_set_link_status(lmc_softc_t * const sc, int state=
)
 {
-  if (state =3D=3D LMC_LINK_UP)
-    sc->lmc_miireg16 |=3D LMC_MII16_HSSI_TA;
-  else
-    sc->lmc_miireg16 &=3D ~LMC_MII16_HSSI_TA;
+	if (state =3D=3D LMC_LINK_UP)
+		sc->lmc_miireg16 |=3D LMC_MII16_HSSI_TA;
+	else
+		sc->lmc_miireg16 &=3D ~LMC_MII16_HSSI_TA;
=20
-  lmc_mii_writereg (sc, 0, 16, sc->lmc_miireg16);
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-/*
- * 0 =3D=3D 16bit, 1 =3D=3D 32bit
- */
-static void
-lmc_hssi_set_crc_length (lmc_softc_t * const sc, int state)
+/* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
+static void lmc_hssi_set_crc_length(lmc_softc_t * const sc, int state)
 {
-  if (state =3D=3D LMC_CTL_CRC_LENGTH_32)
-    {
-      /* 32 bit */
-      sc->lmc_miireg16 |=3D LMC_MII16_HSSI_CRC;
-      sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
-    }
-  else
-    {
-      /* 16 bit */
-      sc->lmc_miireg16 &=3D ~LMC_MII16_HSSI_CRC;
-      sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
-    }
-
-  lmc_mii_writereg (sc, 0, 16, sc->lmc_miireg16);
+	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
+		/* 32 bit */
+		sc->lmc_miireg16 |=3D LMC_MII16_HSSI_CRC;
+		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
+	} else {
+		/* 16 bit */
+		sc->lmc_miireg16 &=3D ~LMC_MII16_HSSI_CRC;
+		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
+	}
+
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-static void
-lmc_hssi_watchdog (lmc_softc_t * const sc)
+static void lmc_hssi_watchdog(lmc_softc_t * const sc)
 {
-  /* HSSI is blank */
+	/* HSSI is blank */
 }
=20
-/*
- *  DS3 methods
- */
+/* DS3 methods */
=20
-/*
- * Set cable length
- */
-static void
-lmc_ds3_set_100ft (lmc_softc_t * const sc, int ie)
+/* Set cable length */
+static void lmc_ds3_set_100ft(lmc_softc_t * const sc, int ie)
 {
-  if (ie =3D=3D LMC_CTL_CABLE_LENGTH_GT_100FT)
-    {
-      sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_ZERO;
-      sc->ictl.cable_length =3D LMC_CTL_CABLE_LENGTH_GT_100FT;
-    }
-  else if (ie =3D=3D LMC_CTL_CABLE_LENGTH_LT_100FT)
-    {
-      sc->lmc_miireg16 |=3D LMC_MII16_DS3_ZERO;
-      sc->ictl.cable_length =3D LMC_CTL_CABLE_LENGTH_LT_100FT;
-    }
-  lmc_mii_writereg (sc, 0, 16, sc->lmc_miireg16);
+	if (ie =3D=3D LMC_CTL_CABLE_LENGTH_GT_100FT) {
+		sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_ZERO;
+		sc->ictl.cable_length =3D LMC_CTL_CABLE_LENGTH_GT_100FT;
+	} else if (ie =3D=3D LMC_CTL_CABLE_LENGTH_LT_100FT) {
+		sc->lmc_miireg16 |=3D LMC_MII16_DS3_ZERO;
+		sc->ictl.cable_length =3D LMC_CTL_CABLE_LENGTH_LT_100FT;
+	}
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-static void
-lmc_ds3_default (lmc_softc_t * const sc)
+static void lmc_ds3_default(lmc_softc_t * const sc)
 {
-  sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
+	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
=20
-  sc->lmc_media->set_link_status (sc, LMC_LINK_DOWN);
-  sc->lmc_media->set_cable_length (sc, LMC_CTL_CABLE_LENGTH_LT_100FT);
-  sc->lmc_media->set_scrambler (sc, LMC_CTL_OFF);
-  sc->lmc_media->set_crc_length (sc, LMC_CTL_CRC_LENGTH_16);
+	sc->lmc_media->set_link_status(sc, LMC_LINK_DOWN);
+	sc->lmc_media->set_cable_length(sc, LMC_CTL_CABLE_LENGTH_LT_100FT);
+	sc->lmc_media->set_scrambler(sc, LMC_CTL_OFF);
+	sc->lmc_media->set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
 }
=20
-/*
- * Given a user provided state, set ourselves up to match it.  This wi=
ll
- * always reset the card if needed.
- */
-static void
-lmc_ds3_set_status (lmc_softc_t * const sc, lmc_ctl_t * ctl)
+/* Given a user provided state, set ourselves up to match it.
+   This will always reset the card if needed. */
+static void lmc_ds3_set_status(lmc_softc_t * const sc, lmc_ctl_t * ctl=
)
 {
-  if (ctl =3D=3D NULL)
-    {
-      sc->lmc_media->set_cable_length (sc, sc->ictl.cable_length);
-      sc->lmc_media->set_scrambler (sc, sc->ictl.scrambler_onoff);
-      lmc_set_protocol (sc, NULL);
-
-      return;
-    }
-
-  /*
-   * check for change in cable length setting
-   */
-  if (ctl->cable_length && !sc->ictl.cable_length)
-    lmc_ds3_set_100ft (sc, LMC_CTL_CABLE_LENGTH_GT_100FT);
-  else if (!ctl->cable_length && sc->ictl.cable_length)
-    lmc_ds3_set_100ft (sc, LMC_CTL_CABLE_LENGTH_LT_100FT);
-
-  /*
-   * Check for change in scrambler setting (requires reset)
-   */
-  if (ctl->scrambler_onoff && !sc->ictl.scrambler_onoff)
-    lmc_ds3_set_scram (sc, LMC_CTL_ON);
-  else if (!ctl->scrambler_onoff && sc->ictl.scrambler_onoff)
-    lmc_ds3_set_scram (sc, LMC_CTL_OFF);
-
-  lmc_set_protocol (sc, ctl);
+	if (ctl =3D=3D NULL) {
+		sc->lmc_media->set_cable_length(sc, sc->ictl.cable_length);
+		sc->lmc_media->set_scrambler(sc, sc->ictl.scrambler_onoff);
+		lmc_set_protocol(sc, NULL);
+		return;
+	}
+
+	/* check for change in cable length setting */
+	if (ctl->cable_length && !sc->ictl.cable_length)
+		lmc_ds3_set_100ft(sc, LMC_CTL_CABLE_LENGTH_GT_100FT);
+	else if (!ctl->cable_length && sc->ictl.cable_length)
+		lmc_ds3_set_100ft(sc, LMC_CTL_CABLE_LENGTH_LT_100FT);
+
+	/* Check for change in scrambler setting (requires reset) */
+	if (ctl->scrambler_onoff && !sc->ictl.scrambler_onoff)
+		lmc_ds3_set_scram(sc, LMC_CTL_ON);
+	else if (!ctl->scrambler_onoff && sc->ictl.scrambler_onoff)
+		lmc_ds3_set_scram(sc, LMC_CTL_OFF);
+
+	lmc_set_protocol(sc, ctl);
 }
=20
-static void
-lmc_ds3_init (lmc_softc_t * const sc)
+static void lmc_ds3_init(lmc_softc_t * const sc)
 {
-  int i;
+	int i;
=20
-  sc->ictl.cardtype =3D LMC_CTL_CARDTYPE_LMC5245;
+	sc->ictl.cardtype =3D LMC_CTL_CARDTYPE_LMC5245;
=20
-  /* writes zeros everywhere */
-  for (i =3D 0; i < 21; i++)
-    {
-      lmc_mii_writereg (sc, 0, 17, i);
-      lmc_mii_writereg (sc, 0, 18, 0);
-    }
+	/* writes zeros everywhere */
+	for (i =3D 0; i < 21; i++) {
+		lmc_mii_writereg(sc, 0, 17, i);
+		lmc_mii_writereg(sc, 0, 18, 0);
+	}
=20
-  /* set some essential bits */
-  lmc_mii_writereg (sc, 0, 17, 1);
-  lmc_mii_writereg (sc, 0, 18, 0x25);	/* ser, xtx */
+	/* set some essential bits */
+	lmc_mii_writereg(sc, 0, 17, 1);
+	lmc_mii_writereg(sc, 0, 18, 0x25);	/* ser, xtx */
=20
-  lmc_mii_writereg (sc, 0, 17, 5);
-  lmc_mii_writereg (sc, 0, 18, 0x80);	/* emode */
+	lmc_mii_writereg(sc, 0, 17, 5);
+	lmc_mii_writereg(sc, 0, 18, 0x80);	/* emode */
=20
-  lmc_mii_writereg (sc, 0, 17, 14);
-  lmc_mii_writereg (sc, 0, 18, 0x30);	/* rcgen, tcgen */
+	lmc_mii_writereg(sc, 0, 17, 14);
+	lmc_mii_writereg(sc, 0, 18, 0x30);	/* rcgen, tcgen */
=20
-  /* clear counters and latched bits */
-  for (i =3D 0; i < 21; i++)
-    {
-      lmc_mii_writereg (sc, 0, 17, i);
-      lmc_mii_readreg (sc, 0, 18);
-    }
+	/* clear counters and latched bits */
+	for (i =3D 0; i < 21; i++) {
+		lmc_mii_writereg(sc, 0, 17, i);
+		lmc_mii_readreg(sc, 0, 18);
+	}
 }
=20
-/*
- * 1 =3D=3D DS3 payload scrambled, 0 =3D=3D not scrambled
- */
-static void
-lmc_ds3_set_scram (lmc_softc_t * const sc, int ie)
+/* 1 =3D=3D DS3 payload scrambled, 0 =3D=3D not scrambled */
+static void lmc_ds3_set_scram(lmc_softc_t * const sc, int ie)
 {
-  if (ie =3D=3D LMC_CTL_ON)
-    {
-      sc->lmc_miireg16 |=3D LMC_MII16_DS3_SCRAM;
-      sc->ictl.scrambler_onoff =3D LMC_CTL_ON;
-    }
-  else
-    {
-      sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_SCRAM;
-      sc->ictl.scrambler_onoff =3D LMC_CTL_OFF;
-    }
-  lmc_mii_writereg (sc, 0, 16, sc->lmc_miireg16);
+	if (ie =3D=3D LMC_CTL_ON) {
+		sc->lmc_miireg16 |=3D LMC_MII16_DS3_SCRAM;
+		sc->ictl.scrambler_onoff =3D LMC_CTL_ON;
+	} else {
+		sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_SCRAM;
+		sc->ictl.scrambler_onoff =3D LMC_CTL_OFF;
+	}
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-/*
- * return hardware link status.
- * 0 =3D=3D link is down, 1 =3D=3D link is up.
- */
-static int
-lmc_ds3_get_link_status (lmc_softc_t * const sc)
+/* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
+static int lmc_ds3_get_link_status(lmc_softc_t * const sc)
 {
-    u16 link_status, link_status_11;
-    int ret =3D 1;
-
-    lmc_mii_writereg (sc, 0, 17, 7);
-    link_status =3D lmc_mii_readreg (sc, 0, 18);
-
-    /* LMC5245 (DS3) & LMC1200 (DS1) LED definitions
-     * led0 yellow =3D far-end adapter is in Red alarm condition
-     * led1 blue   =3D received an Alarm Indication signal
-     *               (upstream failure)
-     * led2 Green  =3D power to adapter, Gate Array loaded & driver
-     *               attached
-     * led3 red    =3D Loss of Signal (LOS) or out of frame (OOF)
-     *               conditions detected on T3 receive signal
-     */
-
-    lmc_led_on(sc, LMC_DS3_LED2);
-
-    if ((link_status & LMC_FRAMER_REG0_DLOS) ||
-        (link_status & LMC_FRAMER_REG0_OOFS)){
-        ret =3D 0;
-        if(sc->last_led_err[3] !=3D 1){
-	    u16 r1;
-            lmc_mii_writereg (sc, 0, 17, 01); /* Turn on Xbit error as=
 our cisco does */
-            r1 =3D lmc_mii_readreg (sc, 0, 18);
-            r1 &=3D 0xfe;
-            lmc_mii_writereg(sc, 0, 18, r1);
-            printk(KERN_WARNING "%s: Red Alarm - Loss of Signal or Los=
s of Framing\n", sc->name);
-        }
-        lmc_led_on(sc, LMC_DS3_LED3);	/* turn on red LED */
-        sc->last_led_err[3] =3D 1;
-    }
-    else {
-        lmc_led_off(sc, LMC_DS3_LED3);	/* turn on red LED */
-        if(sc->last_led_err[3] =3D=3D 1){
-	    u16 r1;
-            lmc_mii_writereg (sc, 0, 17, 01); /* Turn off Xbit error *=
/
-            r1 =3D lmc_mii_readreg (sc, 0, 18);
-            r1 |=3D 0x01;
-            lmc_mii_writereg(sc, 0, 18, r1);
-        }
-        sc->last_led_err[3] =3D 0;
-    }
-
-    lmc_mii_writereg(sc, 0, 17, 0x10);
-    link_status_11 =3D lmc_mii_readreg(sc, 0, 18);
-    if((link_status & LMC_FRAMER_REG0_AIS) ||
-       (link_status_11 & LMC_FRAMER_REG10_XBIT)) {
-        ret =3D 0;
-        if(sc->last_led_err[0] !=3D 1){
-            printk(KERN_WARNING "%s: AIS Alarm or XBit Error\n", sc->n=
ame);
-            printk(KERN_WARNING "%s: Remote end has loss of signal or =
framing\n", sc->name);
-        }
-        lmc_led_on(sc, LMC_DS3_LED0);
-        sc->last_led_err[0] =3D 1;
-    }
-    else {
-        lmc_led_off(sc, LMC_DS3_LED0);
-        sc->last_led_err[0] =3D 0;
-    }
-
-    lmc_mii_writereg (sc, 0, 17, 9);
-    link_status =3D lmc_mii_readreg (sc, 0, 18);
-   =20
-    if(link_status & LMC_FRAMER_REG9_RBLUE){
-        ret =3D 0;
-        if(sc->last_led_err[1] !=3D 1){
-            printk(KERN_WARNING "%s: Blue Alarm - Receiving all 1's\n"=
, sc->name);
-        }
-        lmc_led_on(sc, LMC_DS3_LED1);
-        sc->last_led_err[1] =3D 1;
-    }
-    else {
-        lmc_led_off(sc, LMC_DS3_LED1);
-        sc->last_led_err[1] =3D 0;
-    }
-
-    return ret;
+	u16 link_status, link_status_11;
+	int ret =3D 1;
+
+	lmc_mii_writereg(sc, 0, 17, 7);
+	link_status =3D lmc_mii_readreg(sc, 0, 18);
+
+	/* LMC5245 (DS3) & LMC1200 (DS1) LED definitions
+	 * led0 yellow =3D far-end adapter is in Red alarm condition
+	 * led1 blue   =3D received an Alarm Indication signal
+	 *               (upstream failure)
+	 * led2 Green  =3D power to adapter, Gate Array loaded & driver
+	 *               attached
+	 * led3 red    =3D Loss of Signal (LOS) or out of frame (OOF)
+	 *               conditions detected on T3 receive signal */
+
+	lmc_led_on(sc, LMC_DS3_LED2);
+
+	if ((link_status & LMC_FRAMER_REG0_DLOS) ||
+	    (link_status & LMC_FRAMER_REG0_OOFS)) {
+		ret =3D 0;
+		if (sc->last_led_err[3] !=3D 1) {
+			u16 r1;
+
+			 /* Turn on Xbit error as our cisco does */
+			lmc_mii_writereg(sc, 0, 17, 01);
+			r1 =3D lmc_mii_readreg(sc, 0, 18);
+			r1 &=3D 0xfe;
+			lmc_mii_writereg(sc, 0, 18, r1);
+			printk(KERN_WARNING
+			       "%s: Red Alarm - Loss of Signal or Loss of Framing\n",
+			       sc->name);
+		}
+		lmc_led_on(sc, LMC_DS3_LED3);	/* turn on red LED */
+		sc->last_led_err[3] =3D 1;
+	} else {
+		lmc_led_off(sc, LMC_DS3_LED3);	/* turn on red LED */
+		if (sc->last_led_err[3] =3D=3D 1) {
+			u16 r1;
+			/* Turn off Xbit error */
+			lmc_mii_writereg(sc, 0, 17, 01);
+			r1 =3D lmc_mii_readreg(sc, 0, 18);
+			r1 |=3D 0x01;
+			lmc_mii_writereg(sc, 0, 18, r1);
+		}
+		sc->last_led_err[3] =3D 0;
+	}
+
+	lmc_mii_writereg(sc, 0, 17, 0x10);
+	link_status_11 =3D lmc_mii_readreg(sc, 0, 18);
+	if ((link_status & LMC_FRAMER_REG0_AIS) ||
+	   (link_status_11 & LMC_FRAMER_REG10_XBIT)) {
+		ret =3D 0;
+		if (sc->last_led_err[0] !=3D 1) {
+			printk(KERN_WARNING
+			       "%s: AIS Alarm or XBit Error\n", sc->name);
+			printk(KERN_WARNING
+			       "%s: Remote end has loss of signal or framing\n",
+			       sc->name);
+		}
+		lmc_led_on(sc, LMC_DS3_LED0);
+		sc->last_led_err[0] =3D 1;
+	} else {
+		lmc_led_off(sc, LMC_DS3_LED0);
+		sc->last_led_err[0] =3D 0;
+	}
+
+	lmc_mii_writereg(sc, 0, 17, 9);
+	link_status =3D lmc_mii_readreg(sc, 0, 18);
+
+	if (link_status & LMC_FRAMER_REG9_RBLUE) {
+		ret =3D 0;
+		if (sc->last_led_err[1] !=3D 1) {
+			printk(KERN_WARNING
+			       "%s: Blue Alarm - Receiving all 1's\n",
+			       sc->name);
+		}
+		lmc_led_on(sc, LMC_DS3_LED1);
+		sc->last_led_err[1] =3D 1;
+	} else {
+		lmc_led_off(sc, LMC_DS3_LED1);
+		sc->last_led_err[1] =3D 0;
+	}
+
+	return ret;
 }
=20
-/*
- * 0 =3D=3D 16bit, 1 =3D=3D 32bit
- */
-static void
-lmc_ds3_set_crc_length (lmc_softc_t * const sc, int state)
+/* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
+static void lmc_ds3_set_crc_length(lmc_softc_t * const sc, int state)
 {
-  if (state =3D=3D LMC_CTL_CRC_LENGTH_32)
-    {
-      /* 32 bit */
-      sc->lmc_miireg16 |=3D LMC_MII16_DS3_CRC;
-      sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
-    }
-  else
-    {
-      /* 16 bit */
-      sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_CRC;
-      sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
-    }
-
-  lmc_mii_writereg (sc, 0, 16, sc->lmc_miireg16);
+	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
+		/* 32 bit */
+		sc->lmc_miireg16 |=3D LMC_MII16_DS3_CRC;
+		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
+	} else {
+		/* 16 bit */
+		sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_CRC;
+		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
+	}
+
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-static void
-lmc_ds3_watchdog (lmc_softc_t * const sc)
+static void lmc_ds3_watchdog(lmc_softc_t * const sc)
 {
-   =20
 }
=20
=20
-/*
- *  SSI methods
- */
+/* SSI methods */
=20
 static void lmc_ssi_init(lmc_softc_t * const sc)
 {
@@ -551,333 +473,274 @@ static void lmc_ssi_init(lmc_softc_t * const sc=
)
 	lmc_gpio_mkoutput(sc, LMC_GEP_SSI_TXCLOCK);
 }
=20
-static void
-lmc_ssi_default (lmc_softc_t * const sc)
+static void lmc_ssi_default(lmc_softc_t * const sc)
 {
-  sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
+	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
=20
-  /*
-   * make TXCLOCK always be an output
-   */
-  lmc_gpio_mkoutput (sc, LMC_GEP_SSI_TXCLOCK);
+	/* make TXCLOCK always be an output */
+	lmc_gpio_mkoutput(sc, LMC_GEP_SSI_TXCLOCK);
=20
-  sc->lmc_media->set_link_status (sc, LMC_LINK_DOWN);
-  sc->lmc_media->set_clock_source (sc, LMC_CTL_CLOCK_SOURCE_EXT);
-  sc->lmc_media->set_speed (sc, NULL);
-  sc->lmc_media->set_crc_length (sc, LMC_CTL_CRC_LENGTH_16);
+	sc->lmc_media->set_link_status(sc, LMC_LINK_DOWN);
+	sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_EXT);
+	sc->lmc_media->set_speed(sc, NULL);
+	sc->lmc_media->set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
 }
=20
-/*
- * Given a user provided state, set ourselves up to match it.  This wi=
ll
- * always reset the card if needed.
- */
-static void
-lmc_ssi_set_status (lmc_softc_t * const sc, lmc_ctl_t * ctl)
+/* Given a user provided state, set ourselves up to match it.
+   This will always reset the card if needed. */
+static void lmc_ssi_set_status(lmc_softc_t * const sc, lmc_ctl_t * ctl=
)
 {
-  if (ctl =3D=3D NULL)
-    {
-      sc->lmc_media->set_clock_source (sc, sc->ictl.clock_source);
-      sc->lmc_media->set_speed (sc, &sc->ictl);
-      lmc_set_protocol (sc, NULL);
-
-      return;
-    }
-
-  /*
-   * check for change in clock source
-   */
-  if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT
-      && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT)
-    {
-      sc->lmc_media->set_clock_source (sc, LMC_CTL_CLOCK_SOURCE_INT);
-      sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_INT;
-    }
-  else if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT
-	   && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT)
-    {
-      sc->lmc_media->set_clock_source (sc, LMC_CTL_CLOCK_SOURCE_EXT);
-      sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
-    }
-
-  if (ctl->clock_rate !=3D sc->ictl.clock_rate)
-    sc->lmc_media->set_speed (sc, ctl);
-
-  lmc_set_protocol (sc, ctl);
+	if (ctl =3D=3D NULL) {
+		sc->lmc_media->set_clock_source(sc, sc->ictl.clock_source);
+		sc->lmc_media->set_speed(sc, &sc->ictl);
+		lmc_set_protocol(sc, NULL);
+		return;
+	}
+
+	/* check for change in clock source */
+	if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT
+	    && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
+		sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_INT);
+		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_INT;
+	} else if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT
+		 && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT) {
+		sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_EXT);
+		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
+	}
+
+	if (ctl->clock_rate !=3D sc->ictl.clock_rate)
+		sc->lmc_media->set_speed(sc, ctl);
+
+	lmc_set_protocol(sc, ctl);
 }
=20
-/*
- * 1 =3D=3D internal, 0 =3D=3D external
- */
-static void
-lmc_ssi_set_clock (lmc_softc_t * const sc, int ie)
+/* 1 =3D=3D internal, 0 =3D=3D external */
+static void lmc_ssi_set_clock(lmc_softc_t * const sc, int ie)
 {
-  int old;
-  old =3D ie;
-  if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT)
-    {
-      sc->lmc_gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
-      LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
-      sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
-      if(ie !=3D old)
-        printk (LMC_PRINTF_FMT ": clock external\n", LMC_PRINTF_ARGS);
-    }
-  else
-    {
-      sc->lmc_gpio |=3D LMC_GEP_SSI_TXCLOCK;
-      LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
-      sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
-      if(ie !=3D old)
-        printk (LMC_PRINTF_FMT ": clock internal\n", LMC_PRINTF_ARGS);
-    }
+	int old;
+	old =3D ie;
+	if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
+		sc->lmc_gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
+		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
+		if (ie !=3D old)
+			printk(LMC_PRINTF_FMT ": clock external\n",
+			       LMC_PRINTF_ARGS);
+	} else {
+		sc->lmc_gpio |=3D LMC_GEP_SSI_TXCLOCK;
+		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
+		if (ie !=3D old)
+			printk(LMC_PRINTF_FMT ": clock internal\n",
+			       LMC_PRINTF_ARGS);
+	}
 }
=20
-static void
-lmc_ssi_set_speed (lmc_softc_t * const sc, lmc_ctl_t * ctl)
+static void lmc_ssi_set_speed(lmc_softc_t * const sc, lmc_ctl_t * ctl)
 {
-  lmc_ctl_t *ictl =3D &sc->ictl;
-  lmc_av9110_t *av;
-
-  /* original settings for clock rate of:
-   *  100 Khz (8,25,0,0,2) were incorrect
-   *  they should have been 80,125,1,3,3
-   *  There are 17 param combinations to produce this freq.
-   *  For 1.5 Mhz use 120,100,1,1,2 (226 param. combinations)
-   */
-  if (ctl =3D=3D NULL)
-    {
-      av =3D &ictl->cardspec.ssi;
-      ictl->clock_rate =3D 1500000;
-      av->f =3D ictl->clock_rate;
-      av->n =3D 120;
-      av->m =3D 100;
-      av->v =3D 1;
-      av->x =3D 1;
-      av->r =3D 2;
-
-      write_av9110 (sc, av->n, av->m, av->v, av->x, av->r);
-      return;
-    }
-
-  av =3D &ctl->cardspec.ssi;
-
-  if (av->f =3D=3D 0)
-    return;
-
-  ictl->clock_rate =3D av->f;	/* really, this is the rate we are */
-  ictl->cardspec.ssi =3D *av;
-
-  write_av9110 (sc, av->n, av->m, av->v, av->x, av->r);
+	lmc_ctl_t *ictl =3D &sc->ictl;
+	lmc_av9110_t *av;
+
+	/* original settings for clock rate of 100 Khz (8,25,0,0,2) were
+	   incorrect. They should have been 80,125,1,3,3. There are 17 param
+	   combinations to produce this freq. For 1.5 Mhz use 120,100,1,1,2
+	   (226 param. combinations) */
+	if (ctl =3D=3D NULL) {
+		av =3D &ictl->cardspec.ssi;
+		ictl->clock_rate =3D 1500000;
+		av->f =3D ictl->clock_rate;
+		av->n =3D 120;
+		av->m =3D 100;
+		av->v =3D 1;
+		av->x =3D 1;
+		av->r =3D 2;
+		write_av9110(sc, av->n, av->m, av->v, av->x, av->r);
+		return;
+	}
+
+	av =3D &ctl->cardspec.ssi;
+
+	if (av->f =3D=3D 0)
+		return;
+
+	ictl->clock_rate =3D av->f;	/* really, this is the rate we are */
+	ictl->cardspec.ssi =3D *av;
+
+	write_av9110(sc, av->n, av->m, av->v, av->x, av->r);
 }
=20
-/*
- * return hardware link status.
- * 0 =3D=3D link is down, 1 =3D=3D link is up.
- */
-static int
-lmc_ssi_get_link_status (lmc_softc_t * const sc)
+/* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
+static int lmc_ssi_get_link_status(lmc_softc_t * const sc)
 {
-  u16 link_status;
-  u32 ticks;
-  int ret =3D 1;
-  int hw_hdsk =3D 1;
-
-  /*
-   * missing CTS?  Hmm.  If we require CTS on, we may never get the
-   * link to come up, so omit it in this test.
-   *
-   * Also, it seems that with a loopback cable, DCD isn't asserted,
-   * so just check for things like this:
-   *      DSR _must_ be asserted.
-   *      One of DCD or CTS must be asserted.
-   */
-
-  /* LMC 1000 (SSI) LED definitions
-   * led0 Green =3D power to adapter, Gate Array loaded &
-   *              driver attached
-   * led1 Green =3D DSR and DTR and RTS and CTS are set
-   * led2 Green =3D Cable detected
-   * led3 red   =3D No timing is available from the
-   *              cable or the on-board frequency
-   *              generator.
-   */
-
-  link_status =3D lmc_mii_readreg (sc, 0, 16);
-
-  /* Is the transmit clock still available */
-  ticks =3D LMC_CSR_READ (sc, csr_gp_timer);
-  ticks =3D 0x0000ffff - (ticks & 0x0000ffff);
-
-  lmc_led_on (sc, LMC_MII16_LED0);
-
-  /* =3D=3D=3D=3D=3D=3D transmit clock determination =3D=3D=3D=3D=3D *=
/
-  if (sc->lmc_timing =3D=3D LMC_CTL_CLOCK_SOURCE_INT) {
-      lmc_led_off(sc, LMC_MII16_LED3);
-  }
-  else if (ticks =3D=3D 0 ) {				/* no clock found ? */
-      ret =3D 0;
-      if (sc->last_led_err[3] !=3D 1) {
-	      sc->extra_stats.tx_lossOfClockCnt++;
-	      printk(KERN_WARNING "%s: Lost Clock, Link Down\n", sc->name);
-      }
-      sc->last_led_err[3] =3D 1;
-      lmc_led_on (sc, LMC_MII16_LED3);	/* turn ON red LED */
-  }
-  else {
-      if(sc->last_led_err[3] =3D=3D 1)
-          printk(KERN_WARNING "%s: Clock Returned\n", sc->name);
-      sc->last_led_err[3] =3D 0;
-      lmc_led_off (sc, LMC_MII16_LED3);		/* turn OFF red LED */
-  }
-
-  if ((link_status & LMC_MII16_SSI_DSR) =3D=3D 0) { /* Also HSSI CA */
-      ret =3D 0;
-      hw_hdsk =3D 0;
-  }
+	u16 link_status;
+	u32 ticks;
+	int ret =3D 1;
+	int hw_hdsk =3D 1;
+
+	/* missing CTS?  Hmm.  If we require CTS on, we may never get the
+	   link to come up, so omit it in this test.
+
+	   Also, it seems that with a loopback cable, DCD isn't asserted,
+	   so just check for things like this:
+	   - DSR _must_ be asserted.
+	   - One of DCD or CTS must be asserted. */
+
+	/* LMC 1000 (SSI) LED definitions
+	   - led0 green =3D power to adapter, Gate Array loaded & driver atta=
ched
+	   - led1 green =3D DSR and DTR and RTS and CTS are set
+	   - led2 green =3D Cable detected
+	   - led3 red   =3D No timing is available from the cable or the on-b=
oard
+			  frequency generator. */
+
+	link_status =3D lmc_mii_readreg(sc, 0, 16);
+
+	/* Is the transmit clock still available */
+	ticks =3D LMC_CSR_READ(sc, csr_gp_timer);
+	ticks =3D 0x0000ffff - (ticks & 0x0000ffff);
+
+	lmc_led_on(sc, LMC_MII16_LED0);
+
+	/* transmit clock determination */
+	if (sc->lmc_timing =3D=3D LMC_CTL_CLOCK_SOURCE_INT)
+		lmc_led_off(sc, LMC_MII16_LED3);
+	else if (ticks =3D=3D 0) {	/* no clock found ? */
+		ret =3D 0;
+		if (sc->last_led_err[3] !=3D 1) {
+			sc->extra_stats.tx_lossOfClockCnt++;
+			printk(KERN_WARNING "%s: Lost Clock, Link Down\n",
+			       sc->name);
+		}
+		sc->last_led_err[3] =3D 1;
+		lmc_led_on(sc, LMC_MII16_LED3);	/* turn ON red LED */
+	} else {
+		if (sc->last_led_err[3] =3D=3D 1)
+			printk(KERN_WARNING "%s: Clock Returned\n", sc->name);
+		sc->last_led_err[3] =3D 0;
+		lmc_led_off(sc, LMC_MII16_LED3); /* turn OFF red LED */
+	}
+
+	if ((link_status & LMC_MII16_SSI_DSR) =3D=3D 0) { /* Also HSSI CA */
+		ret =3D 0;
+		hw_hdsk =3D 0;
+	}
=20
 #ifdef CONFIG_LMC_IGNORE_HARDWARE_HANDSHAKE
-  if ((link_status & (LMC_MII16_SSI_CTS | LMC_MII16_SSI_DCD)) =3D=3D 0=
){
-      ret =3D 0;
-      hw_hdsk =3D 0;
-  }
+	if ((link_status & (LMC_MII16_SSI_CTS | LMC_MII16_SSI_DCD)) =3D=3D 0)=
 {
+		ret =3D 0;
+		hw_hdsk =3D 0;
+	}
 #endif
=20
-  if(hw_hdsk =3D=3D 0){
-      if(sc->last_led_err[1] !=3D 1)
-          printk(KERN_WARNING "%s: DSR not asserted\n", sc->name);
-      sc->last_led_err[1] =3D 1;
-      lmc_led_off(sc, LMC_MII16_LED1);
-  }
-  else {
-      if(sc->last_led_err[1] !=3D 0)
-          printk(KERN_WARNING "%s: DSR now asserted\n", sc->name);
-      sc->last_led_err[1] =3D 0;
-      lmc_led_on(sc, LMC_MII16_LED1);
-  }
-
-  if(ret =3D=3D 1) {
-      lmc_led_on(sc, LMC_MII16_LED2); /* Over all good status? */
-  }
- =20
-  return ret;
+	if (hw_hdsk =3D=3D 0) {
+		if (sc->last_led_err[1] !=3D 1)
+			printk(KERN_WARNING "%s: DSR not asserted\n", sc->name);
+		sc->last_led_err[1] =3D 1;
+		lmc_led_off(sc, LMC_MII16_LED1);
+	} else {
+		if (sc->last_led_err[1] !=3D 0)
+			printk(KERN_WARNING "%s: DSR now asserted\n", sc->name);
+		sc->last_led_err[1] =3D 0;
+		lmc_led_on(sc, LMC_MII16_LED1);
+	}
+
+	if (ret =3D=3D 1)
+		lmc_led_on(sc, LMC_MII16_LED2); /* Over all good status? */
+
+	return ret;
 }
=20
-static void
-lmc_ssi_set_link_status (lmc_softc_t * const sc, int state)
+static void lmc_ssi_set_link_status(lmc_softc_t * const sc, int state)
 {
-  if (state =3D=3D LMC_LINK_UP)
-    {
-      sc->lmc_miireg16 |=3D (LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
-      printk (LMC_PRINTF_FMT ": asserting DTR and RTS\n", LMC_PRINTF_A=
RGS);
-    }
-  else
-    {
-      sc->lmc_miireg16 &=3D ~(LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
-      printk (LMC_PRINTF_FMT ": deasserting DTR and RTS\n", LMC_PRINTF=
_ARGS);
-    }
-
-  lmc_mii_writereg (sc, 0, 16, sc->lmc_miireg16);
+	if (state =3D=3D LMC_LINK_UP) {
+		sc->lmc_miireg16 |=3D (LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
+		printk(LMC_PRINTF_FMT ": asserting DTR and RTS\n",
+		       LMC_PRINTF_ARGS);
+	} else {
+		sc->lmc_miireg16 &=3D ~(LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
+		printk(LMC_PRINTF_FMT ": deasserting DTR and RTS\n",
+		       LMC_PRINTF_ARGS);
+	}
+
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
=20
 }
=20
-/*
- * 0 =3D=3D 16bit, 1 =3D=3D 32bit
- */
-static void
-lmc_ssi_set_crc_length (lmc_softc_t * const sc, int state)
+/* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
+static void lmc_ssi_set_crc_length(lmc_softc_t * const sc, int state)
 {
-  if (state =3D=3D LMC_CTL_CRC_LENGTH_32)
-    {
-      /* 32 bit */
-      sc->lmc_miireg16 |=3D LMC_MII16_SSI_CRC;
-      sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
-      sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_4;
-
-    }
-  else
-    {
-      /* 16 bit */
-      sc->lmc_miireg16 &=3D ~LMC_MII16_SSI_CRC;
-      sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
-      sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_2;
-    }
-
-  lmc_mii_writereg (sc, 0, 16, sc->lmc_miireg16);
+	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
+		/* 32 bit */
+		sc->lmc_miireg16 |=3D LMC_MII16_SSI_CRC;
+		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
+		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_4;
+
+	} else {
+		/* 16 bit */
+		sc->lmc_miireg16 &=3D ~LMC_MII16_SSI_CRC;
+		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
+		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_2;
+	}
+
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-/*
- * These are bits to program the ssi frequency generator
- */
-static inline void
-write_av9110_bit (lmc_softc_t * sc, int c)
+/* These are bits to program the ssi frequency generator */
+static inline void write_av9110_bit(lmc_softc_t *sc, int c)
 {
-  /*
-   * set the data bit as we need it.
-   */
-  sc->lmc_gpio &=3D ~(LMC_GEP_CLK);
-  if (c & 0x01)
-    sc->lmc_gpio |=3D LMC_GEP_DATA;
-  else
-    sc->lmc_gpio &=3D ~(LMC_GEP_DATA);
-  LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
-
-  /*
-   * set the clock to high
-   */
-  sc->lmc_gpio |=3D LMC_GEP_CLK;
-  LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
-
-  /*
-   * set the clock to low again.
-   */
-  sc->lmc_gpio &=3D ~(LMC_GEP_CLK);
-  LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
+	/* set the data bit as we need it. */
+	sc->lmc_gpio &=3D ~(LMC_GEP_CLK);
+	if (c & 0x01)
+		sc->lmc_gpio |=3D LMC_GEP_DATA;
+	else
+		sc->lmc_gpio &=3D ~(LMC_GEP_DATA);
+	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+	/* set the clock to high */
+	sc->lmc_gpio |=3D LMC_GEP_CLK;
+	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+	/* set the clock to low again. */
+	sc->lmc_gpio &=3D ~(LMC_GEP_CLK);
+	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
 }
=20
 static void write_av9110(lmc_softc_t *sc, u32 n, u32 m, u32 v, u32 x, =
u32 r)
 {
-  int i;
+	int i;
=20
 #if 0
-  printk (LMC_PRINTF_FMT ": speed %u, %d %d %d %d %d\n",
-	  LMC_PRINTF_ARGS, sc->ictl.clock_rate, n, m, v, x, r);
+	printk(LMC_PRINTF_FMT ": speed %u, %d %d %d %d %d\n",
+	       LMC_PRINTF_ARGS, sc->ictl.clock_rate, n, m, v, x, r);
 #endif
=20
-  sc->lmc_gpio |=3D LMC_GEP_SSI_GENERATOR;
-  sc->lmc_gpio &=3D ~(LMC_GEP_DATA | LMC_GEP_CLK);
-  LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
-
-  /*
-   * Set the TXCLOCK, GENERATOR, SERIAL, and SERIALCLK
-   * as outputs.
-   */
-  lmc_gpio_mkoutput (sc, (LMC_GEP_DATA | LMC_GEP_CLK
-			  | LMC_GEP_SSI_GENERATOR));
-
-  sc->lmc_gpio &=3D ~(LMC_GEP_SSI_GENERATOR);
-  LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
-
-  /*
-   * a shifting we will go...
-   */
-  for (i =3D 0; i < 7; i++)
-    write_av9110_bit (sc, n >> i);
-  for (i =3D 0; i < 7; i++)
-    write_av9110_bit (sc, m >> i);
-  for (i =3D 0; i < 1; i++)
-    write_av9110_bit (sc, v >> i);
-  for (i =3D 0; i < 2; i++)
-    write_av9110_bit (sc, x >> i);
-  for (i =3D 0; i < 2; i++)
-    write_av9110_bit (sc, r >> i);
-  for (i =3D 0; i < 5; i++)
-    write_av9110_bit (sc, 0x17 >> i);
-
-  /*
-   * stop driving serial-related signals
-   */
-  lmc_gpio_mkinput (sc,
-		    (LMC_GEP_DATA | LMC_GEP_CLK
-		     | LMC_GEP_SSI_GENERATOR));
+	sc->lmc_gpio |=3D LMC_GEP_SSI_GENERATOR;
+	sc->lmc_gpio &=3D ~(LMC_GEP_DATA | LMC_GEP_CLK);
+	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+	/* Set the TXCLOCK, GENERATOR, SERIAL, and SERIALCLK as outputs. */
+	lmc_gpio_mkoutput(sc, (LMC_GEP_DATA | LMC_GEP_CLK
+				| LMC_GEP_SSI_GENERATOR));
+
+	sc->lmc_gpio &=3D ~(LMC_GEP_SSI_GENERATOR);
+	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+	/* a shifting we will go... */
+	for (i =3D 0; i < 7; i++)
+		write_av9110_bit(sc, n >> i);
+	for (i =3D 0; i < 7; i++)
+		write_av9110_bit(sc, m >> i);
+	for (i =3D 0; i < 1; i++)
+		write_av9110_bit(sc, v >> i);
+	for (i =3D 0; i < 2; i++)
+		write_av9110_bit(sc, x >> i);
+	for (i =3D 0; i < 2; i++)
+		write_av9110_bit(sc, r >> i);
+	for (i =3D 0; i < 5; i++)
+		write_av9110_bit(sc, 0x17 >> i);
+
+	/* stop driving serial-related signals */
+	lmc_gpio_mkinput(sc, (LMC_GEP_DATA | LMC_GEP_CLK |
+			      LMC_GEP_SSI_GENERATOR));
 }
=20
 static void lmc_ssi_watchdog(lmc_softc_t * const sc)
@@ -889,322 +752,285 @@ static void lmc_ssi_watchdog(lmc_softc_t * cons=
t sc)
 		lmc_led_on(sc, LMC_MII16_LED2);
 }
=20
-/*
- *  T1 methods
- */
+/* T1 methods */
=20
-/*
- * The framer regs are multiplexed through MII regs 17 & 18
- *  write the register address to MII reg 17 and the *  data to MII re=
g 18. */
-static void
-lmc_t1_write (lmc_softc_t * const sc, int a, int d)
+/* The framer regs are multiplexed through MII regs 17 & 18 write the =
register
+   address to MII reg 17 and the data to MII reg 18. */
+static void lmc_t1_write(lmc_softc_t * const sc, int a, int d)
 {
-  lmc_mii_writereg (sc, 0, 17, a);
-  lmc_mii_writereg (sc, 0, 18, d);
+	lmc_mii_writereg(sc, 0, 17, a);
+	lmc_mii_writereg(sc, 0, 18, d);
 }
=20
 /* Save a warning
-static int
-lmc_t1_read (lmc_softc_t * const sc, int a)
+static int lmc_t1_read(lmc_softc_t * const sc, int a)
 {
-  lmc_mii_writereg (sc, 0, 17, a);
-  return lmc_mii_readreg (sc, 0, 18);
+	lmc_mii_writereg(sc, 0, 17, a);
+	return lmc_mii_readreg(sc, 0, 18);
 }
 */
=20
=20
-static void
-lmc_t1_init (lmc_softc_t * const sc)
+static void lmc_t1_init(lmc_softc_t * const sc)
 {
-  u16 mii16;
-  int i;
-
-  sc->ictl.cardtype =3D LMC_CTL_CARDTYPE_LMC1200;
-  mii16 =3D lmc_mii_readreg (sc, 0, 16);
-
-  /* reset 8370 */
-  mii16 &=3D ~LMC_MII16_T1_RST;
-  lmc_mii_writereg (sc, 0, 16, mii16 | LMC_MII16_T1_RST);
-  lmc_mii_writereg (sc, 0, 16, mii16);
-
-  /* set T1 or E1 line.  Uses sc->lmcmii16 reg in function so update i=
t */
-  sc->lmc_miireg16 =3D mii16;
-  lmc_t1_set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
-  mii16 =3D sc->lmc_miireg16;
-
-  lmc_t1_write (sc, 0x01, 0x1B);	/* CR0     - primary control         =
    */
-  lmc_t1_write (sc, 0x02, 0x42);	/* JAT_CR  - jitter atten config     =
    */
-  lmc_t1_write (sc, 0x14, 0x00);	/* LOOP    - loopback config         =
    */
-  lmc_t1_write (sc, 0x15, 0x00);	/* DL3_TS  - external data link times=
lot */
-  lmc_t1_write (sc, 0x18, 0xFF);	/* PIO     - programmable I/O        =
    */
-  lmc_t1_write (sc, 0x19, 0x30);	/* POE     - programmable OE         =
    */
-  lmc_t1_write (sc, 0x1A, 0x0F);	/* CMUX    - clock input mux         =
    */
-  lmc_t1_write (sc, 0x20, 0x41);	/* LIU_CR  - RX LIU config           =
    */
-  lmc_t1_write (sc, 0x22, 0x76);	/* RLIU_CR - RX LIU config           =
    */
-  lmc_t1_write (sc, 0x40, 0x03);	/* RCR0    - RX config               =
    */
-  lmc_t1_write (sc, 0x45, 0x00);	/* RALM    - RX alarm config         =
    */
-  lmc_t1_write (sc, 0x46, 0x05);	/* LATCH   - RX alarm/err/cntr latch =
    */
-  lmc_t1_write (sc, 0x68, 0x40);	/* TLIU_CR - TX LIU config           =
    */
-  lmc_t1_write (sc, 0x70, 0x0D);	/* TCR0    - TX framer config        =
    */
-  lmc_t1_write (sc, 0x71, 0x05);	/* TCR1    - TX config               =
    */
-  lmc_t1_write (sc, 0x72, 0x0B);	/* TFRM    - TX frame format         =
    */
-  lmc_t1_write (sc, 0x73, 0x00);	/* TERROR  - TX error insert         =
    */
-  lmc_t1_write (sc, 0x74, 0x00);	/* TMAN    - TX manual Sa/FEBE config=
    */
-  lmc_t1_write (sc, 0x75, 0x00);	/* TALM    - TX alarm signal config  =
    */
-  lmc_t1_write (sc, 0x76, 0x00);	/* TPATT   - TX test pattern config  =
    */
-  lmc_t1_write (sc, 0x77, 0x00);	/* TLB     - TX inband loopback confi=
g   */
-  lmc_t1_write (sc, 0x90, 0x05);	/* CLAD_CR - clock rate adapter confi=
g   */
-  lmc_t1_write (sc, 0x91, 0x05);	/* CSEL    - clad freq sel           =
    */
-  lmc_t1_write (sc, 0xA6, 0x00);	/* DL1_CTL - DL1 control             =
    */
-  lmc_t1_write (sc, 0xB1, 0x00);	/* DL2_CTL - DL2 control             =
    */
-  lmc_t1_write (sc, 0xD0, 0x47);	/* SBI_CR  - sys bus iface config    =
    */
-  lmc_t1_write (sc, 0xD1, 0x70);	/* RSB_CR  - RX sys bus config       =
    */
-  lmc_t1_write (sc, 0xD4, 0x30);	/* TSB_CR  - TX sys bus config       =
    */
-  for (i =3D 0; i < 32; i++)
-    {
-      lmc_t1_write (sc, 0x0E0 + i, 0x00);	/* SBCn - sys bus per-channe=
l ctl    */
-      lmc_t1_write (sc, 0x100 + i, 0x00);	/* TPCn - TX per-channel ctl=
         */
-      lmc_t1_write (sc, 0x180 + i, 0x00);	/* RPCn - RX per-channel ctl=
         */
-    }
-  for (i =3D 1; i < 25; i++)
-    {
-      lmc_t1_write (sc, 0x0E0 + i, 0x0D);	/* SBCn - sys bus per-channe=
l ctl    */
-    }
-
-  mii16 |=3D LMC_MII16_T1_XOE;
-  lmc_mii_writereg (sc, 0, 16, mii16);
-  sc->lmc_miireg16 =3D mii16;
+	u16 mii16;
+	int i;
+
+	sc->ictl.cardtype =3D LMC_CTL_CARDTYPE_LMC1200;
+	mii16 =3D lmc_mii_readreg(sc, 0, 16);
+
+	/* reset 8370 */
+	mii16 &=3D ~LMC_MII16_T1_RST;
+	lmc_mii_writereg(sc, 0, 16, mii16 | LMC_MII16_T1_RST);
+	lmc_mii_writereg(sc, 0, 16, mii16);
+
+	/* set T1 or E1 line.  Uses sc->lmcmii16 reg in function so update it=
 */
+	sc->lmc_miireg16 =3D mii16;
+	lmc_t1_set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
+	mii16 =3D sc->lmc_miireg16;
+
+	lmc_t1_write(sc, 0x01, 0x1B); /* CR0     - primary control */
+	lmc_t1_write(sc, 0x02, 0x42); /* JAT_CR  - jitter atten config */
+	lmc_t1_write(sc, 0x14, 0x00); /* LOOP    - loopback config */
+	lmc_t1_write(sc, 0x15, 0x00); /* DL3_TS  - external data link timeslo=
t */
+	lmc_t1_write(sc, 0x18, 0xFF); /* PIO     - programmable I/O */
+	lmc_t1_write(sc, 0x19, 0x30); /* POE     - programmable OE */
+	lmc_t1_write(sc, 0x1A, 0x0F); /* CMUX    - clock input mux */
+	lmc_t1_write(sc, 0x20, 0x41); /* LIU_CR  - RX LIU config */
+	lmc_t1_write(sc, 0x22, 0x76); /* RLIU_CR - RX LIU config */
+	lmc_t1_write(sc, 0x40, 0x03); /* RCR0    - RX config */
+	lmc_t1_write(sc, 0x45, 0x00); /* RALM    - RX alarm config */
+	lmc_t1_write(sc, 0x46, 0x05); /* LATCH   - RX alarm/err/cntr latch */
+	lmc_t1_write(sc, 0x68, 0x40); /* TLIU_CR - TX LIU config */
+	lmc_t1_write(sc, 0x70, 0x0D); /* TCR0    - TX framer config */
+	lmc_t1_write(sc, 0x71, 0x05); /* TCR1    - TX config */
+	lmc_t1_write(sc, 0x72, 0x0B); /* TFRM    - TX frame format */
+	lmc_t1_write(sc, 0x73, 0x00); /* TERROR  - TX error insert */
+	lmc_t1_write(sc, 0x74, 0x00); /* TMAN    - TX manual Sa/FEBE config *=
/
+	lmc_t1_write(sc, 0x75, 0x00); /* TALM    - TX alarm signal config */
+	lmc_t1_write(sc, 0x76, 0x00); /* TPATT   - TX test pattern config */
+	lmc_t1_write(sc, 0x77, 0x00); /* TLB     - TX inband loopback config =
*/
+	lmc_t1_write(sc, 0x90, 0x05); /* CLAD_CR - clock rate adapter config =
*/
+	lmc_t1_write(sc, 0x91, 0x05); /* CSEL    - clad freq sel */
+	lmc_t1_write(sc, 0xA6, 0x00); /* DL1_CTL - DL1 control */
+	lmc_t1_write(sc, 0xB1, 0x00); /* DL2_CTL - DL2 control */
+	lmc_t1_write(sc, 0xD0, 0x47); /* SBI_CR  - sys bus iface config */
+	lmc_t1_write(sc, 0xD1, 0x70); /* RSB_CR  - RX sys bus config */
+	lmc_t1_write(sc, 0xD4, 0x30); /* TSB_CR  - TX sys bus config */
+	for (i =3D 0; i < 32; i++) {
+		lmc_t1_write(sc, 0x0E0 + i, 0x00); /* SBCn - sys bus per-channel ctl=
 */
+		lmc_t1_write(sc, 0x100 + i, 0x00); /* TPCn - TX per-channel ctl */
+		lmc_t1_write(sc, 0x180 + i, 0x00); /* RPCn - RX per-channel ctl */
+	}
+	for (i =3D 1; i < 25; i++)
+		lmc_t1_write(sc, 0x0E0 + i, 0x0D); /* SBCn - sys bus per-channel ctl=
 */
+
+	mii16 |=3D LMC_MII16_T1_XOE;
+	lmc_mii_writereg(sc, 0, 16, mii16);
+	sc->lmc_miireg16 =3D mii16;
 }
=20
-static void
-lmc_t1_default (lmc_softc_t * const sc)
+static void lmc_t1_default(lmc_softc_t * const sc)
 {
-  sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
-  sc->lmc_media->set_link_status (sc, LMC_LINK_DOWN);
-  sc->lmc_media->set_circuit_type (sc, LMC_CTL_CIRCUIT_TYPE_T1);
-  sc->lmc_media->set_crc_length (sc, LMC_CTL_CRC_LENGTH_16);
-  /* Right now we can only clock from out internal source */
-  sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
+	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
+	sc->lmc_media->set_link_status(sc, LMC_LINK_DOWN);
+	sc->lmc_media->set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
+	sc->lmc_media->set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
+	/* Right now we can only clock from out internal source */
+	sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
 }
-/* * Given a user provided state, set ourselves up to match it.  This =
will * always reset the card if needed.
- */
-static void
-lmc_t1_set_status (lmc_softc_t * const sc, lmc_ctl_t * ctl)
+/* Given a user provided state, set ourselves up to match it.
+   This will always reset the card if needed. */
+static void lmc_t1_set_status(lmc_softc_t * const sc, lmc_ctl_t * ctl)
 {
-  if (ctl =3D=3D NULL)
-    {
-      sc->lmc_media->set_circuit_type (sc, sc->ictl.circuit_type);
-      lmc_set_protocol (sc, NULL);
-
-      return;
-    }
-  /*
-   * check for change in circuit type         */
-  if (ctl->circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_T1
-      && sc->ictl.circuit_type =3D=3D
-      LMC_CTL_CIRCUIT_TYPE_E1) sc->lmc_media->set_circuit_type (sc,
-								LMC_CTL_CIRCUIT_TYPE_E1);
-  else if (ctl->circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_E1
-	   && sc->ictl.circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_T1)
-    sc->lmc_media->set_circuit_type (sc, LMC_CTL_CIRCUIT_TYPE_T1);
-  lmc_set_protocol (sc, ctl);
+	if (ctl =3D=3D NULL) {
+		sc->lmc_media->set_circuit_type(sc, sc->ictl.circuit_type);
+		lmc_set_protocol(sc, NULL);
+
+		return;
+	}
+	/* check for change in circuit type */
+	if (ctl->circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_T1
+	    && sc->ictl.circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_E1)
+		sc->lmc_media->set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_E1);
+	else if (ctl->circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_E1
+		 && sc->ictl.circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_T1)
+		sc->lmc_media->set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
+	lmc_set_protocol(sc, ctl);
 }
-/*
- * return hardware link status.
- * 0 =3D=3D link is down, 1 =3D=3D link is up.
- */ static int
-lmc_t1_get_link_status (lmc_softc_t * const sc)
+
+/* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
+static int lmc_t1_get_link_status(lmc_softc_t * const sc)
 {
-    u16 link_status;
-    int ret =3D 1;
-
-  /* LMC5245 (DS3) & LMC1200 (DS1) LED definitions
-   * led0 yellow =3D far-end adapter is in Red alarm condition
-   * led1 blue   =3D received an Alarm Indication signal
-   *               (upstream failure)
-   * led2 Green  =3D power to adapter, Gate Array loaded & driver
-   *               attached
-   * led3 red    =3D Loss of Signal (LOS) or out of frame (OOF)
-   *               conditions detected on T3 receive signal
-   */
-    lmc_trace(sc->lmc_device, "lmc_t1_get_link_status in");
-    lmc_led_on(sc, LMC_DS3_LED2);
-
-    lmc_mii_writereg (sc, 0, 17, T1FRAMER_ALARM1_STATUS);
-    link_status =3D lmc_mii_readreg (sc, 0, 18);
-
-
-    if (link_status & T1F_RAIS) {			/* turn on blue LED */
-        ret =3D 0;
-        if(sc->last_led_err[1] !=3D 1){
-            printk(KERN_WARNING "%s: Receive AIS/Blue Alarm. Far end i=
n RED alarm\n", sc->name);
-        }
-        lmc_led_on(sc, LMC_DS3_LED1);
-        sc->last_led_err[1] =3D 1;
-    }
-    else {
-        if(sc->last_led_err[1] !=3D 0){
-            printk(KERN_WARNING "%s: End AIS/Blue Alarm\n", sc->name);
-        }
-        lmc_led_off (sc, LMC_DS3_LED1);
-        sc->last_led_err[1] =3D 0;
-    }
-
-    /*
-     * Yellow Alarm is nasty evil stuff, looks at data patterns
-     * inside the channel and confuses it with HDLC framing
-     * ignore all yellow alarms.
-     *
-     * Do listen to MultiFrame Yellow alarm which while implemented
-     * different ways isn't in the channel and hence somewhat
-     * more reliable
-     */
-
-    if (link_status & T1F_RMYEL) {
-        ret =3D 0;
-        if(sc->last_led_err[0] !=3D 1){
-            printk(KERN_WARNING "%s: Receive Yellow AIS Alarm\n", sc->=
name);
-        }
-        lmc_led_on(sc, LMC_DS3_LED0);
-        sc->last_led_err[0] =3D 1;
-    }
-    else {
-        if(sc->last_led_err[0] !=3D 0){
-            printk(KERN_WARNING "%s: End of Yellow AIS Alarm\n", sc->n=
ame);
-        }
-        lmc_led_off(sc, LMC_DS3_LED0);
-        sc->last_led_err[0] =3D 0;
-    }
-
-    /*
-     * Loss of signal and los of frame
-     * Use the green bit to identify which one lit the led
-     */
-    if(link_status & T1F_RLOF){
-        ret =3D 0;
-        if(sc->last_led_err[3] !=3D 1){
-            printk(KERN_WARNING "%s: Local Red Alarm: Loss of Framing\=
n", sc->name);
-        }
-        lmc_led_on(sc, LMC_DS3_LED3);
-        sc->last_led_err[3] =3D 1;
-
-    }
-    else {
-        if(sc->last_led_err[3] !=3D 0){
-            printk(KERN_WARNING "%s: End Red Alarm (LOF)\n", sc->name)=
;
-        }
-        if( ! (link_status & T1F_RLOS))
-            lmc_led_off(sc, LMC_DS3_LED3);
-        sc->last_led_err[3] =3D 0;
-    }
-   =20
-    if(link_status & T1F_RLOS){
-        ret =3D 0;
-        if(sc->last_led_err[2] !=3D 1){
-            printk(KERN_WARNING "%s: Local Red Alarm: Loss of Signal\n=
", sc->name);
-        }
-        lmc_led_on(sc, LMC_DS3_LED3);
-        sc->last_led_err[2] =3D 1;
-
-    }
-    else {
-        if(sc->last_led_err[2] !=3D 0){
-            printk(KERN_WARNING "%s: End Red Alarm (LOS)\n", sc->name)=
;
-        }
-        if( ! (link_status & T1F_RLOF))
-            lmc_led_off(sc, LMC_DS3_LED3);
-        sc->last_led_err[2] =3D 0;
-    }
-
-    sc->lmc_xinfo.t1_alarm1_status =3D link_status;
-
-    lmc_mii_writereg (sc, 0, 17, T1FRAMER_ALARM2_STATUS);
-    sc->lmc_xinfo.t1_alarm2_status =3D lmc_mii_readreg (sc, 0, 18);
-
-   =20
-    lmc_trace(sc->lmc_device, "lmc_t1_get_link_status out");
-
-    return ret;
+	u16 link_status;
+	int ret =3D 1;
+
+	/* LMC5245 (DS3) & LMC1200 (DS1) LED definitions
+	   - led0 yellow =3D far-end adapter is in Red alarm condition
+	   - led1 blue  =3D received an Alarm Indication signal (upstream fai=
lure)
+	   - led2 green  =3D power to adapter, Gate Array loaded & driver att=
ached
+	   - led3 red    =3D Loss of Signal (LOS) or out of frame (OOF)
+			   conditions detected on T3 receive signal */
+	lmc_trace(sc->lmc_device, "lmc_t1_get_link_status in");
+	lmc_led_on(sc, LMC_DS3_LED2);
+
+	lmc_mii_writereg(sc, 0, 17, T1FRAMER_ALARM1_STATUS);
+	link_status =3D lmc_mii_readreg(sc, 0, 18);
+
+	if (link_status & T1F_RAIS) { /* turn on blue LED */
+		ret =3D 0;
+		if (sc->last_led_err[1] !=3D 1) {
+			printk(KERN_WARNING
+			       "%s: Receive AIS/Blue Alarm. Far end in RED alarm\n",
+			       sc->name);
+		}
+		lmc_led_on(sc, LMC_DS3_LED1);
+		sc->last_led_err[1] =3D 1;
+	} else {
+		if (sc->last_led_err[1] !=3D 0) {
+			printk(KERN_WARNING "%s: End AIS/Blue Alarm\n",
+			       sc->name);
+		}
+		lmc_led_off(sc, LMC_DS3_LED1);
+		sc->last_led_err[1] =3D 0;
+	}
+
+	/* Yellow Alarm is nasty evil stuff, looks at data patterns inside th=
e
+	   channel and confuses it with HDLC framing ignore all yellow alarms=
=2E
+	   Do listen to MultiFrame Yellow alarm which while implemented
+	   different ways isn't in the channel and hence somewhat more
+	   reliable */
+
+	if (link_status & T1F_RMYEL) {
+		ret =3D 0;
+		if (sc->last_led_err[0] !=3D 1) {
+			printk(KERN_WARNING "%s: Receive Yellow AIS Alarm\n",
+			       sc->name);
+		}
+		lmc_led_on(sc, LMC_DS3_LED0);
+		sc->last_led_err[0] =3D 1;
+	} else {
+		if (sc->last_led_err[0] !=3D 0) {
+			printk(KERN_WARNING "%s: End of Yellow AIS Alarm\n",
+			       sc->name);
+		}
+		lmc_led_off(sc, LMC_DS3_LED0);
+		sc->last_led_err[0] =3D 0;
+	}
+
+	/* Loss of signal and los of frame. Use the green bit to identify whi=
ch
+	   one lit the led */
+	if (link_status & T1F_RLOF) {
+		ret =3D 0;
+		if (sc->last_led_err[3] !=3D 1) {
+			printk(KERN_WARNING
+			       "%s: Local Red Alarm: Loss of Framing\n",
+			       sc->name);
+		}
+		lmc_led_on(sc, LMC_DS3_LED3);
+		sc->last_led_err[3] =3D 1;
+
+	} else {
+		if (sc->last_led_err[3] !=3D 0) {
+			printk(KERN_WARNING "%s: End Red Alarm (LOF)\n",
+			       sc->name);
+		}
+		if (!(link_status & T1F_RLOS))
+			lmc_led_off(sc, LMC_DS3_LED3);
+		sc->last_led_err[3] =3D 0;
+	}
+
+	if (link_status & T1F_RLOS) {
+		ret =3D 0;
+		if (sc->last_led_err[2] !=3D 1) {
+			printk(KERN_WARNING
+			       "%s: Local Red Alarm: Loss of Signal\n",
+			       sc->name);
+		}
+		lmc_led_on(sc, LMC_DS3_LED3);
+		sc->last_led_err[2] =3D 1;
+
+	} else {
+		if (sc->last_led_err[2] !=3D 0) {
+			printk(KERN_WARNING "%s: End Red Alarm (LOS)\n",
+			       sc->name);
+		}
+		if (!(link_status & T1F_RLOF))
+			lmc_led_off(sc, LMC_DS3_LED3);
+		sc->last_led_err[2] =3D 0;
+	}
+
+	sc->lmc_xinfo.t1_alarm1_status =3D link_status;
+
+	lmc_mii_writereg(sc, 0, 17, T1FRAMER_ALARM2_STATUS);
+	sc->lmc_xinfo.t1_alarm2_status =3D lmc_mii_readreg(sc, 0, 18);
+
+	lmc_trace(sc->lmc_device, "lmc_t1_get_link_status out");
+	return ret;
 }
=20
-/*
- * 1 =3D=3D T1 Circuit Type , 0 =3D=3D E1 Circuit Type
- */
-static void
-lmc_t1_set_circuit_type (lmc_softc_t * const sc, int ie)
+/* 1 =3D=3D T1 Circuit Type , 0 =3D=3D E1 Circuit Type */
+static void lmc_t1_set_circuit_type(lmc_softc_t * const sc, int ie)
 {
-  if (ie =3D=3D LMC_CTL_CIRCUIT_TYPE_T1) {
-      sc->lmc_miireg16 |=3D LMC_MII16_T1_Z;
-      sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_T1;
-      printk(KERN_INFO "%s: In T1 Mode\n", sc->name);
-  }
-  else {
-      sc->lmc_miireg16 &=3D ~LMC_MII16_T1_Z;
-      sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_E1;
-      printk(KERN_INFO "%s: In E1 Mode\n", sc->name);
-  }
-
-  lmc_mii_writereg (sc, 0, 16, sc->lmc_miireg16);
- =20
+	if (ie =3D=3D LMC_CTL_CIRCUIT_TYPE_T1) {
+		sc->lmc_miireg16 |=3D LMC_MII16_T1_Z;
+		sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_T1;
+		printk(KERN_INFO "%s: In T1 Mode\n", sc->name);
+	} else {
+		sc->lmc_miireg16 &=3D ~LMC_MII16_T1_Z;
+		sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_E1;
+		printk(KERN_INFO "%s: In E1 Mode\n", sc->name);
+	}
+
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-/*
- * 0 =3D=3D 16bit, 1 =3D=3D 32bit */
-static void
-lmc_t1_set_crc_length (lmc_softc_t * const sc, int state)
+/* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
+static void lmc_t1_set_crc_length(lmc_softc_t * const sc, int state)
 {
-  if (state =3D=3D LMC_CTL_CRC_LENGTH_32)
-    {
-      /* 32 bit */
-      sc->lmc_miireg16 |=3D LMC_MII16_T1_CRC;
-      sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
-      sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_4;
-
-    }
-  else
-    {
-      /* 16 bit */ sc->lmc_miireg16 &=3D ~LMC_MII16_T1_CRC;
-      sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
-      sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_2;
-
-    }
-
-  lmc_mii_writereg (sc, 0, 16, sc->lmc_miireg16);
+	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
+		/* 32 bit */
+		sc->lmc_miireg16 |=3D LMC_MII16_T1_CRC;
+		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
+		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_4;
+
+	} else {
+		/* 16 bit */ sc->lmc_miireg16 &=3D ~LMC_MII16_T1_CRC;
+		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
+		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_2;
+
+	}
+
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-/*
- * 1 =3D=3D internal, 0 =3D=3D external
- */
-static void
-lmc_t1_set_clock (lmc_softc_t * const sc, int ie)
+/* 1 =3D=3D internal, 0 =3D=3D external */
+static void lmc_t1_set_clock(lmc_softc_t * const sc, int ie)
 {
-  int old;
-  old =3D ie;
-  if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT)
-    {
-      sc->lmc_gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
-      LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
-      sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
-      if(old !=3D ie)
-        printk (LMC_PRINTF_FMT ": clock external\n", LMC_PRINTF_ARGS);
-    }
-  else
-    {
-      sc->lmc_gpio |=3D LMC_GEP_SSI_TXCLOCK;
-      LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
-      sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
-      if(old !=3D ie)
-        printk (LMC_PRINTF_FMT ": clock internal\n", LMC_PRINTF_ARGS);
-    }
+	int old;
+	old =3D ie;
+	if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
+		sc->lmc_gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
+		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
+		if (old !=3D ie)
+			printk(LMC_PRINTF_FMT ": clock external\n",
+			       LMC_PRINTF_ARGS);
+	} else {
+		sc->lmc_gpio |=3D LMC_GEP_SSI_TXCLOCK;
+		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
+		if (old !=3D ie)
+			printk(LMC_PRINTF_FMT ": clock internal\n",
+			       LMC_PRINTF_ARGS);
+	}
 }
=20
-static void
-lmc_t1_watchdog (lmc_softc_t * const sc)
+static void lmc_t1_watchdog(lmc_softc_t * const sc)
 {
 }
=20
-static void
-lmc_set_protocol (lmc_softc_t * const sc, lmc_ctl_t * ctl)
+static void lmc_set_protocol(lmc_softc_t * const sc, lmc_ctl_t * ctl)
 {
 	if (!ctl)
 		sc->ictl.keepalive_onoff =3D LMC_CTL_ON;
diff --git a/drivers/net/wan/lmc/lmc_proto.c b/drivers/net/wan/lmc/lmc_=
proto.c
index f600075..ac1fef5 100644
--- a/drivers/net/wan/lmc/lmc_proto.c
+++ b/drivers/net/wan/lmc/lmc_proto.c
@@ -1,23 +1,23 @@
- /*
-  * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
-  * All rights reserved.  www.lanmedia.com
-  *
-  * This code is written by:
-  * Andrew Stanley-Jones (asj@cban.com)
-  * Rob Braun (bbraun@vix.com),
-  * Michael Graff (explorer@vix.com) and
-  * Matt Thomas (matt@3am-software.com).
-  *
-  * With Help By:
-  * David Boggs
-  * Ron Crane
-  * Allan Cox
-  *
-  * This software may be used and distributed according to the terms
-  * of the GNU General Public License version 2, incorporated herein b=
y reference.
-  *
-  * Driver for the LanMedia LMC5200, LMC5245, LMC1000, LMC1200 cards.
-  */
+/*
+ * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
+ * All rights reserved.  www.lanmedia.com
+ *
+ * This code is written by:
+ * Andrew Stanley-Jones (asj@cban.com)
+ * Rob Braun (bbraun@vix.com),
+ * Michael Graff (explorer@vix.com) and
+ * Matt Thomas (matt@3am-software.com).
+ *
+ * With Help By:
+ * David Boggs
+ * Ron Crane
+ * Allan Cox
+ *
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License version 2, incorporated herein by re=
ference.
+ *
+ * Driver for the LanMedia LMC5200, LMC5245, LMC1000, LMC1200 cards.
+ */
=20
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -35,8 +35,8 @@
 #include <linux/workqueue.h>
 #include <linux/proc_fs.h>
 #include <linux/bitops.h>
-#include <asm/processor.h>             /* Processor type for cache ali=
gnment. */
-#include <asm/io.h>
+#include <linux/io.h>
+#include <asm/processor.h>   /* Processor type for cache alignment. */
 #include <asm/dma.h>
 #include <linux/smp.h>
=20
@@ -46,20 +46,17 @@
 #include "lmc_ioctl.h"
 #include "lmc_proto.h"
=20
-// attach
-void lmc_proto_attach(lmc_softc_t *sc) /*FOLD00*/
+void lmc_proto_attach(lmc_softc_t *sc)
 {
-    lmc_trace(sc->lmc_device, "lmc_proto_attach in");
-    if (sc->if_type =3D=3D LMC_NET) {
-            struct net_device *dev =3D sc->lmc_device;
-            /*
-	     * They set a few basics because they don't use HDLC
-             */
-            dev->flags |=3D IFF_POINTOPOINT;
-            dev->hard_header_len =3D 0;
-            dev->addr_len =3D 0;
-        }
-    lmc_trace(sc->lmc_device, "lmc_proto_attach out");
+	lmc_trace(sc->lmc_device, "lmc_proto_attach in");
+	if (sc->if_type =3D=3D LMC_NET) {
+		struct net_device *dev =3D sc->lmc_device;
+		/* They set a few basics because they don't use HDLC */
+		dev->flags |=3D IFF_POINTOPOINT;
+		dev->hard_header_len =3D 0;
+		dev->addr_len =3D 0;
+	}
+	lmc_trace(sc->lmc_device, "lmc_proto_attach out");
 }
=20
 int lmc_proto_ioctl(lmc_softc_t *sc, struct ifreq *ifr, int cmd)
@@ -97,39 +94,41 @@ void lmc_proto_close(lmc_softc_t *sc)
 	lmc_trace(sc->lmc_device, "lmc_proto_close out");
 }
=20
-__be16 lmc_proto_type(lmc_softc_t *sc, struct sk_buff *skb) /*FOLD00*/
+__be16 lmc_proto_type(lmc_softc_t *sc, struct sk_buff *skb)
 {
-    lmc_trace(sc->lmc_device, "lmc_proto_type in");
-    switch(sc->if_type){
-    case LMC_PPP:
-	    return hdlc_type_trans(skb, sc->lmc_device);
-	    break;
-    case LMC_NET:
-        return htons(ETH_P_802_2);
-        break;
-    case LMC_RAW: /* Packet type for skbuff kind of useless */
-        return htons(ETH_P_802_2);
-        break;
-    default:
-        printk(KERN_WARNING "%s: No protocol set for this interface, a=
ssuming 802.2 (which is wrong!!)\n", sc->name);
-        return htons(ETH_P_802_2);
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_tye out");
+	lmc_trace(sc->lmc_device, "lmc_proto_type in");
+	switch (sc->if_type) {
+	case LMC_PPP:
+		return hdlc_type_trans(skb, sc->lmc_device);
+		break;
+	case LMC_NET:
+		return htons(ETH_P_802_2);
+		break;
+	case LMC_RAW: /* Packet type for skbuff kind of useless */
+		return htons(ETH_P_802_2);
+		break;
+	default:
+		printk(KERN_WARNING
+		       "%s: No protocol set for this interface, assuming 802.2 (whic=
h is wrong!!)\n",
+		       sc->name);
+		return htons(ETH_P_802_2);
+		break;
+	}
+	lmc_trace(sc->lmc_device, "lmc_proto_tye out");
=20
 }
=20
-void lmc_proto_netif(lmc_softc_t *sc, struct sk_buff *skb) /*FOLD00*/
+void lmc_proto_netif(lmc_softc_t *sc, struct sk_buff *skb)
 {
-    lmc_trace(sc->lmc_device, "lmc_proto_netif in");
-    switch(sc->if_type){
-    case LMC_PPP:
-    case LMC_NET:
-    default:
-        netif_rx(skb);
-        break;
-    case LMC_RAW:
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_netif out");
+	lmc_trace(sc->lmc_device, "lmc_proto_netif in");
+	switch (sc->if_type) {
+	case LMC_PPP:
+	case LMC_NET:
+	default:
+		netif_rx(skb);
+		break;
+	case LMC_RAW:
+		break;
+	}
+	lmc_trace(sc->lmc_device, "lmc_proto_netif out");
 }
diff --git a/drivers/net/wan/lmc/lmc_var.h b/drivers/net/wan/lmc/lmc_va=
r.h
index 65d0197..9b14979 100644
--- a/drivers/net/wan/lmc/lmc_var.h
+++ b/drivers/net/wan/lmc/lmc_var.h
@@ -1,197 +1,184 @@
 #ifndef _LMC_VAR_H_
 #define _LMC_VAR_H_
=20
- /*
-  * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
-  * All rights reserved.  www.lanmedia.com
-  *
-  * This code is written by:
-  * Andrew Stanley-Jones (asj@cban.com)
-  * Rob Braun (bbraun@vix.com),
-  * Michael Graff (explorer@vix.com) and
-  * Matt Thomas (matt@3am-software.com).
-  *
-  * This software may be used and distributed according to the terms
-  * of the GNU General Public License version 2, incorporated herein b=
y reference.
-  */
+/*
+ * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
+ * All rights reserved.  www.lanmedia.com
+ *
+ * This code is written by:
+ * Andrew Stanley-Jones (asj@cban.com)
+ * Rob Braun (bbraun@vix.com),
+ * Michael Graff (explorer@vix.com) and
+ * Matt Thomas (matt@3am-software.com).
+ *
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License version 2, incorporated herein by re=
ference.
+ */
=20
 #include <linux/timer.h>
=20
-/*
- * basic definitions used in lmc include files
- */
+/* basic definitions used in lmc include files */
=20
-typedef struct lmc___softc lmc_softc_t;
-typedef struct lmc___media lmc_media_t;
-typedef struct lmc___ctl lmc_ctl_t;
+typedef struct lmc___softc	lmc_softc_t;
+typedef struct lmc___media	lmc_media_t;
+typedef struct lmc___ctl	lmc_ctl_t;
=20
-#define lmc_csrptr_t    unsigned long
+#define lmc_csrptr_t		unsigned long
=20
-#define LMC_REG_RANGE 0x80
+#define LMC_REG_RANGE		0x80
=20
-#define LMC_PRINTF_FMT  "%s"
-#define LMC_PRINTF_ARGS	(sc->lmc_device->name)
+#define LMC_PRINTF_FMT		"%s"
+#define LMC_PRINTF_ARGS		(sc->lmc_device->name)
=20
-#define TX_TIMEOUT (2*HZ)
+#define TX_TIMEOUT		(2*HZ)
=20
-#define LMC_TXDESCS            32
-#define LMC_RXDESCS            32
+#define LMC_TXDESCS		32
+#define LMC_RXDESCS		32
=20
-#define LMC_LINK_UP            1
-#define LMC_LINK_DOWN          0
+#define LMC_LINK_UP		1
+#define LMC_LINK_DOWN		0
=20
 /* These macros for generic read and write to and from the dec chip */
-#define LMC_CSR_READ(sc, csr) \
-	inl((sc)->lmc_csrs.csr)
-#define LMC_CSR_WRITE(sc, reg, val) \
-	outl((val), (sc)->lmc_csrs.reg)
-
-//#ifdef _LINUX_DELAY_H
-//	#define SLOW_DOWN_IO udelay(2);
-//	#undef __SLOW_DOWN_IO
-//	#define __SLOW_DOWN_IO udelay(2);
-//#endif
+#define LMC_CSR_READ(sc, csr)		inl((sc)->lmc_csrs.csr)
+#define LMC_CSR_WRITE(sc, reg, val)	outl((val), (sc)->lmc_csrs.reg)
=20
-#define DELAY(n) SLOW_DOWN_IO
+#define DELAY(n)		SLOW_DOWN_IO
=20
-#define lmc_delay() inl(sc->lmc_csrs.csr_9)
+#define lmc_delay()		inl(sc->lmc_csrs.csr_9)
=20
 /* This macro sync's up with the mii so that reads and writes can take=
 place */
-#define LMC_MII_SYNC(sc) do {int n=3D32; while( n >=3D 0 ) { \
-                LMC_CSR_WRITE((sc), csr_9, 0x20000); \
-		lmc_delay(); \
-		LMC_CSR_WRITE((sc), csr_9, 0x30000); \
-                lmc_delay(); \
-		n--; }} while(0)
+#define LMC_MII_SYNC(sc)					\
+	do {							\
+		int n =3D 32;					\
+		while (n >=3D 0) {				\
+			LMC_CSR_WRITE((sc), csr_9, 0x20000);	\
+			lmc_delay();				\
+			LMC_CSR_WRITE((sc), csr_9, 0x30000);	\
+			lmc_delay();				\
+			n--;					\
+		}						\
+	} while (0)
=20
 struct lmc_regfile_t {
-    lmc_csrptr_t csr_busmode;                  /* CSR0 */
-    lmc_csrptr_t csr_txpoll;                   /* CSR1 */
-    lmc_csrptr_t csr_rxpoll;                   /* CSR2 */
-    lmc_csrptr_t csr_rxlist;                   /* CSR3 */
-    lmc_csrptr_t csr_txlist;                   /* CSR4 */
-    lmc_csrptr_t csr_status;                   /* CSR5 */
-    lmc_csrptr_t csr_command;                  /* CSR6 */
-    lmc_csrptr_t csr_intr;                     /* CSR7 */
-    lmc_csrptr_t csr_missed_frames;            /* CSR8 */
-    lmc_csrptr_t csr_9;                        /* CSR9 */
-    lmc_csrptr_t csr_10;                       /* CSR10 */
-    lmc_csrptr_t csr_11;                       /* CSR11 */
-    lmc_csrptr_t csr_12;                       /* CSR12 */
-    lmc_csrptr_t csr_13;                       /* CSR13 */
-    lmc_csrptr_t csr_14;                       /* CSR14 */
-    lmc_csrptr_t csr_15;                       /* CSR15 */
+	lmc_csrptr_t csr_busmode;	/* CSR0 */
+	lmc_csrptr_t csr_txpoll;	/* CSR1 */
+	lmc_csrptr_t csr_rxpoll;	/* CSR2 */
+	lmc_csrptr_t csr_rxlist;	/* CSR3 */
+	lmc_csrptr_t csr_txlist;	/* CSR4 */
+	lmc_csrptr_t csr_status;	/* CSR5 */
+	lmc_csrptr_t csr_command;	/* CSR6 */
+	lmc_csrptr_t csr_intr;		/* CSR7 */
+	lmc_csrptr_t csr_missed_frames;	/* CSR8 */
+	lmc_csrptr_t csr_9;		/* CSR9 */
+	lmc_csrptr_t csr_10;		/* CSR10 */
+	lmc_csrptr_t csr_11;		/* CSR11 */
+	lmc_csrptr_t csr_12;		/* CSR12 */
+	lmc_csrptr_t csr_13;		/* CSR13 */
+	lmc_csrptr_t csr_14;		/* CSR14 */
+	lmc_csrptr_t csr_15;		/* CSR15 */
 };
=20
-#define csr_enetrom             csr_9   /* 21040 */
-#define csr_reserved            csr_10  /* 21040 */
-#define csr_full_duplex         csr_11  /* 21040 */
-#define csr_bootrom             csr_10  /* 21041/21140A/?? */
-#define csr_gp                  csr_12  /* 21140* */
-#define csr_watchdog            csr_15  /* 21140* */
-#define csr_gp_timer            csr_11  /* 21041/21140* */
-#define csr_srom_mii            csr_9   /* 21041/21140* */
-#define csr_sia_status          csr_12  /* 2104x */
-#define csr_sia_connectivity    csr_13  /* 2104x */
-#define csr_sia_tx_rx           csr_14  /* 2104x */
-#define csr_sia_general         csr_15  /* 2104x */
-
-/* tulip length/control transmit descriptor definitions
- *  used to define bits in the second tulip_desc_t field (length)
- *  for the transmit descriptor -baz */
-
-#define LMC_TDES_FIRST_BUFFER_SIZE       ((u32)(0x000007FF))
-#define LMC_TDES_SECOND_BUFFER_SIZE      ((u32)(0x003FF800))
-#define LMC_TDES_HASH_FILTERING          ((u32)(0x00400000))
-#define LMC_TDES_DISABLE_PADDING         ((u32)(0x00800000))
-#define LMC_TDES_SECOND_ADDR_CHAINED     ((u32)(0x01000000))
-#define LMC_TDES_END_OF_RING             ((u32)(0x02000000))
-#define LMC_TDES_ADD_CRC_DISABLE         ((u32)(0x04000000))
-#define LMC_TDES_SETUP_PACKET            ((u32)(0x08000000))
-#define LMC_TDES_INVERSE_FILTERING       ((u32)(0x10000000))
-#define LMC_TDES_FIRST_SEGMENT           ((u32)(0x20000000))
-#define LMC_TDES_LAST_SEGMENT            ((u32)(0x40000000))
+#define csr_enetrom		csr_9	/* 21040 */
+#define csr_reserved		csr_10	/* 21040 */
+#define csr_full_duplex		csr_11	/* 21040 */
+#define csr_bootrom		csr_10	/* 21041/21140A/?? */
+#define csr_gp			csr_12	/* 21140* */
+#define csr_watchdog		csr_15	/* 21140* */
+#define csr_gp_timer		csr_11	/* 21041/21140* */
+#define csr_srom_mii		csr_9	/* 21041/21140* */
+#define csr_sia_status		csr_12	/* 2104x */
+#define csr_sia_connectivity	csr_13	/* 2104x */
+#define csr_sia_tx_rx		csr_14	/* 2104x */
+#define csr_sia_general		csr_15	/* 2104x */
+
+/* tulip length/control transmit descriptor definitions used to define=
 bits
+   in the second tulip_desc_t field (length) for the transmit descript=
or */
+
+#define LMC_TDES_FIRST_BUFFER_SIZE	((u32)(0x000007FF))
+#define LMC_TDES_SECOND_BUFFER_SIZE	((u32)(0x003FF800))
+#define LMC_TDES_HASH_FILTERING		((u32)(0x00400000))
+#define LMC_TDES_DISABLE_PADDING	((u32)(0x00800000))
+#define LMC_TDES_SECOND_ADDR_CHAINED	((u32)(0x01000000))
+#define LMC_TDES_END_OF_RING		((u32)(0x02000000))
+#define LMC_TDES_ADD_CRC_DISABLE	((u32)(0x04000000))
+#define LMC_TDES_SETUP_PACKET		((u32)(0x08000000))
+#define LMC_TDES_INVERSE_FILTERING	((u32)(0x10000000))
+#define LMC_TDES_FIRST_SEGMENT		((u32)(0x20000000))
+#define LMC_TDES_LAST_SEGMENT		((u32)(0x40000000))
 #define LMC_TDES_INTERRUPT_ON_COMPLETION ((u32)(0x80000000))
=20
-#define TDES_SECOND_BUFFER_SIZE_BIT_NUMBER  11
-#define TDES_COLLISION_COUNT_BIT_NUMBER     3
+#define TDES_SECOND_BUFFER_SIZE_BIT_NUMBER	11
+#define TDES_COLLISION_COUNT_BIT_NUMBER		3
=20
 /* Constants for the RCV descriptor RDES */
=20
-#define LMC_RDES_OVERFLOW             ((u32)(0x00000001))
-#define LMC_RDES_CRC_ERROR            ((u32)(0x00000002))
-#define LMC_RDES_DRIBBLING_BIT        ((u32)(0x00000004))
-#define LMC_RDES_REPORT_ON_MII_ERR    ((u32)(0x00000008))
-#define LMC_RDES_RCV_WATCHDOG_TIMEOUT ((u32)(0x00000010))
-#define LMC_RDES_FRAME_TYPE           ((u32)(0x00000020))
-#define LMC_RDES_COLLISION_SEEN       ((u32)(0x00000040))
-#define LMC_RDES_FRAME_TOO_LONG       ((u32)(0x00000080))
-#define LMC_RDES_LAST_DESCRIPTOR      ((u32)(0x00000100))
-#define LMC_RDES_FIRST_DESCRIPTOR     ((u32)(0x00000200))
-#define LMC_RDES_MULTICAST_FRAME      ((u32)(0x00000400))
-#define LMC_RDES_RUNT_FRAME           ((u32)(0x00000800))
-#define LMC_RDES_DATA_TYPE            ((u32)(0x00003000))
-#define LMC_RDES_LENGTH_ERROR         ((u32)(0x00004000))
-#define LMC_RDES_ERROR_SUMMARY        ((u32)(0x00008000))
-#define LMC_RDES_FRAME_LENGTH         ((u32)(0x3FFF0000))
-#define LMC_RDES_OWN_BIT              ((u32)(0x80000000))
-
-#define RDES_FRAME_LENGTH_BIT_NUMBER       16
-
-#define LMC_RDES_ERROR_MASK ( (u32)( \
-	  LMC_RDES_OVERFLOW \
-	| LMC_RDES_DRIBBLING_BIT \
-	| LMC_RDES_REPORT_ON_MII_ERR \
-        | LMC_RDES_COLLISION_SEEN ) )
-
-
-/*
- * Ioctl info
- */
+#define LMC_RDES_OVERFLOW		((u32)(0x00000001))
+#define LMC_RDES_CRC_ERROR		((u32)(0x00000002))
+#define LMC_RDES_DRIBBLING_BIT		((u32)(0x00000004))
+#define LMC_RDES_REPORT_ON_MII_ERR	((u32)(0x00000008))
+#define LMC_RDES_RCV_WATCHDOG_TIMEOUT	((u32)(0x00000010))
+#define LMC_RDES_FRAME_TYPE		((u32)(0x00000020))
+#define LMC_RDES_COLLISION_SEEN		((u32)(0x00000040))
+#define LMC_RDES_FRAME_TOO_LONG		((u32)(0x00000080))
+#define LMC_RDES_LAST_DESCRIPTOR	((u32)(0x00000100))
+#define LMC_RDES_FIRST_DESCRIPTOR	((u32)(0x00000200))
+#define LMC_RDES_MULTICAST_FRAME	((u32)(0x00000400))
+#define LMC_RDES_RUNT_FRAME		((u32)(0x00000800))
+#define LMC_RDES_DATA_TYPE		((u32)(0x00003000))
+#define LMC_RDES_LENGTH_ERROR		((u32)(0x00004000))
+#define LMC_RDES_ERROR_SUMMARY		((u32)(0x00008000))
+#define LMC_RDES_FRAME_LENGTH		((u32)(0x3FFF0000))
+#define LMC_RDES_OWN_BIT		((u32)(0x80000000))
+
+#define RDES_FRAME_LENGTH_BIT_NUMBER	16
+
+#define LMC_RDES_ERROR_MASK ((u32)(LMC_RDES_OVERFLOW |		 \
+				   LMC_RDES_DRIBBLING_BIT |	 \
+				   LMC_RDES_REPORT_ON_MII_ERR |	 \
+				   LMC_RDES_COLLISION_SEEN))
+
+/* Ioctl info */
=20
 typedef struct {
-	u32	n;
-	u32	m;
-	u32	v;
-	u32	x;
-	u32	r;
-	u32	f;
-	u32	exact;
+	u32 n;
+	u32 m;
+	u32 v;
+	u32 x;
+	u32 r;
+	u32 f;
+	u32 exact;
 } lmc_av9110_t;
=20
-/*
- * Common structure passed to the ioctl code.
- */
+/* Common structure passed to the ioctl code. */
 struct lmc___ctl {
-	u32	cardtype;
-	u32	clock_source;		/* HSSI, T1 */
-	u32	clock_rate;		/* T1 */
-	u32	crc_length;
-	u32	cable_length;		/* DS3 */
-	u32	scrambler_onoff;	/* DS3 */
-	u32	cable_type;		/* T1 */
-	u32	keepalive_onoff;	/* protocol */
-	u32	ticks;			/* ticks/sec */
+	u32 cardtype;
+	u32 clock_source;		/* HSSI, T1 */
+	u32 clock_rate;			/* T1 */
+	u32 crc_length;
+	u32 cable_length;		/* DS3 */
+	u32 scrambler_onoff;		/* DS3 */
+	u32 cable_type;			/* T1 */
+	u32 keepalive_onoff;		/* protocol */
+	u32 ticks;			/* ticks/sec */
 	union {
-		lmc_av9110_t	ssi;
+		lmc_av9110_t ssi;
 	} cardspec;
-	u32       circuit_type;   /* T1 or E1 */
+	u32	circuit_type;		/* T1 or E1 */
 };
=20
=20
 /*
- * Carefull, look at the data sheet, there's more to this
- * structure than meets the eye.  It should probably be:
- *
- * struct tulip_desc_t {
- *         u8  own:1;
- *         u32 status:31;
- *         u32 control:10;
- *         u32 buffer1;
- *         u32 buffer2;
- * };
- * You could also expand status control to provide more bit informatio=
n
- */
+  Carefull, look at the data sheet, there's more to this structure tha=
n meets
+  the eye.  It should probably be:
+
+  struct tulip_desc_t {
+	u8 own:1;
+	u32 status:31;
+	u32 control:10;
+	u32 buffer1;
+	u32 buffer2;
+  };
+  You could also expand status control to provide more bit information=
 */
=20
 struct tulip_desc_t {
 	s32 status;
@@ -200,271 +187,254 @@ struct tulip_desc_t {
 	u32 buffer2;
 };
=20
-/*
- * media independent methods to check on media status, link, light LED=
s,
- * etc.
- */
+/* media independent methods to check on media status, link, light LED=
s, etc. */
 struct lmc___media {
-	void	(* init)(lmc_softc_t * const);
-	void	(* defaults)(lmc_softc_t * const);
-	void	(* set_status)(lmc_softc_t * const, lmc_ctl_t *);
-	void	(* set_clock_source)(lmc_softc_t * const, int);
-	void	(* set_speed)(lmc_softc_t * const, lmc_ctl_t *);
-	void	(* set_cable_length)(lmc_softc_t * const, int);
-	void	(* set_scrambler)(lmc_softc_t * const, int);
-	int	(* get_link_status)(lmc_softc_t * const);
-	void	(* set_link_status)(lmc_softc_t * const, int);
-	void	(* set_crc_length)(lmc_softc_t * const, int);
-        void    (* set_circuit_type)(lmc_softc_t * const, int);
-        void	(* watchdog)(lmc_softc_t * const);
+	void (* init)(lmc_softc_t * const);
+	void (* defaults)(lmc_softc_t * const);
+	void (* set_status)(lmc_softc_t * const, lmc_ctl_t *);
+	void (* set_clock_source)(lmc_softc_t * const, int);
+	void (* set_speed)(lmc_softc_t * const, lmc_ctl_t *);
+	void (* set_cable_length)(lmc_softc_t * const, int);
+	void (* set_scrambler)(lmc_softc_t * const, int);
+	int (* get_link_status)(lmc_softc_t * const);
+	void (* set_link_status)(lmc_softc_t * const, int);
+	void (* set_crc_length)(lmc_softc_t * const, int);
+	void (* set_circuit_type)(lmc_softc_t * const, int);
+	void (* watchdog)(lmc_softc_t * const);
 };
=20
-
-#define STATCHECK     0xBEEFCAFE
-
-struct lmc_extra_statistics
-{
-	u32       version_size;
-	u32       lmc_cardtype;
-
-	u32       tx_ProcTimeout;
-	u32       tx_IntTimeout;
-	u32       tx_NoCompleteCnt;
-	u32       tx_MaxXmtsB4Int;
-	u32       tx_TimeoutCnt;
-	u32       tx_OutOfSyncPtr;
-	u32       tx_tbusy0;
-	u32       tx_tbusy1;
-	u32       tx_tbusy_calls;
-	u32       resetCount;
-	u32       lmc_txfull;
-	u32       tbusy;
-	u32       dirtyTx;
-	u32       lmc_next_tx;
-	u32       otherTypeCnt;
-	u32       lastType;
-	u32       lastTypeOK;
-	u32       txLoopCnt;
-	u32       usedXmtDescripCnt;
-	u32       txIndexCnt;
-	u32       rxIntLoopCnt;
-
-	u32       rx_SmallPktCnt;
-	u32       rx_BadPktSurgeCnt;
-	u32       rx_BuffAllocErr;
-	u32       tx_lossOfClockCnt;
+#define STATCHECK 0xBEEFCAFE
+
+struct lmc_extra_statistics {
+	u32 version_size;
+	u32 lmc_cardtype;
+
+	u32 tx_ProcTimeout;
+	u32 tx_IntTimeout;
+	u32 tx_NoCompleteCnt;
+	u32 tx_MaxXmtsB4Int;
+	u32 tx_TimeoutCnt;
+	u32 tx_OutOfSyncPtr;
+	u32 tx_tbusy0;
+	u32 tx_tbusy1;
+	u32 tx_tbusy_calls;
+	u32 resetCount;
+	u32 lmc_txfull;
+	u32 tbusy;
+	u32 dirtyTx;
+	u32 lmc_next_tx;
+	u32 otherTypeCnt;
+	u32 lastType;
+	u32 lastTypeOK;
+	u32 txLoopCnt;
+	u32 usedXmtDescripCnt;
+	u32 txIndexCnt;
+	u32 rxIntLoopCnt;
+
+	u32 rx_SmallPktCnt;
+	u32 rx_BadPktSurgeCnt;
+	u32 rx_BuffAllocErr;
+	u32 tx_lossOfClockCnt;
=20
 	/* T1 error counters */
-	u32       framingBitErrorCount;
-	u32       lineCodeViolationCount;
+	u32 framingBitErrorCount;
+	u32 lineCodeViolationCount;
=20
-	u32       lossOfFrameCount;
-	u32       changeOfFrameAlignmentCount;
-	u32       severelyErroredFrameCount;
+	u32 lossOfFrameCount;
+	u32 changeOfFrameAlignmentCount;
+	u32 severelyErroredFrameCount;
=20
-	u32       check;
+	u32 check;
 };
=20
 typedef struct lmc_xinfo {
-	u32       Magic0;                         /* BEEFCAFE */
+	u32 Magic0;		/* BEEFCAFE */
=20
-	u32       PciCardType;
-	u32       PciSlotNumber;          /* PCI slot number       */
+	u32 PciCardType;
+	u32 PciSlotNumber;	/* PCI slot number	*/
=20
-	u16	       DriverMajorVersion;
-	u16	       DriverMinorVersion;
-	u16	       DriverSubVersion;
+	u16 DriverMajorVersion;
+	u16 DriverMinorVersion;
+	u16 DriverSubVersion;
=20
-	u16	       XilinxRevisionNumber;
-	u16	       MaxFrameSize;
+	u16 XilinxRevisionNumber;
+	u16 MaxFrameSize;
=20
-	u16     	  t1_alarm1_status;
-	u16       	t1_alarm2_status;
+	u16 t1_alarm1_status;
+	u16 t1_alarm2_status;
=20
-	int             link_status;
-	u32       mii_reg16;
+	int link_status;
+	u32 mii_reg16;
=20
-	u32       Magic1;                         /* DEADBEEF */
+	u32 Magic1;		/* DEADBEEF */
 } LMC_XINFO;
=20
=20
-/*
- * forward decl
- */
+/* forward decl */
 struct lmc___softc {
-	char                   *name;
-	u8			board_idx;
+	char *name;
+	u8 board_idx;
 	struct lmc_extra_statistics extra_stats;
-	struct net_device      *lmc_device;
-
-	int                     hang, rxdesc, bad_packet, some_counter;
-	u32  	         	txgo;
-	struct lmc_regfile_t	lmc_csrs;
-	volatile u32		lmc_txtick;
-	volatile u32		lmc_rxtick;
-	u32			lmc_flags;
-	u32			lmc_intrmask;	/* our copy of csr_intr */
-	u32			lmc_cmdmode;	/* our copy of csr_cmdmode */
-	u32			lmc_busmode;	/* our copy of csr_busmode */
-	u32			lmc_gpio_io;	/* state of in/out settings */
-	u32			lmc_gpio;	/* state of outputs */
-	struct sk_buff*		lmc_txq[LMC_TXDESCS];
-	struct sk_buff*		lmc_rxq[LMC_RXDESCS];
-	volatile
-	struct tulip_desc_t	lmc_rxring[LMC_RXDESCS];
-	volatile
-	struct tulip_desc_t	lmc_txring[LMC_TXDESCS];
-	unsigned int		lmc_next_rx, lmc_next_tx;
-	volatile
-	unsigned int		lmc_taint_tx, lmc_taint_rx;
-	int			lmc_tx_start, lmc_txfull;
-	int			lmc_txbusy;
-	u16			lmc_miireg16;
-	int			lmc_ok;
-	int			last_link_status;
-	int			lmc_cardtype;
-	u32               	last_frameerr;
-	lmc_media_t	       *lmc_media;
-	struct timer_list	timer;
-	lmc_ctl_t		ictl;
-	u32			TxDescriptControlInit;
-
-	int                     tx_TimeoutInd; /* additional driver state */
-	int                     tx_TimeoutDisplay;
-	unsigned int		lastlmc_taint_tx;
-	int                     lasttx_packets;
-	u32			tx_clockState;
-	u32			lmc_crcSize;
-	LMC_XINFO		lmc_xinfo;
-	char                    lmc_yel, lmc_blue, lmc_red; /* for T1 and DS3=
 */
-	char                    lmc_timing; /* for HSSI and SSI */
-	int                     got_irq;
-
-	char                    last_led_err[4];
-
-	u32                     last_int;
-	u32                     num_int;
-
-	spinlock_t              lmc_lock;
-	u16			if_type;       /* HDLC/PPP or NET */
-
-	/* Failure cases */
-	u8			failed_ring;
-	u8			failed_recv_alloc;
-
-	/* Structure check */
-	u32                     check;
+	struct net_device *lmc_device;
+
+	int hang, rxdesc, bad_packet, some_counter;
+	u32 txgo;
+	struct lmc_regfile_t lmc_csrs;
+	volatile u32 lmc_txtick;
+	volatile u32 lmc_rxtick;
+	u32 lmc_flags;
+	u32 lmc_intrmask;	/* our copy of csr_intr */
+	u32 lmc_cmdmode;	/* our copy of csr_cmdmode */
+	u32 lmc_busmode;	/* our copy of csr_busmode */
+	u32 lmc_gpio_io;	/* state of in/out settings */
+	u32 lmc_gpio;		/* state of outputs */
+	struct sk_buff *lmc_txq[LMC_TXDESCS];
+	struct sk_buff *lmc_rxq[LMC_RXDESCS];
+	volatile struct tulip_desc_t lmc_rxring[LMC_RXDESCS];
+	volatile struct tulip_desc_t lmc_txring[LMC_TXDESCS];
+	unsigned int lmc_next_rx, lmc_next_tx;
+	volatile unsigned int lmc_taint_tx, lmc_taint_rx;
+	int lmc_tx_start, lmc_txfull;
+	int lmc_txbusy;
+	u16 lmc_miireg16;
+	int lmc_ok;
+	int last_link_status;
+	int lmc_cardtype;
+	u32 last_frameerr;
+	lmc_media_t *lmc_media;
+	struct timer_list timer;
+	lmc_ctl_t ictl;
+	u32 TxDescriptControlInit;
+
+	int tx_TimeoutInd;		/* additional driver state */
+	int tx_TimeoutDisplay;
+	unsigned int lastlmc_taint_tx;
+	int lasttx_packets;
+	u32 tx_clockState;
+	u32 lmc_crcSize;
+	LMC_XINFO lmc_xinfo;
+	char lmc_yel, lmc_blue, lmc_red; /* for T1 and DS3 */
+	char lmc_timing;		/* for HSSI and SSI */
+	int got_irq;
+
+	char last_led_err[4];
+
+	u32 last_int;
+	u32 num_int;
+
+	spinlock_t lmc_lock;
+	u16 if_type;			/* HDLC/PPP or NET */
+
+	u8 failed_ring;			/* Failure cases */
+	u8 failed_recv_alloc;
+
+
+	u32 check;			/* Structure check */
 };
=20
-#define LMC_PCI_TIME 1
-#define LMC_EXT_TIME 0
+#define LMC_PCI_TIME		1
+#define LMC_EXT_TIME		0
=20
-#define PKT_BUF_SZ              1542  /* was 1536 */
+#define PKT_BUF_SZ		1542
=20
 /* CSR5 settings */
-#define TIMER_INT     0x00000800
-#define TP_LINK_FAIL  0x00001000
-#define TP_LINK_PASS  0x00000010
-#define NORMAL_INT    0x00010000
-#define ABNORMAL_INT  0x00008000
-#define RX_JABBER_INT 0x00000200
-#define RX_DIED       0x00000100
-#define RX_NOBUFF     0x00000080
-#define RX_INT        0x00000040
-#define TX_FIFO_UNDER 0x00000020
-#define TX_JABBER     0x00000008
-#define TX_NOBUFF     0x00000004
-#define TX_DIED       0x00000002
-#define TX_INT        0x00000001
+#define TIMER_INT		0x00000800
+#define TP_LINK_FAIL		0x00001000
+#define TP_LINK_PASS		0x00000010
+#define NORMAL_INT		0x00010000
+#define ABNORMAL_INT		0x00008000
+#define RX_JABBER_INT		0x00000200
+#define RX_DIED			0x00000100
+#define RX_NOBUFF		0x00000080
+#define RX_INT			0x00000040
+#define TX_FIFO_UNDER		0x00000020
+#define TX_JABBER		0x00000008
+#define TX_NOBUFF		0x00000004
+#define TX_DIED			0x00000002
+#define TX_INT			0x00000001
=20
 /* CSR6 settings */
-#define OPERATION_MODE  0x00000200 /* Full Duplex      */
-#define PROMISC_MODE    0x00000040 /* Promiscuous Mode */
-#define RECIEVE_ALL     0x40000000 /* Recieve All      */
-#define PASS_BAD_FRAMES 0x00000008 /* Pass Bad Frames  */
+#define OPERATION_MODE		0x00000200 /* Full Duplex */
+#define PROMISC_MODE		0x00000040 /* Promiscuous Mode */
+#define RECIEVE_ALL		0x40000000 /* Recieve All */
+#define PASS_BAD_FRAMES		0x00000008 /* Pass Bad Frames */
=20
-/* Dec control registers  CSR6 as well */
-#define LMC_DEC_ST 0x00002000
-#define LMC_DEC_SR 0x00000002
+/* Dec control registers. CSR6 as well */
+#define LMC_DEC_ST		0x00002000
+#define LMC_DEC_SR		0x00000002
=20
 /* CSR15 settings */
-#define RECV_WATCHDOG_DISABLE 0x00000010
-#define JABBER_DISABLE        0x00000001
+#define RECV_WATCHDOG_DISABLE	0x00000010
+#define JABBER_DISABLE		0x00000001
=20
 /* More settings */
-/*
- * aSR6 -- Command (Operation Mode) Register
- */
-#define TULIP_CMD_RECEIVEALL    0x40000000L /* (RW)  Receivel all fram=
es? */
-#define TULIP_CMD_MUSTBEONE     0x02000000L /* (RW)  Must Be One (2114=
0) */
-#define TULIP_CMD_TXTHRSHLDCTL  0x00400000L /* (RW)  Transmit Threshol=
d Mode (21140) */
-#define TULIP_CMD_STOREFWD      0x00200000L /* (RW)  Store and Foward =
(21140) */
-#define TULIP_CMD_NOHEARTBEAT   0x00080000L /* (RW)  No Heartbeat (211=
40) */
-#define TULIP_CMD_PORTSELECT    0x00040000L /* (RW)  Post Select (100M=
b) (21140) */
-#define TULIP_CMD_FULLDUPLEX    0x00000200L /* (RW)  Full Duplex Mode =
*/
-#define TULIP_CMD_OPERMODE      0x00000C00L /* (RW)  Operating Mode */
-#define TULIP_CMD_PROMISCUOUS   0x00000041L /* (RW)  Promiscuous Mode =
*/
-#define TULIP_CMD_PASSBADPKT    0x00000008L /* (RW)  Pass Bad Frames *=
/
-#define TULIP_CMD_THRESHOLDCTL  0x0000C000L /* (RW)  Threshold Control=
 */
-
-#define TULIP_GP_PINSET         0x00000100L
-#define TULIP_BUSMODE_SWRESET   0x00000001L
+/* aSR6 -- Command (Operation Mode) Register */
+#define TULIP_CMD_RECEIVEALL	0x40000000L /* (RW) Receivel all frames? =
*/
+#define TULIP_CMD_MUSTBEONE	0x02000000L /* (RW) Must Be One (21140) */
+#define TULIP_CMD_TXTHRSHLDCTL	0x00400000L /* (RW) Transmit Threshold =
Mode (21140) */
+#define TULIP_CMD_STOREFWD	0x00200000L /* (RW) Store and Foward (21140=
) */
+#define TULIP_CMD_NOHEARTBEAT	0x00080000L /* (RW) No Heartbeat (21140)=
 */
+#define TULIP_CMD_PORTSELECT	0x00040000L /* (RW) Post Select (100Mb) (=
21140) */
+#define TULIP_CMD_FULLDUPLEX	0x00000200L /* (RW) Full Duplex Mode */
+#define TULIP_CMD_OPERMODE	0x00000C00L /* (RW) Operating Mode */
+#define TULIP_CMD_PROMISCUOUS	0x00000041L /* (RW) Promiscuous Mode */
+#define TULIP_CMD_PASSBADPKT	0x00000008L /* (RW) Pass Bad Frames */
+#define TULIP_CMD_THRESHOLDCTL	0x0000C000L /* (RW) Threshold Control *=
/
+
+#define TULIP_GP_PINSET		0x00000100L
+#define TULIP_BUSMODE_SWRESET	0x00000001L
 #define TULIP_WATCHDOG_TXDISABLE 0x00000001L
 #define TULIP_WATCHDOG_RXDISABLE 0x00000010L
=20
-#define TULIP_STS_NORMALINTR    0x00010000L /* (RW)  Normal Interrupt =
*/
-#define TULIP_STS_ABNRMLINTR    0x00008000L /* (RW)  Abnormal Interrup=
t */
-#define TULIP_STS_ERI           0x00004000L /* (RW)  Early Receive Int=
errupt */
-#define TULIP_STS_SYSERROR      0x00002000L /* (RW)  System Error */
-#define TULIP_STS_GTE           0x00000800L /* (RW)  General Pupose Ti=
mer Exp */
-#define TULIP_STS_ETI           0x00000400L /* (RW)  Early Transmit In=
terrupt */
-#define TULIP_STS_RXWT          0x00000200L /* (RW)  Receiver Watchdog=
 Timeout */
-#define TULIP_STS_RXSTOPPED     0x00000100L /* (RW)  Receiver Process =
Stopped */
-#define TULIP_STS_RXNOBUF       0x00000080L /* (RW)  Receive Buf Unava=
il */
-#define TULIP_STS_RXINTR        0x00000040L /* (RW)  Receive Interrupt=
 */
-#define TULIP_STS_TXUNDERFLOW   0x00000020L /* (RW)  Transmit Underflo=
w */
-#define TULIP_STS_TXJABER       0x00000008L /* (RW)  Jabber timeout */
-#define TULIP_STS_TXNOBUF       0x00000004L
-#define TULIP_STS_TXSTOPPED     0x00000002L /* (RW)  Transmit Process =
Stopped */
-#define TULIP_STS_TXINTR        0x00000001L /* (RW)  Transmit Interrup=
t */
-
-#define TULIP_STS_RXS_STOPPED   0x00000000L /*        000 - Stopped */
-
-#define TULIP_STS_RXSTOPPED     0x00000100L             /* (RW)  Recei=
ve Process Stopped */
-#define TULIP_STS_RXNOBUF       0x00000080L
-
-#define TULIP_CMD_TXRUN         0x00002000L /* (RW)  Start/Stop Transm=
itter */
-#define TULIP_CMD_RXRUN         0x00000002L /* (RW)  Start/Stop Receiv=
e Filtering */
-#define TULIP_DSTS_TxDEFERRED   0x00000001      /* Initially Deferred =
*/
-#define TULIP_DSTS_OWNER        0x80000000      /* Owner (1 =3D 21040)=
 */
-#define TULIP_DSTS_RxMIIERR     0x00000008
-#define LMC_DSTS_ERRSUM         (TULIP_DSTS_RxMIIERR)
-
-#define TULIP_DEFAULT_INTR_MASK  (TULIP_STS_NORMALINTR \
-  | TULIP_STS_RXINTR       \
-  | TULIP_STS_TXINTR     \
-  | TULIP_STS_ABNRMLINTR \
-  | TULIP_STS_SYSERROR   \
-  | TULIP_STS_TXSTOPPED  \
-  | TULIP_STS_TXUNDERFLOW\
-  | TULIP_STS_RXSTOPPED )
-
-#define DESC_OWNED_BY_SYSTEM   ((u32)(0x00000000))
-#define DESC_OWNED_BY_DC21X4   ((u32)(0x80000000))
+#define TULIP_STS_NORMALINTR	0x00010000L /* (RW) Normal Interrupt */
+#define TULIP_STS_ABNRMLINTR	0x00008000L /* (RW) Abnormal Interrupt */
+#define TULIP_STS_ERI		0x00004000L /* (RW) Early Receive Interrupt */
+#define TULIP_STS_SYSERROR	0x00002000L /* (RW) System Error */
+#define TULIP_STS_GTE		0x00000800L /* (RW) General Pupose Timer Exp */
+#define TULIP_STS_ETI		0x00000400L /* (RW) Early Transmit Interrupt */
+#define TULIP_STS_RXWT		0x00000200L /* (RW) Receiver Watchdog Timeout =
*/
+#define TULIP_STS_RXSTOPPED	0x00000100L /* (RW) Receiver Process Stopp=
ed */
+#define TULIP_STS_RXNOBUF	0x00000080L /* (RW) Receive Buf Unavail */
+#define TULIP_STS_RXINTR	0x00000040L /* (RW) Receive Interrupt */
+#define TULIP_STS_TXUNDERFLOW	0x00000020L /* (RW) Transmit Underflow *=
/
+#define TULIP_STS_TXJABER	0x00000008L /* (RW) Jabber timeout */
+#define TULIP_STS_TXNOBUF	0x00000004L
+#define TULIP_STS_TXSTOPPED	0x00000002L /* (RW) Transmit Process Stopp=
ed */
+#define TULIP_STS_TXINTR	0x00000001L /* (RW) Transmit Interrupt */
+
+#define TULIP_STS_RXS_STOPPED	0x00000000L /*	000 - Stopped */
+
+#define TULIP_STS_RXSTOPPED	0x00000100L /* (RW) Receive Process Stoppe=
d */
+#define TULIP_STS_RXNOBUF	0x00000080L
+
+#define TULIP_CMD_TXRUN		0x00002000L /* (RW) Start/Stop Transmitter */
+#define TULIP_CMD_RXRUN		0x00000002L /* (RW) Start/Stop Receive Filter=
ing */
+#define TULIP_DSTS_TxDEFERRED	0x00000001	/* Initially Deferred */
+#define TULIP_DSTS_OWNER	0x80000000	/* Owner (1 =3D 21040) */
+#define TULIP_DSTS_RxMIIERR	0x00000008
+#define LMC_DSTS_ERRSUM		(TULIP_DSTS_RxMIIERR)
+
+#define TULIP_DEFAULT_INTR_MASK	(TULIP_STS_NORMALINTR | TULIP_STS_RXIN=
TR | \
+				 TULIP_STS_TXINTR | TULIP_STS_ABNRMLINTR | \
+				 TULIP_STS_SYSERROR | TULIP_STS_TXSTOPPED | \
+				 TULIP_STS_TXUNDERFLOW | TULIP_STS_RXSTOPPED)
+
+#define DESC_OWNED_BY_SYSTEM	((u32)(0x00000000))
+#define DESC_OWNED_BY_DC21X4	((u32)(0x80000000))
=20
 #ifndef TULIP_CMD_RECEIVEALL
-#define TULIP_CMD_RECEIVEALL 0x40000000L
+#define TULIP_CMD_RECEIVEALL	0x40000000L
 #endif
=20
 /* Adapter module number */
-#define LMC_ADAP_HSSI           2
-#define LMC_ADAP_DS3            3
-#define LMC_ADAP_SSI            4
-#define LMC_ADAP_T1             5
+#define LMC_ADAP_HSSI		2
+#define LMC_ADAP_DS3		3
+#define LMC_ADAP_SSI		4
+#define LMC_ADAP_T1		5
=20
-#define LMC_MTU 1500
+#define LMC_MTU			1500
=20
-#define LMC_CRC_LEN_16 2  /* 16-bit CRC */
-#define LMC_CRC_LEN_32 4
+#define LMC_CRC_LEN_16		2	/* 16-bit CRC */
+#define LMC_CRC_LEN_32		4
=20
 #endif /* _LMC_VAR_H_ */
--=20
1.7.1.1

