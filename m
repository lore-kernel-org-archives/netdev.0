From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH/v2] pci: push deprecated pci_find_device() function to last user
Date: Mon, 18 Jan 2010 17:24:10 +0100 (CET)
Message-ID: <20100118162410.4562840108@xenon.ts.pxnet.com>
References: <20100113142328.5DE2F40107@xenon.ts.pxnet.com>
	<20100113.203338.52448956.davem@davemloft.net>
	<20100114044331.GA29008@suse.de>
	<20100114.001204.203918209.davem@davemloft.net>
	<20100114082823.63379b3d@jbarnes-piketon>
Cc: David Miller <davem@davemloft.net>, Greg KH <gregkh@suse.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:40285 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624Ab0ARQbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2010 11:31:44 -0500
In-Reply-To: <20100114082823.63379b3d@jbarnes-piketon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ISDN4Linux HiSax driver family contains the last remaining users
of the deprecated pci_find_device() function. This patch creates a
private copy of that function in HiSax, and removes the now unused
global function together with its controlling configuration option,
CONFIG_PCI_LEGACY.

Impact: code reorganization, no functional change
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
Revised to fix !CONFIG_PCI case for combined ISAPNP/PCI drivers.

 drivers/isdn/hisax/Kconfig        |   18 +++++++++---------
 drivers/isdn/hisax/avm_pci.c      |    6 +++---
 drivers/isdn/hisax/bkm_a4t.c      |    2 +-
 drivers/isdn/hisax/bkm_a8.c       |    2 +-
 drivers/isdn/hisax/diva.c         |   14 +++++++-------
 drivers/isdn/hisax/elsa.c         |    8 ++++----
 drivers/isdn/hisax/enternow_pci.c |    2 +-
 drivers/isdn/hisax/gazel.c        |    8 ++++----
 drivers/isdn/hisax/hfc_pci.c      |    2 +-
 drivers/isdn/hisax/hisax.h        |   23 +++++++++++++++++++++++
 drivers/isdn/hisax/niccy.c        |    6 +++---
 drivers/isdn/hisax/nj_s.c         |    2 +-
 drivers/isdn/hisax/nj_u.c         |    2 +-
 drivers/isdn/hisax/sedlbauer.c    |    6 +++---
 drivers/isdn/hisax/telespci.c     |    2 +-
 drivers/isdn/hisax/w6692.c        |    2 +-
 drivers/pci/Kconfig               |   11 -----------
 drivers/pci/Makefile              |    3 ---
 drivers/pci/legacy.c              |   34 ----------------------------------
 include/linux/pci.h               |   13 -------------
 20 files changed, 64 insertions(+), 102 deletions(-)
 delete mode 100644 drivers/pci/legacy.c

diff --git a/drivers/isdn/hisax/Kconfig b/drivers/isdn/hisax/Kconfig
index 3464ebc..452fde9 100644
--- a/drivers/isdn/hisax/Kconfig
+++ b/drivers/isdn/hisax/Kconfig
@@ -109,7 +109,7 @@ config HISAX_16_3
 
 config HISAX_TELESPCI
 	bool "Teles PCI"
-	depends on PCI && PCI_LEGACY && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
+	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
 	help
 	  This enables HiSax support for the Teles PCI.
 	  See <file:Documentation/isdn/README.HiSax> on how to configure it.
@@ -237,7 +237,7 @@ config HISAX_MIC
 
 config HISAX_NETJET
 	bool "NETjet card"
-	depends on PCI && PCI_LEGACY && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
+	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
 	help
 	  This enables HiSax support for the NetJet from Traverse
 	  Technologies.
@@ -248,7 +248,7 @@ config HISAX_NETJET
 
 config HISAX_NETJET_U
 	bool "NETspider U card"
-	depends on PCI && PCI_LEGACY && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
+	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
 	help
 	  This enables HiSax support for the Netspider U interface ISDN card
 	  from Traverse Technologies.
@@ -287,7 +287,7 @@ config HISAX_HSTSAPHIR
 
 config HISAX_BKM_A4T
 	bool "Telekom A4T card"
-	depends on PCI && PCI_LEGACY
+	depends on PCI
 	help
 	  This enables HiSax support for the Telekom A4T card.
 
@@ -297,7 +297,7 @@ config HISAX_BKM_A4T
 
 config HISAX_SCT_QUADRO
 	bool "Scitel Quadro card"
-	depends on PCI && PCI_LEGACY
+	depends on PCI
 	help
 	  This enables HiSax support for the Scitel Quadro card.
 
@@ -316,7 +316,7 @@ config HISAX_GAZEL
 
 config HISAX_HFC_PCI
 	bool "HFC PCI-Bus cards"
-	depends on PCI && PCI_LEGACY && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
+	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
 	help
 	  This enables HiSax support for the HFC-S PCI 2BDS0 based cards.
 
@@ -325,7 +325,7 @@ config HISAX_HFC_PCI
 
 config HISAX_W6692
 	bool "Winbond W6692 based cards"
-	depends on PCI && PCI_LEGACY
+	depends on PCI
 	help
 	  This enables HiSax support for Winbond W6692 based PCI ISDN cards.
 
@@ -341,7 +341,7 @@ config HISAX_HFC_SX
 
 config HISAX_ENTERNOW_PCI
 	bool "Formula-n enter:now PCI card"
-	depends on HISAX_NETJET && PCI && PCI_LEGACY && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
+	depends on HISAX_NETJET && PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV))
 	help
 	  This enables HiSax support for the Formula-n enter:now PCI
 	  ISDN card.
@@ -412,7 +412,7 @@ config HISAX_HFC4S8S
 
 config HISAX_FRITZ_PCIPNP
 	tristate "AVM Fritz!Card PCI/PCIv2/PnP support (EXPERIMENTAL)"
-	depends on PCI && PCI_LEGACY && EXPERIMENTAL
+	depends on PCI && EXPERIMENTAL
 	help
 	  This enables the driver for the AVM Fritz!Card PCI,
 	  Fritz!Card PCI v2 and Fritz!Card PnP.
diff --git a/drivers/isdn/hisax/avm_pci.c b/drivers/isdn/hisax/avm_pci.c
index 7cabc5a..14295a1 100644
--- a/drivers/isdn/hisax/avm_pci.c
+++ b/drivers/isdn/hisax/avm_pci.c
@@ -822,7 +822,7 @@ static int __devinit avm_pnp_setup(struct IsdnCardState *cs)
 
 #endif /* __ISAPNP__ */
 
-#ifndef CONFIG_PCI_LEGACY
+#ifndef CONFIG_PCI
 
 static int __devinit avm_pci_setup(struct IsdnCardState *cs)
 {
@@ -835,7 +835,7 @@ static struct pci_dev *dev_avm __devinitdata = NULL;
 
 static int __devinit avm_pci_setup(struct IsdnCardState *cs)
 {
-	if ((dev_avm = pci_find_device(PCI_VENDOR_ID_AVM,
+	if ((dev_avm = hisax_find_pci_device(PCI_VENDOR_ID_AVM,
 		PCI_DEVICE_ID_AVM_A1, dev_avm))) {
 
 		if (pci_enable_device(dev_avm))
@@ -864,7 +864,7 @@ static int __devinit avm_pci_setup(struct IsdnCardState *cs)
 	return (1);
 }
 
-#endif /* CONFIG_PCI_LEGACY */
+#endif /* CONFIG_PCI */
 
 int __devinit
 setup_avm_pcipnp(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/bkm_a4t.c b/drivers/isdn/hisax/bkm_a4t.c
index 9ca2ee5..9f2009c 100644
--- a/drivers/isdn/hisax/bkm_a4t.c
+++ b/drivers/isdn/hisax/bkm_a4t.c
@@ -340,7 +340,7 @@ setup_bkm_a4t(struct IsdnCard *card)
 	} else
 		return (0);
 
-	while ((dev_a4t = pci_find_device(PCI_VENDOR_ID_ZORAN,
+	while ((dev_a4t = hisax_find_pci_device(PCI_VENDOR_ID_ZORAN,
 		PCI_DEVICE_ID_ZORAN_36120, dev_a4t))) {
 		ret = a4t_pci_probe(dev_a4t, cs, &found, &pci_memaddr);
 		if (!ret)
diff --git a/drivers/isdn/hisax/bkm_a8.c b/drivers/isdn/hisax/bkm_a8.c
index e1ff471..e775706 100644
--- a/drivers/isdn/hisax/bkm_a8.c
+++ b/drivers/isdn/hisax/bkm_a8.c
@@ -301,7 +301,7 @@ setup_sct_quadro(struct IsdnCard *card)
 		(sub_vendor_id != PCI_VENDOR_ID_BERKOM)))
 		return (0);
 	if (cs->subtyp == SCT_1) {
-		while ((dev_a8 = pci_find_device(PCI_VENDOR_ID_PLX,
+		while ((dev_a8 = hisax_find_pci_device(PCI_VENDOR_ID_PLX,
 			PCI_DEVICE_ID_PLX_9050, dev_a8))) {
 			
 			sub_vendor_id = dev_a8->subsystem_vendor;
diff --git a/drivers/isdn/hisax/diva.c b/drivers/isdn/hisax/diva.c
index 0b0c2e5..780da9b 100644
--- a/drivers/isdn/hisax/diva.c
+++ b/drivers/isdn/hisax/diva.c
@@ -1148,7 +1148,7 @@ static int __devinit setup_diva_isapnp(struct IsdnCard *card)
 
 #endif	/* ISAPNP */
 
-#ifdef CONFIG_PCI_LEGACY
+#ifdef CONFIG_PCI
 static struct pci_dev *dev_diva __devinitdata = NULL;
 static struct pci_dev *dev_diva_u __devinitdata = NULL;
 static struct pci_dev *dev_diva201 __devinitdata = NULL;
@@ -1159,21 +1159,21 @@ static int __devinit setup_diva_pci(struct IsdnCard *card)
 	struct IsdnCardState *cs = card->cs;
 
 	cs->subtyp = 0;
-	if ((dev_diva = pci_find_device(PCI_VENDOR_ID_EICON,
+	if ((dev_diva = hisax_find_pci_device(PCI_VENDOR_ID_EICON,
 		PCI_DEVICE_ID_EICON_DIVA20, dev_diva))) {
 		if (pci_enable_device(dev_diva))
 			return(0);
 		cs->subtyp = DIVA_PCI;
 		cs->irq = dev_diva->irq;
 		cs->hw.diva.cfg_reg = pci_resource_start(dev_diva, 2);
-	} else if ((dev_diva_u = pci_find_device(PCI_VENDOR_ID_EICON,
+	} else if ((dev_diva_u = hisax_find_pci_device(PCI_VENDOR_ID_EICON,
 		PCI_DEVICE_ID_EICON_DIVA20_U, dev_diva_u))) {
 		if (pci_enable_device(dev_diva_u))
 			return(0);
 		cs->subtyp = DIVA_PCI;
 		cs->irq = dev_diva_u->irq;
 		cs->hw.diva.cfg_reg = pci_resource_start(dev_diva_u, 2);
-	} else if ((dev_diva201 = pci_find_device(PCI_VENDOR_ID_EICON,
+	} else if ((dev_diva201 = hisax_find_pci_device(PCI_VENDOR_ID_EICON,
 		PCI_DEVICE_ID_EICON_DIVA201, dev_diva201))) {
 		if (pci_enable_device(dev_diva201))
 			return(0);
@@ -1183,7 +1183,7 @@ static int __devinit setup_diva_pci(struct IsdnCard *card)
 			(ulong) ioremap(pci_resource_start(dev_diva201, 0), 4096);
 		cs->hw.diva.cfg_reg =
 			(ulong) ioremap(pci_resource_start(dev_diva201, 1), 4096);
-	} else if ((dev_diva202 = pci_find_device(PCI_VENDOR_ID_EICON,
+	} else if ((dev_diva202 = hisax_find_pci_device(PCI_VENDOR_ID_EICON,
 		PCI_DEVICE_ID_EICON_DIVA202, dev_diva202))) {
 		if (pci_enable_device(dev_diva202))
 			return(0);
@@ -1229,14 +1229,14 @@ static int __devinit setup_diva_pci(struct IsdnCard *card)
 	return (1);		/* card found */
 }
 
-#else	/* if !CONFIG_PCI_LEGACY */
+#else	/* if !CONFIG_PCI */
 
 static int __devinit setup_diva_pci(struct IsdnCard *card)
 {
 	return (-1);	/* card not found; continue search */
 }
 
-#endif	/* CONFIG_PCI_LEGACY */
+#endif	/* CONFIG_PCI */
 
 int __devinit
 setup_diva(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/elsa.c b/drivers/isdn/hisax/elsa.c
index aa29d1c..23c41fc 100644
--- a/drivers/isdn/hisax/elsa.c
+++ b/drivers/isdn/hisax/elsa.c
@@ -1025,7 +1025,7 @@ setup_elsa_pcmcia(struct IsdnCard *card)
 	       cs->irq);
 }
 
-#ifdef CONFIG_PCI_LEGACY
+#ifdef CONFIG_PCI
 static 	struct pci_dev *dev_qs1000 __devinitdata = NULL;
 static 	struct pci_dev *dev_qs3000 __devinitdata = NULL;
 
@@ -1035,7 +1035,7 @@ setup_elsa_pci(struct IsdnCard *card)
 	struct IsdnCardState *cs = card->cs;
 
 	cs->subtyp = 0;
-	if ((dev_qs1000 = pci_find_device(PCI_VENDOR_ID_ELSA,
+	if ((dev_qs1000 = hisax_find_pci_device(PCI_VENDOR_ID_ELSA,
 		PCI_DEVICE_ID_ELSA_MICROLINK, dev_qs1000))) {
 		if (pci_enable_device(dev_qs1000))
 			return(0);
@@ -1043,7 +1043,7 @@ setup_elsa_pci(struct IsdnCard *card)
 		cs->irq = dev_qs1000->irq;
 		cs->hw.elsa.cfg = pci_resource_start(dev_qs1000, 1);
 		cs->hw.elsa.base = pci_resource_start(dev_qs1000, 3);
-	} else if ((dev_qs3000 = pci_find_device(PCI_VENDOR_ID_ELSA,
+	} else if ((dev_qs3000 = hisax_find_pci_device(PCI_VENDOR_ID_ELSA,
 		PCI_DEVICE_ID_ELSA_QS3000, dev_qs3000))) {
 		if (pci_enable_device(dev_qs3000))
 			return(0);
@@ -1093,7 +1093,7 @@ setup_elsa_pci(struct IsdnCard *card)
 {
 	return (1);
 }
-#endif /* CONFIG_PCI_LEGACY */
+#endif /* CONFIG_PCI */
 
 static int __devinit
 setup_elsa_common(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/enternow_pci.c b/drivers/isdn/hisax/enternow_pci.c
index 39f421e..26264ab 100644
--- a/drivers/isdn/hisax/enternow_pci.c
+++ b/drivers/isdn/hisax/enternow_pci.c
@@ -406,7 +406,7 @@ setup_enternow_pci(struct IsdnCard *card)
 
 	for ( ;; )
 	{
-		if ((dev_netjet = pci_find_device(PCI_VENDOR_ID_TIGERJET,
+		if ((dev_netjet = hisax_find_pci_device(PCI_VENDOR_ID_TIGERJET,
 			PCI_DEVICE_ID_TIGERJET_300,  dev_netjet))) {
 			ret = en_pci_probe(dev_netjet, cs);
 			if (!ret)
diff --git a/drivers/isdn/hisax/gazel.c b/drivers/isdn/hisax/gazel.c
index 0ea3b46..353982f 100644
--- a/drivers/isdn/hisax/gazel.c
+++ b/drivers/isdn/hisax/gazel.c
@@ -531,7 +531,7 @@ setup_gazelisa(struct IsdnCard *card, struct IsdnCardState *cs)
 	return (0);
 }
 
-#ifdef CONFIG_PCI_LEGACY
+#ifdef CONFIG_PCI
 static struct pci_dev *dev_tel __devinitdata = NULL;
 
 static int __devinit
@@ -546,7 +546,7 @@ setup_gazelpci(struct IsdnCardState *cs)
 	found = 0;
 	seekcard = PCI_DEVICE_ID_PLX_R685;
 	for (nbseek = 0; nbseek < 4; nbseek++) {
-		if ((dev_tel = pci_find_device(PCI_VENDOR_ID_PLX,
+		if ((dev_tel = hisax_find_pci_device(PCI_VENDOR_ID_PLX,
 					seekcard, dev_tel))) {
 			if (pci_enable_device(dev_tel))
 				return 1;
@@ -620,7 +620,7 @@ setup_gazelpci(struct IsdnCardState *cs)
 
 	return (0);
 }
-#endif /* CONFIG_PCI_LEGACY */
+#endif /* CONFIG_PCI */
 
 int __devinit
 setup_gazel(struct IsdnCard *card)
@@ -640,7 +640,7 @@ setup_gazel(struct IsdnCard *card)
 			return (0);
 	} else {
 
-#ifdef CONFIG_PCI_LEGACY
+#ifdef CONFIG_PCI
 		if (setup_gazelpci(cs))
 			return (0);
 #else
diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
index 1091473..917cc84 100644
--- a/drivers/isdn/hisax/hfc_pci.c
+++ b/drivers/isdn/hisax/hfc_pci.c
@@ -1658,7 +1658,7 @@ setup_hfcpci(struct IsdnCard *card)
 
 	i = 0;
 	while (id_list[i].vendor_id) {
-		tmp_hfcpci = pci_find_device(id_list[i].vendor_id,
+		tmp_hfcpci = hisax_find_pci_device(id_list[i].vendor_id,
 					     id_list[i].device_id,
 					     dev_hfcpci);
 		i++;
diff --git a/drivers/isdn/hisax/hisax.h b/drivers/isdn/hisax/hisax.h
index 0685c19..832a878 100644
--- a/drivers/isdn/hisax/hisax.h
+++ b/drivers/isdn/hisax/hisax.h
@@ -1323,3 +1323,26 @@ void release_tei(struct IsdnCardState *cs);
 char *HiSax_getrev(const char *revision);
 int TeiNew(void);
 void TeiFree(void);
+
+#ifdef CONFIG_PCI
+
+#include <linux/pci.h>
+
+/* adaptation wrapper for old usage
+ * WARNING! This is unfit for use in a PCI hotplug environment,
+ * as the returned PCI device can disappear at any moment in time.
+ * Callers should be converted to use pci_get_device() instead.
+ */
+static inline struct pci_dev *hisax_find_pci_device(unsigned int vendor,
+						    unsigned int device,
+						    struct pci_dev *from)
+{
+	struct pci_dev *pdev;
+
+	pci_dev_get(from);
+	pdev = pci_get_subsys(vendor, device, PCI_ANY_ID, PCI_ANY_ID, from);
+	pci_dev_put(pdev);
+	return pdev;
+}
+
+#endif
diff --git a/drivers/isdn/hisax/niccy.c b/drivers/isdn/hisax/niccy.c
index ef00633..ccaa6e1 100644
--- a/drivers/isdn/hisax/niccy.c
+++ b/drivers/isdn/hisax/niccy.c
@@ -297,12 +297,12 @@ int __devinit setup_niccy(struct IsdnCard *card)
 			return 0;
 		}
 	} else {
-#ifdef CONFIG_PCI_LEGACY
+#ifdef CONFIG_PCI
 		static struct pci_dev *niccy_dev __devinitdata;
 
 		u_int pci_ioaddr;
 		cs->subtyp = 0;
-		if ((niccy_dev = pci_find_device(PCI_VENDOR_ID_SATSAGEM,
+		if ((niccy_dev = hisax_find_pci_device(PCI_VENDOR_ID_SATSAGEM,
 						 PCI_DEVICE_ID_SATSAGEM_NICCY,
 						 niccy_dev))) {
 			if (pci_enable_device(niccy_dev))
@@ -354,7 +354,7 @@ int __devinit setup_niccy(struct IsdnCard *card)
 		printk(KERN_WARNING "Niccy: io0 0 and NO_PCI_BIOS\n");
 		printk(KERN_WARNING "Niccy: unable to config NICCY PCI\n");
 		return 0;
-#endif				/* CONFIG_PCI_LEGACY */
+#endif				/* CONFIG_PCI */
 	}
 	printk(KERN_INFO "HiSax: NICCY %s config irq:%d data:0x%X ale:0x%X\n",
 		(cs->subtyp == 1) ? "PnP" : "PCI",
diff --git a/drivers/isdn/hisax/nj_s.c b/drivers/isdn/hisax/nj_s.c
index 8d36ccc..2344e7b 100644
--- a/drivers/isdn/hisax/nj_s.c
+++ b/drivers/isdn/hisax/nj_s.c
@@ -276,7 +276,7 @@ setup_netjet_s(struct IsdnCard *card)
 
 	for ( ;; )
 	{
-		if ((dev_netjet = pci_find_device(PCI_VENDOR_ID_TIGERJET,
+		if ((dev_netjet = hisax_find_pci_device(PCI_VENDOR_ID_TIGERJET,
 			PCI_DEVICE_ID_TIGERJET_300,  dev_netjet))) {
 			ret = njs_pci_probe(dev_netjet, cs);
 			if (!ret)
diff --git a/drivers/isdn/hisax/nj_u.c b/drivers/isdn/hisax/nj_u.c
index d306c94..095e974 100644
--- a/drivers/isdn/hisax/nj_u.c
+++ b/drivers/isdn/hisax/nj_u.c
@@ -240,7 +240,7 @@ setup_netjet_u(struct IsdnCard *card)
 
 	for ( ;; )
 	{
-		if ((dev_netjet = pci_find_device(PCI_VENDOR_ID_TIGERJET,
+		if ((dev_netjet = hisax_find_pci_device(PCI_VENDOR_ID_TIGERJET,
 			PCI_DEVICE_ID_TIGERJET_300,  dev_netjet))) {
 			ret = nju_pci_probe(dev_netjet, cs);
 			if (!ret)
diff --git a/drivers/isdn/hisax/sedlbauer.c b/drivers/isdn/hisax/sedlbauer.c
index 5569a52..69dfc8d 100644
--- a/drivers/isdn/hisax/sedlbauer.c
+++ b/drivers/isdn/hisax/sedlbauer.c
@@ -598,7 +598,7 @@ setup_sedlbauer_isapnp(struct IsdnCard *card, int *bytecnt)
 }
 #endif /* __ISAPNP__ */
 
-#ifdef CONFIG_PCI_LEGACY
+#ifdef CONFIG_PCI
 static struct pci_dev *dev_sedl __devinitdata = NULL;
 
 static int __devinit
@@ -607,7 +607,7 @@ setup_sedlbauer_pci(struct IsdnCard *card)
 	struct IsdnCardState *cs = card->cs;
 	u16 sub_vendor_id, sub_id;
 
-	if ((dev_sedl = pci_find_device(PCI_VENDOR_ID_TIGERJET,
+	if ((dev_sedl = hisax_find_pci_device(PCI_VENDOR_ID_TIGERJET,
 			PCI_DEVICE_ID_TIGERJET_100, dev_sedl))) {
 		if (pci_enable_device(dev_sedl))
 			return(0);
@@ -673,7 +673,7 @@ setup_sedlbauer_pci(struct IsdnCard *card)
 	return (1);
 }
 
-#endif /* CONFIG_PCI_LEGACY */
+#endif /* CONFIG_PCI */
 
 int __devinit
 setup_sedlbauer(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/telespci.c b/drivers/isdn/hisax/telespci.c
index 28b08de..b85ceb3 100644
--- a/drivers/isdn/hisax/telespci.c
+++ b/drivers/isdn/hisax/telespci.c
@@ -300,7 +300,7 @@ setup_telespci(struct IsdnCard *card)
 	if (cs->typ != ISDN_CTYPE_TELESPCI)
 		return (0);
 
-	if ((dev_tel = pci_find_device (PCI_VENDOR_ID_ZORAN, PCI_DEVICE_ID_ZORAN_36120, dev_tel))) {
+	if ((dev_tel = hisax_find_pci_device (PCI_VENDOR_ID_ZORAN, PCI_DEVICE_ID_ZORAN_36120, dev_tel))) {
 		if (pci_enable_device(dev_tel))
 			return(0);
 		cs->irq = dev_tel->irq;
diff --git a/drivers/isdn/hisax/w6692.c b/drivers/isdn/hisax/w6692.c
index c4d862c..9d6e864 100644
--- a/drivers/isdn/hisax/w6692.c
+++ b/drivers/isdn/hisax/w6692.c
@@ -1007,7 +1007,7 @@ setup_w6692(struct IsdnCard *card)
 		return (0);
 
 	while (id_list[id_idx].vendor_id) {
-		dev_w6692 = pci_find_device(id_list[id_idx].vendor_id,
+		dev_w6692 = hisax_find_pci_device(id_list[id_idx].vendor_id,
 					    id_list[id_idx].device_id,
 					    dev_w6692);
 		if (dev_w6692) {
diff --git a/drivers/pci/Kconfig b/drivers/pci/Kconfig
index b1ecefa..7858a11 100644
--- a/drivers/pci/Kconfig
+++ b/drivers/pci/Kconfig
@@ -21,17 +21,6 @@ config PCI_MSI
 
 	   If you don't know what to do here, say N.
 
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
@@ -8,9 +8,6 @@ obj-y		+= access.o bus.o probe.o remove.o pci.o quirks.o \
 obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_SYSFS) += slot.o
 
-obj-$(CONFIG_PCI_LEGACY) += legacy.o
-CFLAGS_legacy.o += -Wno-deprecated-declarations
-
 # Build PCI Express stuff if needed
 obj-$(CONFIG_PCIEPORTBUS) += pcie/
 
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
- * pci_find_device - begin or continue searching for a PCI device by vendor/device id
- * @vendor: PCI vendor id to match, or %PCI_ANY_ID to match all vendor ids
- * @device: PCI device id to match, or %PCI_ANY_ID to match all device ids
- * @from: Previous PCI device found in search, or %NULL for new search.
- *
- * Iterates through the list of known PCI devices.  If a PCI device is found
- * with a matching @vendor and @device, a pointer to its device structure is
- * returned.  Otherwise, %NULL is returned.
- * A new search is initiated by passing %NULL as the @from argument.
- * Otherwise if @from is not %NULL, searches continue from next device
- * on the global list.
- *
- * NOTE: Do not use this function any more; use pci_get_device() instead, as
- * the PCI device returned by this function can disappear at any moment in
- * time.
- */
-struct pci_dev *pci_find_device(unsigned int vendor, unsigned int device,
-				struct pci_dev *from)
-{
-	struct pci_dev *pdev;
-
-	pci_dev_get(from);
-	pdev = pci_get_subsys(vendor, device, PCI_ANY_ID, PCI_ANY_ID, from);
-	pci_dev_put(pdev);
-	return pdev;
-}
-EXPORT_SYMBOL(pci_find_device);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 174e539..dd9682c 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -615,12 +615,6 @@ extern void pci_sort_breadthfirst(void);
 
 /* Generic PCI functions exported to card drivers */
 
-#ifdef CONFIG_PCI_LEGACY
-struct pci_dev __deprecated *pci_find_device(unsigned int vendor,
-					     unsigned int device,
-					     struct pci_dev *from);
-#endif /* CONFIG_PCI_LEGACY */
-
 enum pci_lost_interrupt_reason {
 	PCI_LOST_IRQ_NO_INFORMATION = 0,
 	PCI_LOST_IRQ_DISABLE_MSI,
@@ -973,13 +967,6 @@ static inline int pci_proc_domain(struct pci_bus *bus)
 _PCI_NOP_ALL(read, *)
 _PCI_NOP_ALL(write,)
 
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
-- 
1.6.5.3.298.g39add

