From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: fix section mismatches
Date: Tue, 19 Apr 2011 01:31:20 +0200 (CEST)
Message-ID: <20110418233120.E4B1F138DD@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Jaroslav Kysela <perex@perex.cz>,
	Samuel Ortiz <samuel@sortiz.org>,
	Grant Grundler <grundler@parisc-linux.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46014 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512Ab1DRXbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 19:31:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix build warnings like the following:

WARNING: drivers/net/built-in.o(.data+0x12434): Section mismatch in ref=
erence from the variable madgemc_driver to the variable .init.data:madg=
emc_adapter_ids

And add some consts to EISA device ID tables along the way.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

This is what I now use to keep all those section mismatch warnings from
clobbering my build log that kept me from noticing more important warni=
ngs.
Please accept or ignore as you see fit.

Thanks,
Micha=C5=82 Miros=C5=82aw
---

 drivers/net/3c509.c             |   14 ++++++------
 drivers/net/3c59x.c             |    4 +-
 drivers/net/depca.c             |   35 ++++++++++++++++---------------
 drivers/net/hp100.c             |   12 +++++-----
 drivers/net/ibmlana.c           |    4 +-
 drivers/net/irda/smsc-ircc2.c   |   44 +++++++++++++++++++------------=
-------
 drivers/net/ne3210.c            |   15 ++++++++-----
 drivers/net/smc-mca.c           |    6 ++--
 drivers/net/tokenring/madgemc.c |    2 +-
 drivers/net/tulip/de4x5.c       |    4 +-
 10 files changed, 72 insertions(+), 68 deletions(-)

diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 91abb96..cb39ded 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -185,7 +185,7 @@ static int max_interrupt_work =3D 10;
 static int nopnp;
 #endif
=20
-static int __devinit el3_common_init(struct net_device *dev);
+static int el3_common_init(struct net_device *dev);
 static void el3_common_remove(struct net_device *dev);
 static ushort id_read_eeprom(int index);
 static ushort read_eeprom(int ioaddr, int index);
@@ -395,7 +395,7 @@ static struct isa_driver el3_isa_driver =3D {
 static int isa_registered;
=20
 #ifdef CONFIG_PNP
-static struct pnp_device_id el3_pnp_ids[] =3D {
+static const struct pnp_device_id el3_pnp_ids[] __devinitconst =3D {
 	{ .id =3D "TCM5090" }, /* 3Com Etherlink III (TP) */
 	{ .id =3D "TCM5091" }, /* 3Com Etherlink III */
 	{ .id =3D "TCM5094" }, /* 3Com Etherlink III (combo) */
@@ -478,7 +478,7 @@ static int pnp_registered;
 #endif /* CONFIG_PNP */
=20
 #ifdef CONFIG_EISA
-static struct eisa_device_id el3_eisa_ids[] =3D {
+static const struct eisa_device_id el3_eisa_ids[] __devinitconst =3D {
 		{ "TCM5090" },
 		{ "TCM5091" },
 		{ "TCM5092" },
@@ -508,7 +508,7 @@ static int eisa_registered;
 #ifdef CONFIG_MCA
 static int el3_mca_probe(struct device *dev);
=20
-static short el3_mca_adapter_ids[] __initdata =3D {
+static const short el3_mca_adapter_ids[] __devinitconst =3D {
 		0x627c,
 		0x627d,
 		0x62db,
@@ -517,7 +517,7 @@ static short el3_mca_adapter_ids[] __initdata =3D {
 		0x0000
 };
=20
-static char *el3_mca_adapter_names[] __initdata =3D {
+static const char *const el3_mca_adapter_names[] __devinitconst =3D {
 		"3Com 3c529 EtherLink III (10base2)",
 		"3Com 3c529 EtherLink III (10baseT)",
 		"3Com 3c529 EtherLink III (test mode)",
@@ -601,7 +601,7 @@ static void el3_common_remove (struct net_device *d=
ev)
 }
=20
 #ifdef CONFIG_MCA
-static int __init el3_mca_probe(struct device *device)
+static int __devinit el3_mca_probe(struct device *device)
 {
 	/* Based on Erik Nygren's (nygren@mit.edu) 3c529 patch,
 	 * heavily modified by Chris Beauregard
@@ -671,7 +671,7 @@ static int __init el3_mca_probe(struct device *devi=
ce)
 #endif /* CONFIG_MCA */
=20
 #ifdef CONFIG_EISA
-static int __init el3_eisa_probe (struct device *device)
+static int __devinit el3_eisa_probe (struct device *device)
 {
 	short i;
 	int ioaddr, irq, if_port;
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 8cc2256..99f43d2 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -901,14 +901,14 @@ static const struct dev_pm_ops vortex_pm_ops =3D =
{
 #endif /* !CONFIG_PM */
=20
 #ifdef CONFIG_EISA
-static struct eisa_device_id vortex_eisa_ids[] =3D {
+static const struct eisa_device_id vortex_eisa_ids[] __devinitconst =3D=
 {
 	{ "TCM5920", CH_3C592 },
 	{ "TCM5970", CH_3C597 },
 	{ "" }
 };
 MODULE_DEVICE_TABLE(eisa, vortex_eisa_ids);
=20
-static int __init vortex_eisa_probe(struct device *device)
+static int __devinit vortex_eisa_probe(struct device *device)
 {
 	void __iomem *ioaddr;
 	struct eisa_device *edev;
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 8b0084d..1765405 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -331,18 +331,18 @@ static struct {
                          "DE422",\
                          ""}
=20
-static char* __initdata depca_signature[] =3D DEPCA_SIGNATURE;
+static const char* const depca_signature[] __devinitconst =3D DEPCA_SI=
GNATURE;
=20
 enum depca_type {
 	DEPCA, de100, de101, de200, de201, de202, de210, de212, de422, unknow=
n
 };
=20
-static char depca_string[] =3D "depca";
+static const char depca_string[] =3D "depca";
=20
 static int depca_device_remove (struct device *device);
=20
 #ifdef CONFIG_EISA
-static struct eisa_device_id depca_eisa_ids[] =3D {
+static const struct eisa_device_id depca_eisa_ids[] __devinitconst =3D=
 {
 	{ "DEC4220", de422 },
 	{ "" }
 };
@@ -367,19 +367,19 @@ static struct eisa_driver depca_eisa_driver =3D {
 #define DE210_ID 0x628d
 #define DE212_ID 0x6def
=20
-static short depca_mca_adapter_ids[] =3D {
+static const short depca_mca_adapter_ids[] __devinitconst =3D {
 	DE210_ID,
 	DE212_ID,
 	0x0000
 };
=20
-static char *depca_mca_adapter_name[] =3D {
+static const char *depca_mca_adapter_name[] =3D {
 	"DEC EtherWORKS MC Adapter (DE210)",
 	"DEC EtherWORKS MC Adapter (DE212)",
 	NULL
 };
=20
-static enum depca_type depca_mca_adapter_type[] =3D {
+static const enum depca_type depca_mca_adapter_type[] =3D {
 	de210,
 	de212,
 	0
@@ -541,10 +541,9 @@ static void SetMulticastFilter(struct net_device *=
dev);
 static int load_packet(struct net_device *dev, struct sk_buff *skb);
 static void depca_dbg_open(struct net_device *dev);
=20
-static u_char de1xx_irq[] __initdata =3D { 2, 3, 4, 5, 7, 9, 0 };
-static u_char de2xx_irq[] __initdata =3D { 5, 9, 10, 11, 15, 0 };
-static u_char de422_irq[] __initdata =3D { 5, 9, 10, 11, 0 };
-static u_char *depca_irq;
+static const u_char de1xx_irq[] __devinitconst =3D { 2, 3, 4, 5, 7, 9,=
 0 };
+static const u_char de2xx_irq[] __devinitconst =3D { 5, 9, 10, 11, 15,=
 0 };
+static const u_char de422_irq[] __devinitconst =3D { 5, 9, 10, 11, 0 }=
;
=20
 static int irq;
 static int io;
@@ -580,7 +579,7 @@ static const struct net_device_ops depca_netdev_ops=
 =3D {
 	.ndo_validate_addr	=3D eth_validate_addr,
 };
=20
-static int __init depca_hw_init (struct net_device *dev, struct device=
 *device)
+static int __devinit depca_hw_init (struct net_device *dev, struct dev=
ice *device)
 {
 	struct depca_private *lp;
 	int i, j, offset, netRAM, mem_len, status =3D 0;
@@ -748,6 +747,7 @@ static int __init depca_hw_init (struct net_device =
*dev, struct device *device)
 	if (dev->irq < 2) {
 		unsigned char irqnum;
 		unsigned long irq_mask, delay;
+		const u_char *depca_irq;
=20
 		irq_mask =3D probe_irq_on();
=20
@@ -770,6 +770,7 @@ static int __init depca_hw_init (struct net_device =
*dev, struct device *device)
 			break;
=20
 		default:
+			depca_irq =3D NULL;
 			break;	/* Not reached */
 		}
=20
@@ -1302,7 +1303,7 @@ static void SetMulticastFilter(struct net_device =
*dev)
 	}
 }
=20
-static int __init depca_common_init (u_long ioaddr, struct net_device =
**devp)
+static int __devinit depca_common_init (u_long ioaddr, struct net_devi=
ce **devp)
 {
 	int status =3D 0;
=20
@@ -1333,7 +1334,7 @@ static int __init depca_common_init (u_long ioadd=
r, struct net_device **devp)
 /*
 ** Microchannel bus I/O device probe
 */
-static int __init depca_mca_probe(struct device *device)
+static int __devinit depca_mca_probe(struct device *device)
 {
 	unsigned char pos[2];
 	unsigned char where;
@@ -1457,7 +1458,7 @@ static int __init depca_mca_probe(struct device *=
device)
 ** ISA bus I/O device probe
 */
=20
-static void __init depca_platform_probe (void)
+static void __devinit depca_platform_probe (void)
 {
 	int i;
 	struct platform_device *pldev;
@@ -1497,7 +1498,7 @@ static void __init depca_platform_probe (void)
 	}
 }
=20
-static enum depca_type __init depca_shmem_probe (ulong *mem_start)
+static enum depca_type __devinit depca_shmem_probe (ulong *mem_start)
 {
 	u_long mem_base[] =3D DEPCA_RAM_BASE_ADDRESSES;
 	enum depca_type adapter =3D unknown;
@@ -1558,7 +1559,7 @@ static int __devinit depca_isa_probe (struct plat=
form_device *device)
 */
=20
 #ifdef CONFIG_EISA
-static int __init depca_eisa_probe (struct device *device)
+static int __devinit depca_eisa_probe (struct device *device)
 {
 	enum depca_type adapter =3D unknown;
 	struct eisa_device *edev;
@@ -1629,7 +1630,7 @@ static int __devexit depca_device_remove (struct =
device *device)
 ** and Boot (readb) ROM. This will also give us a clue to the network =
RAM
 ** base address.
 */
-static int __init DepcaSignature(char *name, u_long base_addr)
+static int __devinit DepcaSignature(char *name, u_long base_addr)
 {
 	u_int i, j, k;
 	void __iomem *ptr;
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 8e10d2f..c52a1df 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -188,14 +188,14 @@ struct hp100_private {
  *  variables
  */
 #ifdef CONFIG_ISA
-static const char *hp100_isa_tbl[] =3D {
+static const char *const hp100_isa_tbl[] __devinitconst =3D {
 	"HWPF150", /* HP J2573 rev A */
 	"HWP1950", /* HP J2573 */
 };
 #endif
=20
 #ifdef CONFIG_EISA
-static struct eisa_device_id hp100_eisa_tbl[] =3D {
+static const struct eisa_device_id hp100_eisa_tbl[] __devinitconst =3D=
 {
 	{ "HWPF180" }, /* HP J2577 rev A */
 	{ "HWP1920" }, /* HP 27248B */
 	{ "HWP1940" }, /* HP J2577 */
@@ -336,7 +336,7 @@ static __devinit const char *hp100_read_id(int ioad=
dr)
 }
=20
 #ifdef CONFIG_ISA
-static __init int hp100_isa_probe1(struct net_device *dev, int ioaddr)
+static __devinit int hp100_isa_probe1(struct net_device *dev, int ioad=
dr)
 {
 	const char *sig;
 	int i;
@@ -372,7 +372,7 @@ static __init int hp100_isa_probe1(struct net_devic=
e *dev, int ioaddr)
  * EISA and PCI are handled by device infrastructure.
  */
=20
-static int  __init hp100_isa_probe(struct net_device *dev, int addr)
+static int  __devinit hp100_isa_probe(struct net_device *dev, int addr=
)
 {
 	int err =3D -ENODEV;
=20
@@ -396,7 +396,7 @@ static int  __init hp100_isa_probe(struct net_devic=
e *dev, int addr)
 #endif /* CONFIG_ISA */
=20
 #if !defined(MODULE) && defined(CONFIG_ISA)
-struct net_device * __init hp100_probe(int unit)
+struct net_device * __devinit hp100_probe(int unit)
 {
 	struct net_device *dev =3D alloc_etherdev(sizeof(struct hp100_private=
));
 	int err;
@@ -2843,7 +2843,7 @@ static void cleanup_dev(struct net_device *d)
 }
=20
 #ifdef CONFIG_EISA
-static int __init hp100_eisa_probe (struct device *gendev)
+static int __devinit hp100_eisa_probe (struct device *gendev)
 {
 	struct net_device *dev =3D alloc_etherdev(sizeof(struct hp100_private=
));
 	struct eisa_device *edev =3D to_eisa_device(gendev);
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index a7d6cad..136d754 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -895,12 +895,12 @@ static int ibmlana_irq;
 static int ibmlana_io;
 static int startslot;		/* counts through slots when probing multiple d=
evices */
=20
-static short ibmlana_adapter_ids[] __initdata =3D {
+static const short ibmlana_adapter_ids[] __devinitconst =3D {
 	IBM_LANA_ID,
 	0x0000
 };
=20
-static char *ibmlana_adapter_names[] __devinitdata =3D {
+static const char *const ibmlana_adapter_names[] __devinitconst =3D {
 	"IBM LAN Adapter/A",
 	NULL
 };
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc=
2.c
index 8800e1f..69b5707 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -222,19 +222,19 @@ static void smsc_ircc_set_transceiver_for_speed(s=
truct smsc_ircc_cb *self, u32 s
 static void smsc_ircc_sir_wait_hw_transmitter_finish(struct smsc_ircc_=
cb *self);
=20
 /* Probing */
-static int __init smsc_ircc_look_for_chips(void);
-static const struct smsc_chip * __init smsc_ircc_probe(unsigned short =
cfg_base, u8 reg, const struct smsc_chip *chip, char *type);
-static int __init smsc_superio_flat(const struct smsc_chip *chips, uns=
igned short cfg_base, char *type);
-static int __init smsc_superio_paged(const struct smsc_chip *chips, un=
signed short cfg_base, char *type);
-static int __init smsc_superio_fdc(unsigned short cfg_base);
-static int __init smsc_superio_lpc(unsigned short cfg_base);
+static int smsc_ircc_look_for_chips(void);
+static const struct smsc_chip * smsc_ircc_probe(unsigned short cfg_bas=
e, u8 reg, const struct smsc_chip *chip, char *type);
+static int smsc_superio_flat(const struct smsc_chip *chips, unsigned s=
hort cfg_base, char *type);
+static int smsc_superio_paged(const struct smsc_chip *chips, unsigned =
short cfg_base, char *type);
+static int smsc_superio_fdc(unsigned short cfg_base);
+static int smsc_superio_lpc(unsigned short cfg_base);
 #ifdef CONFIG_PCI
-static int __init preconfigure_smsc_chip(struct smsc_ircc_subsystem_co=
nfiguration *conf);
-static int __init preconfigure_through_82801(struct pci_dev *dev, stru=
ct smsc_ircc_subsystem_configuration *conf);
-static void __init preconfigure_ali_port(struct pci_dev *dev,
+static int preconfigure_smsc_chip(struct smsc_ircc_subsystem_configura=
tion *conf);
+static int preconfigure_through_82801(struct pci_dev *dev, struct smsc=
_ircc_subsystem_configuration *conf);
+static void preconfigure_ali_port(struct pci_dev *dev,
 					 unsigned short port);
-static int __init preconfigure_through_ali(struct pci_dev *dev, struct=
 smsc_ircc_subsystem_configuration *conf);
-static int __init smsc_ircc_preconfigure_subsystems(unsigned short irc=
c_cfg,
+static int preconfigure_through_ali(struct pci_dev *dev, struct smsc_i=
rcc_subsystem_configuration *conf);
+static int smsc_ircc_preconfigure_subsystems(unsigned short ircc_cfg,
 						    unsigned short ircc_fir,
 						    unsigned short ircc_sir,
 						    unsigned char ircc_dma,
@@ -366,7 +366,7 @@ static inline void register_bank(int iobase, int ba=
nk)
 }
=20
 /* PNP hotplug support */
-static const struct pnp_device_id smsc_ircc_pnp_table[] =3D {
+static const struct pnp_device_id smsc_ircc_pnp_table[] __devinitconst=
 =3D {
 	{ .id =3D "SMCf010", .driver_data =3D 0 },
 	/* and presumably others */
 	{ }
@@ -515,7 +515,7 @@ static const struct net_device_ops smsc_ircc_netdev=
_ops =3D {
  *    Try to open driver instance
  *
  */
-static int __init smsc_ircc_open(unsigned int fir_base, unsigned int s=
ir_base, u8 dma, u8 irq)
+static int __devinit smsc_ircc_open(unsigned int fir_base, unsigned in=
t sir_base, u8 dma, u8 irq)
 {
 	struct smsc_ircc_cb *self;
 	struct net_device *dev;
@@ -2273,7 +2273,7 @@ static int __init smsc_superio_paged(const struct=
 smsc_chip *chips, unsigned sho
 }
=20
=20
-static int __init smsc_access(unsigned short cfg_base, unsigned char r=
eg)
+static int __devinit smsc_access(unsigned short cfg_base, unsigned cha=
r reg)
 {
 	IRDA_DEBUG(1, "%s\n", __func__);
=20
@@ -2281,7 +2281,7 @@ static int __init smsc_access(unsigned short cfg_=
base, unsigned char reg)
 	return inb(cfg_base) !=3D reg ? -1 : 0;
 }
=20
-static const struct smsc_chip * __init smsc_ircc_probe(unsigned short =
cfg_base, u8 reg, const struct smsc_chip *chip, char *type)
+static const struct smsc_chip * __devinit smsc_ircc_probe(unsigned sho=
rt cfg_base, u8 reg, const struct smsc_chip *chip, char *type)
 {
 	u8 devid, xdevid, rev;
=20
@@ -2406,7 +2406,7 @@ static int __init smsc_superio_lpc(unsigned short=
 cfg_base)
 #ifdef CONFIG_PCI
 #define PCIID_VENDOR_INTEL 0x8086
 #define PCIID_VENDOR_ALI 0x10b9
-static struct smsc_ircc_subsystem_configuration subsystem_configuratio=
ns[] __initdata =3D {
+static const struct smsc_ircc_subsystem_configuration subsystem_config=
urations[] __devinitconst =3D {
 	/*
 	 * Subsystems needing entries:
 	 * 0x10b9:0x1533 0x103c:0x0850 HP nx9010 family
@@ -2532,7 +2532,7 @@ static struct smsc_ircc_subsystem_configuration s=
ubsystem_configurations[] __ini
  * (FIR port, SIR port, FIR DMA, FIR IRQ)
  * through the chip configuration port.
  */
-static int __init preconfigure_smsc_chip(struct
+static int __devinit preconfigure_smsc_chip(struct
 					 smsc_ircc_subsystem_configuration
 					 *conf)
 {
@@ -2633,7 +2633,7 @@ static int __init preconfigure_smsc_chip(struct
  * or Intel 82801DB/DBL (ICH4/ICH4-L) LPC Interface Bridge.
  * They all work the same way!
  */
-static int __init preconfigure_through_82801(struct pci_dev *dev,
+static int __devinit preconfigure_through_82801(struct pci_dev *dev,
 					     struct
 					     smsc_ircc_subsystem_configuration
 					     *conf)
@@ -2786,7 +2786,7 @@ static int __init preconfigure_through_82801(stru=
ct pci_dev *dev,
  * This is based on reverse-engineering since ALi does not
  * provide any data sheet for the 1533 chip.
  */
-static void __init preconfigure_ali_port(struct pci_dev *dev,
+static void __devinit preconfigure_ali_port(struct pci_dev *dev,
 					 unsigned short port)
 {
 	unsigned char reg;
@@ -2824,7 +2824,7 @@ static void __init preconfigure_ali_port(struct p=
ci_dev *dev,
 	IRDA_MESSAGE("Activated ALi 1533 ISA bridge port 0x%04x.\n", port);
 }
=20
-static int __init preconfigure_through_ali(struct pci_dev *dev,
+static int __devinit preconfigure_through_ali(struct pci_dev *dev,
 					   struct
 					   smsc_ircc_subsystem_configuration
 					   *conf)
@@ -2837,7 +2837,7 @@ static int __init preconfigure_through_ali(struct=
 pci_dev *dev,
 	return preconfigure_smsc_chip(conf);
 }
=20
-static int __init smsc_ircc_preconfigure_subsystems(unsigned short irc=
c_cfg,
+static int __devinit smsc_ircc_preconfigure_subsystems(unsigned short =
ircc_cfg,
 						    unsigned short ircc_fir,
 						    unsigned short ircc_sir,
 						    unsigned char ircc_dma,
@@ -2849,7 +2849,7 @@ static int __init smsc_ircc_preconfigure_subsyste=
ms(unsigned short ircc_cfg,
 	int ret =3D 0;
=20
 	for_each_pci_dev(dev) {
-		struct smsc_ircc_subsystem_configuration *conf;
+		const struct smsc_ircc_subsystem_configuration *conf;
=20
 		/*
 		 * Cache the subsystem vendor/device:
diff --git a/drivers/net/ne3210.c b/drivers/net/ne3210.c
index 243ed2a..e8984b0 100644
--- a/drivers/net/ne3210.c
+++ b/drivers/net/ne3210.c
@@ -80,17 +80,20 @@ static void ne3210_block_output(struct net_device *=
dev, int count, const unsigne
=20
 #define NE3210_DEBUG	0x0
=20
-static unsigned char irq_map[] __initdata =3D {15, 12, 11, 10, 9, 7, 5=
, 3};
-static unsigned int shmem_map[] __initdata =3D {0xff0, 0xfe0, 0xfff0, =
0xd8, 0xffe0, 0xffc0, 0xd0, 0x0};
-static const char *ifmap[] __initdata =3D {"UTP", "?", "BNC", "AUI"};
-static int ifmap_val[] __initdata =3D {
+static const unsigned char irq_map[] __devinitconst =3D
+	{ 15, 12, 11, 10, 9, 7, 5, 3 };
+static const unsigned int shmem_map[] __devinitconst =3D
+	{ 0xff0, 0xfe0, 0xfff0, 0xd8, 0xffe0, 0xffc0, 0xd0, 0x0 };
+static const char *const ifmap[] __devinitconst =3D
+	{ "UTP", "?", "BNC", "AUI" };
+static const int ifmap_val[] __devinitconst =3D {
 		IF_PORT_10BASET,
 		IF_PORT_UNKNOWN,
 		IF_PORT_10BASE2,
 		IF_PORT_AUI,
 };
=20
-static int __init ne3210_eisa_probe (struct device *device)
+static int __devinit ne3210_eisa_probe (struct device *device)
 {
 	unsigned long ioaddr, phys_mem;
 	int i, retval, port_index;
@@ -313,7 +316,7 @@ static void ne3210_block_output(struct net_device *=
dev, int count,
 	memcpy_toio(shmem, buf, count);
 }
=20
-static struct eisa_device_id ne3210_ids[] =3D {
+static const struct eisa_device_id ne3210_ids[] __devinitconst =3D {
 	{ "EGL0101" },
 	{ "NVL1801" },
 	{ "" },
diff --git a/drivers/net/smc-mca.c b/drivers/net/smc-mca.c
index d07c39c..0f29f26 100644
--- a/drivers/net/smc-mca.c
+++ b/drivers/net/smc-mca.c
@@ -156,7 +156,7 @@ static const struct {
    { 14, 15 }
 };
=20
-static short smc_mca_adapter_ids[] __initdata =3D {
+static const short smc_mca_adapter_ids[] __devinitconst =3D {
 	0x61c8,
 	0x61c9,
 	0x6fc0,
@@ -168,7 +168,7 @@ static short smc_mca_adapter_ids[] __initdata =3D {
 	0x0000
 };
=20
-static char *smc_mca_adapter_names[] __initdata =3D {
+static const char *const smc_mca_adapter_names[] __devinitconst =3D {
 	"SMC Ethercard PLUS Elite/A BNC/AUI (WD8013EP/A)",
 	"SMC Ethercard PLUS Elite/A UTP/AUI (WD8013WP/A)",
 	"WD Ethercard PLUS/A (WD8003E/A or WD8003ET/A)",
@@ -199,7 +199,7 @@ static const struct net_device_ops ultramca_netdev_=
ops =3D {
 #endif
 };
=20
-static int __init ultramca_probe(struct device *gen_dev)
+static int __devinit ultramca_probe(struct device *gen_dev)
 {
 	unsigned short ioaddr;
 	struct net_device *dev;
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/ma=
dgemc.c
index 2bedc0a..1313aa1 100644
--- a/drivers/net/tokenring/madgemc.c
+++ b/drivers/net/tokenring/madgemc.c
@@ -727,7 +727,7 @@ static int __devexit madgemc_remove(struct device *=
device)
 	return 0;
 }
=20
-static short madgemc_adapter_ids[] __initdata =3D {
+static const short madgemc_adapter_ids[] __devinitconst =3D {
 	0x002d,
 	0x0000
 };
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index efaa1d6..45144d5 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1995,7 +1995,7 @@ SetMulticastFilter(struct net_device *dev)
=20
 static u_char de4x5_irq[] =3D EISA_ALLOWED_IRQ_LIST;
=20
-static int __init de4x5_eisa_probe (struct device *gendev)
+static int __devinit de4x5_eisa_probe (struct device *gendev)
 {
 	struct eisa_device *edev;
 	u_long iobase;
@@ -2097,7 +2097,7 @@ static int __devexit de4x5_eisa_remove (struct de=
vice *device)
 	return 0;
 }
=20
-static struct eisa_device_id de4x5_eisa_ids[] =3D {
+static const struct eisa_device_id de4x5_eisa_ids[] __devinitconst =3D=
 {
         { "DEC4250", 0 },	/* 0 is the board name index... */
         { "" }
 };
--=20
1.7.2.5

