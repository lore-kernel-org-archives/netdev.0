From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: Can we remove pci_find_device() yet?
Date: Mon, 11 Jan 2010 20:46:50 +0100
Message-ID: <4B4B802A.2010709@imap.cc>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au> <20100108044646.GC6611@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:49362 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753259Ab0AKTw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 14:52:57 -0500
In-Reply-To: <20100108044646.GC6611@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 08.01.2010 05:46 schrieb Greg KH:
> On Fri, Jan 08, 2010 at 11:22:36AM +1100, Stephen Rothwell wrote:
>>
>> This interface has been deprecated since November 2006, so can somet=
hing
>> be done about the last users (I think only some ISDN drivers)?

That would be the HiSax I4L drivers.

> Ick, the "new" isdn drivers are still not merged that replace those
> older ones?  I thought that happened a while ago.

mISDN, which is the designated successor to HiSax, has indeed been
merged in 2008.

Trouble is, mISDN's userspace interface is completely different from I4=
L.
Removing HiSax would therefore break userspace compatibility for curren=
t
users of HiSax supported devices. In order to switch to mISDN they'll
have to replace all of their ISDN4Linux applications with equivalent
mISDN ones, and I'm not even sure there is a replacement for everything=
=2E

Just an idea - as a stopgap measure, couldn't pci_find_device() be made
a private function of the HiSax drivers? That way, the remainder of the
kernel won't be polluted by it anymore, and the PCI_LEGACY config optio=
n
can be dropped. Something like this quick and dirty hack:

diff --git a/drivers/isdn/hisax/Kconfig b/drivers/isdn/hisax/Kconfig
index 3464ebc..452fde9 100644
--- a/drivers/isdn/hisax/Kconfig
+++ b/drivers/isdn/hisax/Kconfig
@@ -109,7 +109,7 @@ config HISAX_16_3
=20
 config HISAX_TELESPCI
 	bool "Teles PCI"
-	depends on PCI && PCI_LEGACY && (BROKEN || !(SPARC || PPC || PARISC |=
| M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
+	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIP=
S && !CPU_LITTLE_ENDIAN) || FRV))
 	help
 	  This enables HiSax support for the Teles PCI.
 	  See <file:Documentation/isdn/README.HiSax> on how to configure it.
@@ -237,7 +237,7 @@ config HISAX_MIC
=20
 config HISAX_NETJET
 	bool "NETjet card"
-	depends on PCI && PCI_LEGACY && (BROKEN || !(SPARC || PPC || PARISC |=
| M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
+	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIP=
S && !CPU_LITTLE_ENDIAN) || FRV))
 	help
 	  This enables HiSax support for the NetJet from Traverse
 	  Technologies.
@@ -248,7 +248,7 @@ config HISAX_NETJET
=20
 config HISAX_NETJET_U
 	bool "NETspider U card"
-	depends on PCI && PCI_LEGACY && (BROKEN || !(SPARC || PPC || PARISC |=
| M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
+	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIP=
S && !CPU_LITTLE_ENDIAN) || FRV))
 	help
 	  This enables HiSax support for the Netspider U interface ISDN card
 	  from Traverse Technologies.
@@ -287,7 +287,7 @@ config HISAX_HSTSAPHIR
=20
 config HISAX_BKM_A4T
 	bool "Telekom A4T card"
-	depends on PCI && PCI_LEGACY
+	depends on PCI
 	help
 	  This enables HiSax support for the Telekom A4T card.
=20
@@ -297,7 +297,7 @@ config HISAX_BKM_A4T
=20
 config HISAX_SCT_QUADRO
 	bool "Scitel Quadro card"
-	depends on PCI && PCI_LEGACY
+	depends on PCI
 	help
 	  This enables HiSax support for the Scitel Quadro card.
=20
@@ -316,7 +316,7 @@ config HISAX_GAZEL
=20
 config HISAX_HFC_PCI
 	bool "HFC PCI-Bus cards"
-	depends on PCI && PCI_LEGACY && (BROKEN || !(SPARC || PPC || PARISC |=
| M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
+	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIP=
S && !CPU_LITTLE_ENDIAN) || FRV))
 	help
 	  This enables HiSax support for the HFC-S PCI 2BDS0 based cards.
=20
@@ -325,7 +325,7 @@ config HISAX_HFC_PCI
=20
 config HISAX_W6692
 	bool "Winbond W6692 based cards"
-	depends on PCI && PCI_LEGACY
+	depends on PCI
 	help
 	  This enables HiSax support for Winbond W6692 based PCI ISDN cards.
=20
@@ -341,7 +341,7 @@ config HISAX_HFC_SX
=20
 config HISAX_ENTERNOW_PCI
 	bool "Formula-n enter:now PCI card"
-	depends on HISAX_NETJET && PCI && PCI_LEGACY && (BROKEN || !(SPARC ||=
 PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
+	depends on HISAX_NETJET && PCI && (BROKEN || !(SPARC || PPC || PARISC=
 || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
 	help
 	  This enables HiSax support for the Formula-n enter:now PCI
 	  ISDN card.
@@ -412,7 +412,7 @@ config HISAX_HFC4S8S
=20
 config HISAX_FRITZ_PCIPNP
 	tristate "AVM Fritz!Card PCI/PCIv2/PnP support (EXPERIMENTAL)"
-	depends on PCI && PCI_LEGACY && EXPERIMENTAL
+	depends on PCI && EXPERIMENTAL
 	help
 	  This enables the driver for the AVM Fritz!Card PCI,
 	  Fritz!Card PCI v2 and Fritz!Card PnP.
diff --git a/drivers/isdn/hisax/avm_pci.c b/drivers/isdn/hisax/avm_pci.=
c
index 7cabc5a..f8d21a0 100644
--- a/drivers/isdn/hisax/avm_pci.c
+++ b/drivers/isdn/hisax/avm_pci.c
@@ -822,15 +822,6 @@ static int __devinit avm_pnp_setup(struct IsdnCard=
State *cs)
=20
 #endif /* __ISAPNP__ */
=20
-#ifndef CONFIG_PCI_LEGACY
-
-static int __devinit avm_pci_setup(struct IsdnCardState *cs)
-{
-	return(1);	/* no-op: success */
-}
-
-#else
-
 static struct pci_dev *dev_avm __devinitdata =3D NULL;
=20
 static int __devinit avm_pci_setup(struct IsdnCardState *cs)
@@ -864,8 +855,6 @@ static int __devinit avm_pci_setup(struct IsdnCardS=
tate *cs)
 	return (1);
 }
=20
-#endif /* CONFIG_PCI_LEGACY */
-
 int __devinit
 setup_avm_pcipnp(struct IsdnCard *card)
 {
diff --git a/drivers/isdn/hisax/diva.c b/drivers/isdn/hisax/diva.c
index 0b0c2e5..830ad46 100644
--- a/drivers/isdn/hisax/diva.c
+++ b/drivers/isdn/hisax/diva.c
@@ -1148,7 +1148,6 @@ static int __devinit setup_diva_isapnp(struct Isd=
nCard *card)
=20
 #endif	/* ISAPNP */
=20
-#ifdef CONFIG_PCI_LEGACY
 static struct pci_dev *dev_diva __devinitdata =3D NULL;
 static struct pci_dev *dev_diva_u __devinitdata =3D NULL;
 static struct pci_dev *dev_diva201 __devinitdata =3D NULL;
@@ -1229,15 +1228,6 @@ static int __devinit setup_diva_pci(struct IsdnC=
ard *card)
 	return (1);		/* card found */
 }
=20
-#else	/* if !CONFIG_PCI_LEGACY */
-
-static int __devinit setup_diva_pci(struct IsdnCard *card)
-{
-	return (-1);	/* card not found; continue search */
-}
-
-#endif	/* CONFIG_PCI_LEGACY */
-
 int __devinit
 setup_diva(struct IsdnCard *card)
 {
diff --git a/drivers/isdn/hisax/elsa.c b/drivers/isdn/hisax/elsa.c
index aa29d1c..28f6620 100644
--- a/drivers/isdn/hisax/elsa.c
+++ b/drivers/isdn/hisax/elsa.c
@@ -1025,7 +1025,6 @@ setup_elsa_pcmcia(struct IsdnCard *card)
 	       cs->irq);
 }
=20
-#ifdef CONFIG_PCI_LEGACY
 static 	struct pci_dev *dev_qs1000 __devinitdata =3D NULL;
 static 	struct pci_dev *dev_qs3000 __devinitdata =3D NULL;
=20
@@ -1086,15 +1085,6 @@ setup_elsa_pci(struct IsdnCard *card)
 	return (1);
 }
=20
-#else
-
-static int __devinit
-setup_elsa_pci(struct IsdnCard *card)
-{
-	return (1);
-}
-#endif /* CONFIG_PCI_LEGACY */
-
 static int __devinit
 setup_elsa_common(struct IsdnCard *card)
 {
diff --git a/drivers/isdn/hisax/gazel.c b/drivers/isdn/hisax/gazel.c
index 0ea3b46..c25f455 100644
--- a/drivers/isdn/hisax/gazel.c
+++ b/drivers/isdn/hisax/gazel.c
@@ -531,7 +531,6 @@ setup_gazelisa(struct IsdnCard *card, struct IsdnCa=
rdState *cs)
 	return (0);
 }
=20
-#ifdef CONFIG_PCI_LEGACY
 static struct pci_dev *dev_tel __devinitdata =3D NULL;
=20
 static int __devinit
@@ -620,7 +619,6 @@ setup_gazelpci(struct IsdnCardState *cs)
=20
 	return (0);
 }
-#endif /* CONFIG_PCI_LEGACY */
=20
 int __devinit
 setup_gazel(struct IsdnCard *card)
@@ -639,14 +637,8 @@ setup_gazel(struct IsdnCard *card)
 		if (setup_gazelisa(card, cs))
 			return (0);
 	} else {
-
-#ifdef CONFIG_PCI_LEGACY
 		if (setup_gazelpci(cs))
 			return (0);
-#else
-		printk(KERN_WARNING "Gazel: Card PCI requested and NO_PCI_BIOS, unab=
le to config\n");
-		return (0);
-#endif				/* CONFIG_PCI */
 	}
=20
 	if (reserve_regions(card, cs)) {
diff --git a/drivers/isdn/hisax/hisax.h b/drivers/isdn/hisax/hisax.h
index 0685c19..63c8359 100644
--- a/drivers/isdn/hisax/hisax.h
+++ b/drivers/isdn/hisax/hisax.h
@@ -1323,3 +1323,22 @@ void release_tei(struct IsdnCardState *cs);
 char *HiSax_getrev(const char *revision);
 int TeiNew(void);
 void TeiFree(void);
+
+#ifdef CONFIG_PCI
+
+#include <linux/pci.h>
+
+/* FIXME */
+static inline struct pci_dev *pci_find_device(unsigned int vendor,
+					      unsigned int device,
+					      struct pci_dev *from)
+{
+	struct pci_dev *pdev;
+
+	pci_dev_get(from);
+	pdev =3D pci_get_subsys(vendor, device, PCI_ANY_ID, PCI_ANY_ID, from)=
;
+	pci_dev_put(pdev);
+	return pdev;
+}
+
+#endif
diff --git a/drivers/isdn/hisax/niccy.c b/drivers/isdn/hisax/niccy.c
index ef00633..13922f6 100644
--- a/drivers/isdn/hisax/niccy.c
+++ b/drivers/isdn/hisax/niccy.c
@@ -297,7 +297,6 @@ int __devinit setup_niccy(struct IsdnCard *card)
 			return 0;
 		}
 	} else {
-#ifdef CONFIG_PCI_LEGACY
 		static struct pci_dev *niccy_dev __devinitdata;
=20
 		u_int pci_ioaddr;
@@ -350,11 +349,6 @@ int __devinit setup_niccy(struct IsdnCard *card)
 			release_region(cs->hw.niccy.isac, 4);
 			return 0;
 		}
-#else
-		printk(KERN_WARNING "Niccy: io0 0 and NO_PCI_BIOS\n");
-		printk(KERN_WARNING "Niccy: unable to config NICCY PCI\n");
-		return 0;
-#endif				/* CONFIG_PCI_LEGACY */
 	}
 	printk(KERN_INFO "HiSax: NICCY %s config irq:%d data:0x%X ale:0x%X\n"=
,
 		(cs->subtyp =3D=3D 1) ? "PnP" : "PCI",
diff --git a/drivers/isdn/hisax/sedlbauer.c b/drivers/isdn/hisax/sedlba=
uer.c
index 5569a52..5cdcb0d 100644
--- a/drivers/isdn/hisax/sedlbauer.c
+++ b/drivers/isdn/hisax/sedlbauer.c
@@ -598,7 +598,6 @@ setup_sedlbauer_isapnp(struct IsdnCard *card, int *=
bytecnt)
 }
 #endif /* __ISAPNP__ */
=20
-#ifdef CONFIG_PCI_LEGACY
 static struct pci_dev *dev_sedl __devinitdata =3D NULL;
=20
 static int __devinit
@@ -665,16 +664,6 @@ setup_sedlbauer_pci(struct IsdnCard *card)
 	return (1);
 }
=20
-#else
-
-static int __devinit
-setup_sedlbauer_pci(struct IsdnCard *card)
-{
-	return (1);
-}
-
-#endif /* CONFIG_PCI_LEGACY */
-
 int __devinit
 setup_sedlbauer(struct IsdnCard *card)
 {
diff --git a/drivers/pci/Kconfig b/drivers/pci/Kconfig
index b1ecefa..7858a11 100644
--- a/drivers/pci/Kconfig
+++ b/drivers/pci/Kconfig
@@ -21,17 +21,6 @@ config PCI_MSI
=20
 	   If you don't know what to do here, say N.
=20
-config PCI_LEGACY
-	bool "Enable deprecated pci_find_* API"
-	depends on PCI
-	default y
-	help
-	  Say Y here if you want to include support for the deprecated
-	  pci_find_device() API.  Most drivers have been converted over
-	  to using the proper hotplug APIs, so this option serves to
-	  include/exclude only a few drivers that are still using this
-	  API.
-
 config PCI_DEBUG
 	bool "PCI Debugging"
 	depends on PCI && DEBUG_KERNEL
diff --git a/drivers/pci/Makefile b/drivers/pci/Makefile
index 4df48d5..f635608 100644
--- a/drivers/pci/Makefile
+++ b/drivers/pci/Makefile
@@ -8,9 +8,6 @@ obj-y		+=3D access.o bus.o probe.o remove.o pci.o quirk=
s.o \
 obj-$(CONFIG_PROC_FS) +=3D proc.o
 obj-$(CONFIG_SYSFS) +=3D slot.o
=20
-obj-$(CONFIG_PCI_LEGACY) +=3D legacy.o
-CFLAGS_legacy.o +=3D -Wno-deprecated-declarations
-
 # Build PCI Express stuff if needed
 obj-$(CONFIG_PCIEPORTBUS) +=3D pcie/
=20
diff --git a/drivers/pci/legacy.c b/drivers/pci/legacy.c
deleted file mode 100644
index 871f65c..0000000
--- a/drivers/pci/legacy.c
+++ /dev/null
@@ -1,34 +0,0 @@
-#include <linux/init.h>
-#include <linux/pci.h>
-#include <linux/module.h>
-#include <linux/interrupt.h>
-#include "pci.h"
-
-/**
- * pci_find_device - begin or continue searching for a PCI device by v=
endor/device id
- * @vendor: PCI vendor id to match, or %PCI_ANY_ID to match all vendor=
 ids
- * @device: PCI device id to match, or %PCI_ANY_ID to match all device=
 ids
- * @from: Previous PCI device found in search, or %NULL for new search=
=2E
- *
- * Iterates through the list of known PCI devices.  If a PCI device is=
 found
- * with a matching @vendor and @device, a pointer to its device struct=
ure is
- * returned.  Otherwise, %NULL is returned.
- * A new search is initiated by passing %NULL as the @from argument.
- * Otherwise if @from is not %NULL, searches continue from next device
- * on the global list.
- *
- * NOTE: Do not use this function any more; use pci_get_device() inste=
ad, as
- * the PCI device returned by this function can disappear at any momen=
t in
- * time.
- */
-struct pci_dev *pci_find_device(unsigned int vendor, unsigned int devi=
ce,
-				struct pci_dev *from)
-{
-	struct pci_dev *pdev;
-
-	pci_dev_get(from);
-	pdev =3D pci_get_subsys(vendor, device, PCI_ANY_ID, PCI_ANY_ID, from)=
;
-	pci_dev_put(pdev);
-	return pdev;
-}
-EXPORT_SYMBOL(pci_find_device);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 174e539..dd9682c 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -615,12 +615,6 @@ extern void pci_sort_breadthfirst(void);
=20
 /* Generic PCI functions exported to card drivers */
=20
-#ifdef CONFIG_PCI_LEGACY
-struct pci_dev __deprecated *pci_find_device(unsigned int vendor,
-					     unsigned int device,
-					     struct pci_dev *from);
-#endif /* CONFIG_PCI_LEGACY */
-
 enum pci_lost_interrupt_reason {
 	PCI_LOST_IRQ_NO_INFORMATION =3D 0,
 	PCI_LOST_IRQ_DISABLE_MSI,
@@ -973,13 +967,6 @@ static inline int pci_proc_domain(struct pci_bus *=
bus)
 _PCI_NOP_ALL(read, *)
 _PCI_NOP_ALL(write,)
=20
-static inline struct pci_dev *pci_find_device(unsigned int vendor,
-					      unsigned int device,
-					      struct pci_dev *from)
-{
-	return NULL;
-}
-
 static inline struct pci_dev *pci_get_device(unsigned int vendor,
 					     unsigned int device,
 					     struct pci_dev *from)

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
