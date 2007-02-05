From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH 01/02] misc-net-drivers: Use ARRAY_SIZE macro when appropriate
Date: Mon, 5 Feb 2007 18:56:57 +0200
Message-ID: <20070205165657.GG3896@Ahmed>
References: <20070205165429.GD3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:41380 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbXBEQ5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 11:57:05 -0500
Received: by an-out-0708.google.com with SMTP id b33so1069463ana
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 08:57:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20070205165429.GD3896@Ahmed>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A 2.6.20 patch to use ARRAY_SIZE macro already defined in kernel.h for some
miscellaneous network drivers with no specific maintaners.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
---
[PATCH 01/02] is compile tested.
[PATCH 02/02] isn't compile tested cause of missing hardware.

diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 4612f71..d48196c 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -806,7 +806,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 		        i = cs8900_irq_map[0];
 #else
 			/* Translate the IRQ using the IRQ mapping table. */
-			if (i >= sizeof(cs8900_irq_map)/sizeof(cs8900_irq_map[0]))
+			if (i >= ARRAY_SIZE(cs8900_irq_map))
 				printk("\ncs89x0: invalid ISA interrupt number %d\n", i);
 			else
 				i = cs8900_irq_map[i];
@@ -1248,11 +1248,11 @@ write_irq(struct net_device *dev, int chip_type, int irq)
 
 	if (chip_type == CS8900) {
 		/* Search the mapping table for the corresponding IRQ pin. */
-		for (i = 0; i != sizeof(cs8900_irq_map)/sizeof(cs8900_irq_map[0]); i++)
+		for (i = 0; i != ARRAY_SIZE(cs8900_irq_map); i++)
 			if (cs8900_irq_map[i] == irq)
 				break;
 		/* Not found */
-		if (i == sizeof(cs8900_irq_map)/sizeof(cs8900_irq_map[0]))
+		if (i == ARRAY_SIZE(cs8900_irq_map))
 			i = 3;
 		writereg(dev, PP_CS8900_ISAINT, i);
 	} else {
diff --git a/drivers/net/irda/actisys-sir.c b/drivers/net/irda/actisys-sir.c
index 9715ab5..84d7bb0 100644
--- a/drivers/net/irda/actisys-sir.c
+++ b/drivers/net/irda/actisys-sir.c
@@ -43,6 +43,7 @@
 #include <linux/module.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/kernel.h>
 
 #include <net/irda/irda.h>
 
@@ -67,7 +68,7 @@ static int actisys_reset(struct sir_dev *);
 /* Note : the 220L doesn't support 38400, but we will fix that below */
 static unsigned baud_rates[] = { 9600, 19200, 57600, 115200, 38400 };
 
-#define MAX_SPEEDS (sizeof(baud_rates)/sizeof(baud_rates[0]))
+#define MAX_SPEEDS ARRAY_SIZE(baud_rates)
 
 static struct dongle_driver act220l = {
 	.owner		= THIS_MODULE,
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index 177c502..4b016aa 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -515,7 +515,7 @@ CLEAR_INT(void) {
 	outb(0, IOADDR+8);
 }
 
-#define SIZE(x)	(sizeof(x)/sizeof((x)[0]))
+#define SIZE(x)	ARRAY_SIZE(x)
 
 #if 0
 /* selftest or dump */
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index a5c4199..7081d08 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -379,7 +379,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 			{E8390_RREAD+E8390_START, E8390_CMD},
 		};
 
-		for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 			outb_p(program_seq[i].value, ioaddr + program_seq[i].offset);
 
 	}
diff --git a/drivers/net/ne2.c b/drivers/net/ne2.c
index 089b5bb..c6c2a91 100644
--- a/drivers/net/ne2.c
+++ b/drivers/net/ne2.c
@@ -432,7 +432,7 @@ static int __init ne2_probe1(struct net_device *dev, int slot)
 			{E8390_RREAD+E8390_START, E8390_CMD},
 		};
 
-		for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 			outb_p(program_seq[i].value, base_addr +
 				program_seq[i].offset);
 
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index 589785d..6bafdda 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -309,7 +309,7 @@ static int __devinit ne2k_pci_init_one (struct pci_dev *pdev,
 			{0x00,	EN0_RSARHI},
 			{E8390_RREAD+E8390_START, E8390_CMD},
 		};
-		for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 			outb(program_seq[i].value, ioaddr + program_seq[i].offset);
 
 	}
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index f263232..7f93c08 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -395,7 +395,7 @@ int netxen_is_flash_supported(struct netxen_adapter *adapter)
 	/* if the flash size less than 4Mb, make huge war cry and die */
 	for (j = 1; j < 4; j++) {
 		addr = j * NETXEN_NIC_WINDOW_MARGIN;
-		for (i = 0; i < (sizeof(locs) / sizeof(locs[0])); i++) {
+		for (i = 0; i < ARRAY_SIZE(locs); i++) {
 			if (netxen_rom_fast_read(adapter, locs[i], &val01) == 0
 			    && netxen_rom_fast_read(adapter, (addr + locs[i]),
 						    &val02) == 0) {
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 6139048..6b64ea4 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -232,7 +232,7 @@ static int get_prom(struct pcmcia_device *link)
     axnet_reset_8390(dev);
     mdelay(10);
 
-    for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+    for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 	outb_p(program_seq[i].value, ioaddr + program_seq[i].offset);
 
     for (i = 0; i < 6; i += 2) {
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index d88e9b2..e652246 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -375,7 +375,7 @@ static hw_info_t *get_prom(struct pcmcia_device *link)
     pcnet_reset_8390(dev);
     mdelay(10);
 
-    for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+    for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 	outb_p(program_seq[i].value, ioaddr + program_seq[i].offset);
 
     for (i = 0; i < 32; i++)
diff --git a/drivers/net/sk98lin/skgemib.c b/drivers/net/sk98lin/skgemib.c
index 0a6f67a..625cb25 100644
--- a/drivers/net/sk98lin/skgemib.c
+++ b/drivers/net/sk98lin/skgemib.c
@@ -22,6 +22,8 @@
  *
  ******************************************************************************/
 
+#include <linux/kernel.h>
+
 /*
  * PRIVATE OID handler function prototypes
  */
@@ -82,7 +84,7 @@ PNMI_STATIC int DiagActions(SK_AC *pAC, SK_IOC IoC, int action, SK_U32 Id,
 
 
 /* defines *******************************************************************/
-#define ID_TABLE_SIZE (sizeof(IdTable)/sizeof(IdTable[0]))
+#define ID_TABLE_SIZE ARRAY_SIZE(IdTable)
 
 
 /* global variables **********************************************************/
diff --git a/drivers/net/sk98lin/skgesirq.c b/drivers/net/sk98lin/skgesirq.c
index 3e7aa49..83e1544 100644
--- a/drivers/net/sk98lin/skgesirq.c
+++ b/drivers/net/sk98lin/skgesirq.c
@@ -51,6 +51,7 @@ static const char SysKonnectFileId[] =
 	"@(#) $Id: skgesirq.c,v 1.92 2003/09/16 14:37:07 rschmidt Exp $ (C) Marvell.";
 #endif
 
+#include <linux/kernel.h>
 #include "h/skdrv1st.h"		/* Driver Specific Definitions */
 #ifndef SK_SLIM
 #include "h/skgepnmi.h"		/* PNMI Definitions */
@@ -892,7 +893,7 @@ int		Port)		/* Which port should be checked */
 	 */
 	RxCts = 0;
 
-	for (i = 0; i < sizeof(SkGeRxRegs)/sizeof(SkGeRxRegs[0]); i++) {
+	for (i = 0; i < ARRAY_SIZE(SkGeRxRegs); i++) {
 		
 		(void)SkXmMacStatistic(pAC, IoC, Port, SkGeRxRegs[i], &RxTmp);
 		
diff --git a/drivers/net/skfp/smt.c b/drivers/net/skfp/smt.c
index 99a776a..6820989 100644
--- a/drivers/net/skfp/smt.c
+++ b/drivers/net/skfp/smt.c
@@ -14,6 +14,7 @@
  *
  ******************************************************************************/
 
+#include <linux/kernel.h>
 #include "h/types.h"
 #include "h/fddi.h"
 #include "h/smc.h"
@@ -1655,7 +1656,7 @@ static const struct smt_pdef {
 	{ SMT_P4053,	0,	SWAP_SMT_P4053			} ,
 } ;
 
-#define N_SMT_PLEN	(sizeof(smt_pdef)/sizeof(smt_pdef[0]))
+#define N_SMT_PLEN	ARRAY_SIZE(smt_pdef)
 
 int smt_check_para(struct s_smc *smc, struct smt_header	*sm,
 		   const u_short list[])
diff --git a/drivers/net/skfp/srf.c b/drivers/net/skfp/srf.c
index 16573ac..0f47297 100644
--- a/drivers/net/skfp/srf.c
+++ b/drivers/net/skfp/srf.c
@@ -19,6 +19,8 @@
 	SRF state machine and frame generation
 */
 
+#include <linux/kernel.h>
+
 #include "h/types.h"
 #include "h/fddi.h"
 #include "h/smc.h"
@@ -43,7 +45,7 @@ static void clear_reported(struct s_smc *smc);
 static void smt_send_srf(struct s_smc *smc);
 static struct s_srf_evc *smt_get_evc(struct s_smc *smc, int code, int index);
 
-#define MAX_EVCS	(sizeof(smc->evcs)/sizeof(smc->evcs[0]))
+#define MAX_EVCS	ARRAY_SIZE(smc->evcs)
 
 struct evc_init {
 	u_char code ;
@@ -67,7 +69,7 @@ static const struct evc_init evc_inits[] = {
 	{ SMT_EVENT_PORT_PATH_CHANGE,		INDEX_PORT,NUMPHYS,SMT_P4053 } ,
 } ;
 
-#define MAX_INIT_EVC	(sizeof(evc_inits)/sizeof(evc_inits[0]))
+#define MAX_INIT_EVC	ARRAY_SIZE(evc_inits)
 
 void smt_init_evc(struct s_smc *smc)
 {


-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
