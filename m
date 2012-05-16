From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 4/4] tokenring: delete all remaining driver support
Date: Tue, 15 May 2012 20:35:44 -0400
Message-ID: <1337128544-18680-5-git-send-email-paul.gortmaker@windriver.com>
References: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44458 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967099Ab2EPAge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 20:36:34 -0400
In-Reply-To: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This represents the mass deletion of the of the tokenring support.

It gets rid of:
  - the net/tr.c which the drivers depended on
  - the drivers/net component
  - the Kbuild infrastructure around it
  - any tokenring related CONFIG_ settings in any defconfigs
  - the tokenring headers in the include/linux dir
  - the firmware associated with the tokenring drivers.
  - any associated token ring documentation.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 Documentation/filesystems/proc.txt    |    1 -
 Documentation/networking/00-INDEX     |    8 -
 Documentation/networking/3c359.txt    |   58 -
 Documentation/networking/olympic.txt  |   79 -
 Documentation/networking/smctr.txt    |   66 -
 Documentation/networking/tms380tr.txt |  147 -
 arch/mips/configs/mtx1_defconfig      |    4 -
 arch/xtensa/configs/common_defconfig  |    5 -
 drivers/message/fusion/mptlan.h       |    1 -
 drivers/net/Kconfig                   |    2 -
 drivers/net/Makefile                  |    1 -
 drivers/net/Space.c                   |   46 -
 drivers/net/tokenring/3c359.c         | 1831 -----------
 drivers/net/tokenring/3c359.h         |  291 --
 drivers/net/tokenring/Kconfig         |  199 --
 drivers/net/tokenring/Makefile        |   16 -
 drivers/net/tokenring/abyss.c         |  468 ---
 drivers/net/tokenring/abyss.h         |   58 -
 drivers/net/tokenring/ibmtr.c         | 1964 -----------
 drivers/net/tokenring/ibmtr_cs.c      |  370 ---
 drivers/net/tokenring/lanstreamer.c   | 1909 -----------
 drivers/net/tokenring/lanstreamer.h   |  343 --
 drivers/net/tokenring/madgemc.c       |  761 -----
 drivers/net/tokenring/madgemc.h       |   70 -
 drivers/net/tokenring/olympic.c       | 1737 ----------
 drivers/net/tokenring/olympic.h       |  321 --
 drivers/net/tokenring/proteon.c       |  422 ---
 drivers/net/tokenring/skisa.c         |  432 ---
 drivers/net/tokenring/smctr.c         | 5717 ---------------------------------
 drivers/net/tokenring/smctr.h         | 1585 ---------
 drivers/net/tokenring/tms380tr.c      | 2306 -------------
 drivers/net/tokenring/tms380tr.h      | 1141 -------
 drivers/net/tokenring/tmspci.c        |  236 --
 firmware/3com/3C359.bin.ihex          | 1573 ---------
 firmware/Makefile                     |    2 -
 firmware/WHENCE                       |   38 -
 firmware/tr_smctr.bin.ihex            |  477 ---
 include/linux/Kbuild                  |    1 -
 include/linux/ibmtr.h                 |  373 ---
 include/linux/if_tr.h                 |  103 -
 include/linux/trdevice.h              |   37 -
 net/802/Makefile                      |    1 -
 net/802/tr.c                          |  669 ----
 43 files changed, 0 insertions(+), 25869 deletions(-)
 delete mode 100644 Documentation/networking/3c359.txt
 delete mode 100644 Documentation/networking/olympic.txt
 delete mode 100644 Documentation/networking/smctr.txt
 delete mode 100644 Documentation/networking/tms380tr.txt
 delete mode 100644 drivers/net/tokenring/3c359.c
 delete mode 100644 drivers/net/tokenring/3c359.h
 delete mode 100644 drivers/net/tokenring/Kconfig
 delete mode 100644 drivers/net/tokenring/Makefile
 delete mode 100644 drivers/net/tokenring/abyss.c
 delete mode 100644 drivers/net/tokenring/abyss.h
 delete mode 100644 drivers/net/tokenring/ibmtr.c
 delete mode 100644 drivers/net/tokenring/ibmtr_cs.c
 delete mode 100644 drivers/net/tokenring/lanstreamer.c
 delete mode 100644 drivers/net/tokenring/lanstreamer.h
 delete mode 100644 drivers/net/tokenring/madgemc.c
 delete mode 100644 drivers/net/tokenring/madgemc.h
 delete mode 100644 drivers/net/tokenring/olympic.c
 delete mode 100644 drivers/net/tokenring/olympic.h
 delete mode 100644 drivers/net/tokenring/proteon.c
 delete mode 100644 drivers/net/tokenring/skisa.c
 delete mode 100644 drivers/net/tokenring/smctr.c
 delete mode 100644 drivers/net/tokenring/smctr.h
 delete mode 100644 drivers/net/tokenring/tms380tr.c
 delete mode 100644 drivers/net/tokenring/tms380tr.h
 delete mode 100644 drivers/net/tokenring/tmspci.c
 delete mode 100644 firmware/3com/3C359.bin.ihex
 delete mode 100644 firmware/tr_smctr.bin.ihex
 delete mode 100644 include/linux/ibmtr.h
 delete mode 100644 include/linux/if_tr.h
 delete mode 100644 include/linux/trdevice.h
 delete mode 100644 net/802/tr.c

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index b7413cb..ef088e5 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -996,7 +996,6 @@ Table 1-9: Network info in /proc/net
  snmp          SNMP data                                                       
  sockstat      Socket statistics                                               
  tcp           TCP  sockets                                                    
- tr_rif        Token ring RIF routing table                                    
  udp           UDP sockets                                                     
  unix          UNIX domain sockets                                             
  wireless      Wireless interface data (Wavelan etc)                           
diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index 9ad9dde..2cc3c77 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -1,7 +1,5 @@
 00-INDEX
 	- this file
-3c359.txt
-	- information on the 3Com TokenLink Velocity XL (3c5359) driver.
 3c505.txt
 	- information on the 3Com EtherLink Plus (3c505) driver.
 3c509.txt
@@ -142,8 +140,6 @@ netif-msg.txt
 	- Design of the network interface message level setting (NETIF_MSG_*).
 nfc.txt
 	- The Linux Near Field Communication (NFS) subsystem.
-olympic.txt
-	- IBM PCI Pit/Pit-Phy/Olympic Token Ring driver info.
 openvswitch.txt
 	- Open vSwitch developer documentation.
 operstates.txt
@@ -184,8 +180,6 @@ skfp.txt
 	- SysKonnect FDDI (SK-5xxx, Compaq Netelligent) driver info.
 smc9.txt
 	- the driver for SMC's 9000 series of Ethernet cards
-smctr.txt
-	- SMC TokenCard TokenRing Linux driver info.
 spider-net.txt
 	- README for the Spidernet Driver (as found in PS3 / Cell BE).
 stmmac.txt
@@ -200,8 +194,6 @@ tcp-thin.txt
 	- kernel tuning options for low rate 'thin' TCP streams.
 tlan.txt
 	- ThunderLAN (Compaq Netelligent 10/100, Olicom OC-2xxx) driver info.
-tms380tr.txt
-	- SysKonnect Token Ring ISA/PCI adapter driver info.
 tproxy.txt
 	- Transparent proxy support user guide.
 tuntap.txt
diff --git a/Documentation/networking/3c359.txt b/Documentation/networking/3c359.txt
deleted file mode 100644
index dadfe81..0000000
diff --git a/Documentation/networking/olympic.txt b/Documentation/networking/olympic.txt
deleted file mode 100644
index b95b5bf..0000000
diff --git a/Documentation/networking/smctr.txt b/Documentation/networking/smctr.txt
deleted file mode 100644
index 9af25b8..0000000
diff --git a/Documentation/networking/tms380tr.txt b/Documentation/networking/tms380tr.txt
deleted file mode 100644
index 1f73e13..0000000
diff --git a/arch/mips/configs/mtx1_defconfig b/arch/mips/configs/mtx1_defconfig
index 807c97e..46c61edc 100644
--- a/arch/mips/configs/mtx1_defconfig
+++ b/arch/mips/configs/mtx1_defconfig
@@ -346,11 +346,8 @@ CONFIG_CHELSIO_T1=m
 CONFIG_IXGB=m
 CONFIG_S2IO=m
 CONFIG_MYRI10GE=m
-CONFIG_TR=y
 CONFIG_IBMOL=m
 CONFIG_IBMLS=m
-CONFIG_3C359=m
-CONFIG_TMS380TR=m
 CONFIG_TMSPCI=m
 CONFIG_ABYSS=m
 CONFIG_USB_CATC=m
@@ -376,7 +373,6 @@ CONFIG_PCMCIA_SMC91C92=m
 CONFIG_PCMCIA_XIRC2PS=m
 CONFIG_PCMCIA_AXNET=m
 CONFIG_ARCNET_COM20020_CS=m
-CONFIG_PCMCIA_IBMTR=m
 CONFIG_WAN=y
 CONFIG_LANMEDIA=m
 CONFIG_HDLC=m
diff --git a/arch/xtensa/configs/common_defconfig b/arch/xtensa/configs/common_defconfig
index b90038e..a182a4e 100644
--- a/arch/xtensa/configs/common_defconfig
+++ b/arch/xtensa/configs/common_defconfig
@@ -333,11 +333,6 @@ CONFIG_XT2000_SONIC=y
 # CONFIG_S2IO is not set
 
 #
-# Token Ring devices
-#
-# CONFIG_TR is not set
-
-#
 # Wireless LAN (non-hamradio)
 #
 CONFIG_NET_RADIO=y
diff --git a/drivers/message/fusion/mptlan.h b/drivers/message/fusion/mptlan.h
index c171afa..69e9d54 100644
--- a/drivers/message/fusion/mptlan.h
+++ b/drivers/message/fusion/mptlan.h
@@ -69,7 +69,6 @@
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
 #include <linux/delay.h>
-// #include <linux/trdevice.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 78a6259..0c2bd80 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -282,8 +282,6 @@ source "drivers/net/slip/Kconfig"
 
 source "drivers/s390/net/Kconfig"
 
-source "drivers/net/tokenring/Kconfig"
-
 source "drivers/net/usb/Kconfig"
 
 source "drivers/net/wireless/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index a6b8ce1..3d375ca 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -50,7 +50,6 @@ obj-$(CONFIG_SLIP) += slip/
 obj-$(CONFIG_SLHC) += slip/
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_SUNGEM_PHY) += sungem_phy.o
-obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
 obj-$(CONFIG_WLAN) += wireless/
 obj-$(CONFIG_WIMAX) += wimax/
diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 88bbd8f..486e2dc 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -29,7 +29,6 @@
  */
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/trdevice.h>
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/netlink.h>
@@ -284,46 +283,6 @@ static void __init ethif_probe2(int unit)
 		probe_list2(unit, parport_probes, base_addr == 0));
 }
 
-#ifdef CONFIG_TR
-/* Token-ring device probe */
-extern int ibmtr_probe_card(struct net_device *);
-extern struct net_device *smctr_probe(int unit);
-
-static struct devprobe2 tr_probes2[] __initdata = {
-#ifdef CONFIG_SMCTR
-	{smctr_probe, 0},
-#endif
-	{NULL, 0},
-};
-
-static __init int trif_probe(int unit)
-{
-	int err = -ENODEV;
-#ifdef CONFIG_IBMTR
-	struct net_device *dev = alloc_trdev(0);
-	if (!dev)
-		return -ENOMEM;
-
-	sprintf(dev->name, "tr%d", unit);
-	netdev_boot_setup_check(dev);
-	err = ibmtr_probe_card(dev);
-	if (err)
-		free_netdev(dev);
-#endif
-	return err;
-}
-
-static void __init trif_probe2(int unit)
-{
-	unsigned long base_addr = netdev_boot_base("tr", unit);
-
-	if (base_addr == 1)
-		return;
-	probe_list2(unit, tr_probes2, base_addr == 0);
-}
-#endif
-
-
 /*  Statically configured drivers -- order matters here. */
 static int __init net_olddevs_init(void)
 {
@@ -333,11 +292,6 @@ static int __init net_olddevs_init(void)
 	for (num = 0; num < 8; ++num)
 		sbni_probe(num);
 #endif
-#ifdef CONFIG_TR
-	for (num = 0; num < 8; ++num)
-		if (!trif_probe(num))
-			trif_probe2(num);
-#endif
 	for (num = 0; num < 8; ++num)
 		ethif_probe2(num);
 
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
deleted file mode 100644
index 0924f57..0000000
diff --git a/drivers/net/tokenring/3c359.h b/drivers/net/tokenring/3c359.h
deleted file mode 100644
index bcb1a6b..0000000
diff --git a/drivers/net/tokenring/Kconfig b/drivers/net/tokenring/Kconfig
deleted file mode 100644
index ef3bb13..0000000
diff --git a/drivers/net/tokenring/Makefile b/drivers/net/tokenring/Makefile
deleted file mode 100644
index f1be8d9..0000000
diff --git a/drivers/net/tokenring/abyss.c b/drivers/net/tokenring/abyss.c
deleted file mode 100644
index b715e6b..0000000
diff --git a/drivers/net/tokenring/abyss.h b/drivers/net/tokenring/abyss.h
deleted file mode 100644
index b0a473b..0000000
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
deleted file mode 100644
index b5c8c18..0000000
diff --git a/drivers/net/tokenring/ibmtr_cs.c b/drivers/net/tokenring/ibmtr_cs.c
deleted file mode 100644
index 356e28e..0000000
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
deleted file mode 100644
index 97e4c65..0000000
diff --git a/drivers/net/tokenring/lanstreamer.h b/drivers/net/tokenring/lanstreamer.h
deleted file mode 100644
index 3c58d6a..0000000
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
deleted file mode 100644
index 28adcdf..0000000
diff --git a/drivers/net/tokenring/madgemc.h b/drivers/net/tokenring/madgemc.h
deleted file mode 100644
index fe88e27..0000000
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
deleted file mode 100644
index 4d45fe8..0000000
diff --git a/drivers/net/tokenring/olympic.h b/drivers/net/tokenring/olympic.h
deleted file mode 100644
index 30631ba..0000000
diff --git a/drivers/net/tokenring/proteon.c b/drivers/net/tokenring/proteon.c
deleted file mode 100644
index 62d90e4..0000000
diff --git a/drivers/net/tokenring/skisa.c b/drivers/net/tokenring/skisa.c
deleted file mode 100644
index ee11e93..0000000
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
deleted file mode 100644
index cb35fb7..0000000
diff --git a/drivers/net/tokenring/smctr.h b/drivers/net/tokenring/smctr.h
deleted file mode 100644
index 6e5700a..0000000
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
deleted file mode 100644
index b5e0855..0000000
diff --git a/drivers/net/tokenring/tms380tr.h b/drivers/net/tokenring/tms380tr.h
deleted file mode 100644
index e5a617c..0000000
diff --git a/drivers/net/tokenring/tmspci.c b/drivers/net/tokenring/tmspci.c
deleted file mode 100644
index 90f3fa4..0000000
diff --git a/firmware/3com/3C359.bin.ihex b/firmware/3com/3C359.bin.ihex
deleted file mode 100644
index 781bac3..0000000
diff --git a/firmware/Makefile b/firmware/Makefile
index 0d15a3d..344713b 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -26,7 +26,6 @@ fw-shipped- += acenic/tg1.bin
 else
 acenic-objs := acenic/tg1.bin acenic/tg2.bin
 endif
-fw-shipped-$(CONFIG_3C359) += 3com/3C359.bin
 fw-shipped-$(CONFIG_ACENIC) += $(acenic-objs)
 fw-shipped-$(CONFIG_ADAPTEC_STARFIRE) += adaptec/starfire_rx.bin \
 					 adaptec/starfire_tx.bin
@@ -86,7 +85,6 @@ fw-shipped-$(CONFIG_SCSI_QLOGIC_1280) += qlogic/1040.bin qlogic/1280.bin \
 					 qlogic/12160.bin
 fw-shipped-$(CONFIG_SCSI_QLOGICPTI) += qlogic/isp1000.bin
 fw-shipped-$(CONFIG_INFINIBAND_QIB) += qlogic/sd7220.fw
-fw-shipped-$(CONFIG_SMCTR) += tr_smctr.bin
 fw-shipped-$(CONFIG_SND_KORG1212) += korg/k1212.dsp
 fw-shipped-$(CONFIG_SND_MAESTRO3) += ess/maestro3_assp_kernel.fw \
 				     ess/maestro3_assp_minisrc.fw
diff --git a/firmware/WHENCE b/firmware/WHENCE
index 182ecb6..8388f02 100644
--- a/firmware/WHENCE
+++ b/firmware/WHENCE
@@ -89,18 +89,6 @@ Licence: Allegedly GPLv2+, but no source visible. Marked:
   Copyright (C) 2001 Qlogic Corporation (www.qlogic.com)
 
 --------------------------------------------------------------------------
-Driver: smctr -- SMC ISA/MCA Token Ring adapter
-
-File: tr_smctr.bin
-Info: MCT.BIN v6.3C1 03/01/95
-
-Original licence info:
-
- * This firmware is licensed to you strictly for use in conjunction
- * with the use of SMC TokenRing adapters. There is no waranty
- * expressed or implied about its fitness for any purpose.
-
---------------------------------------------------------------------------
 
 Driver: kaweth -- USB KLSI KL5USB101-based Ethernet device
 
@@ -567,32 +555,6 @@ Found in hex form in kernel source.
 
 --------------------------------------------------------------------------
 
-Driver: 3C359 - 3Com 3C359 Token Link Velocity XL adapter
-
-File: 3com/3C359.bin
-
-Licence:
-/*
- * The firmware this driver downloads into the tokenring card is a
- * separate program and is not GPL'd source code, even though the Linux
- * side driver and the routine that loads this data into the card are.
- *
- * This firmware is licensed to you strictly for use in conjunction
- * with the use of 3Com 3C359 TokenRing adapters. There is no
- * waranty expressed or implied about its fitness for any purpose.
- */
-/* 3c359_microcode.mac: 3Com 3C359 Tokenring microcode.
- *
- * Notes:
- *  - Loaded from xl_init upon adapter initialization.
- *
- * Available from 3Com as part of their standard 3C359 driver.
- */
-
-Found in hex form in kernel source.
-
---------------------------------------------------------------------------
-
 Driver: PCMCIA_PCNET - NE2000 compatible PCMCIA adapter
 
 File: cis/LA-PCM.cis
diff --git a/firmware/tr_smctr.bin.ihex b/firmware/tr_smctr.bin.ihex
deleted file mode 100644
index 6797451..0000000
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 3c9b616..b738f2d 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -186,7 +186,6 @@ header-y += if_pppox.h
 header-y += if_slip.h
 header-y += if_strip.h
 header-y += if_team.h
-header-y += if_tr.h
 header-y += if_tun.h
 header-y += if_tunnel.h
 header-y += if_vlan.h
diff --git a/include/linux/ibmtr.h b/include/linux/ibmtr.h
deleted file mode 100644
index 06695b7..0000000
diff --git a/include/linux/if_tr.h b/include/linux/if_tr.h
deleted file mode 100644
index fc23aeb..0000000
diff --git a/include/linux/trdevice.h b/include/linux/trdevice.h
deleted file mode 100644
index bfc84a7..0000000
diff --git a/net/802/Makefile b/net/802/Makefile
index 7893d67..a30d6e3 100644
--- a/net/802/Makefile
+++ b/net/802/Makefile
@@ -4,7 +4,6 @@
 
 # Check the p8022 selections against net/core/Makefile.
 obj-$(CONFIG_LLC)	+= p8022.o psnap.o
-obj-$(CONFIG_TR)	+= p8022.o psnap.o tr.o
 obj-$(CONFIG_NET_FC)	+=                 fc.o
 obj-$(CONFIG_FDDI)	+=                 fddi.o
 obj-$(CONFIG_HIPPI)	+=                 hippi.o
diff --git a/net/802/tr.c b/net/802/tr.c
deleted file mode 100644
index 175243b..0000000
-- 
1.7.9.1
