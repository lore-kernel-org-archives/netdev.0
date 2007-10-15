From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Mon, 15 Oct 2007 16:19:20 -0400
Message-ID: <20071015201920.GA3960@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933883AbXJOUTx@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The MIPS stuff was ACK'd by Ralf.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 Documentation/networking/bonding.txt           |   33 +
 arch/mips/au1000/common/prom.c                 |   61 +-
 arch/mips/au1000/common/setup.c                |    5 +-
 arch/mips/au1000/db1x00/init.c                 |   10 +-
 arch/mips/au1000/mtx-1/init.c                  |    6 +-
 arch/mips/au1000/pb1000/init.c                 |   10 +-
 arch/mips/au1000/pb1100/init.c                 |   10 +-
 arch/mips/au1000/pb1200/board_setup.c          |    6 +-
 arch/mips/au1000/pb1200/init.c                 |   10 +-
 arch/mips/au1000/pb1500/init.c                 |   10 +-
 arch/mips/au1000/pb1550/init.c                 |   10 +-
 arch/mips/au1000/xxs1500/init.c                |   10 +-
 arch/powerpc/platforms/cell/axon_msi.c         |   11 +-
 arch/powerpc/sysdev/dcr.c                      |    4 +-
 arch/powerpc/sysdev/mpic.c                     |    4 +-
 drivers/infiniband/ulp/ipoib/ipoib.h           |    4 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   29 +-
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    3 +-
 drivers/net/Kconfig                            |    9 +
 drivers/net/Makefile                           |    1 +
 drivers/net/au1000_eth.c                       |   28 +-
 drivers/net/bonding/bond_main.c                |  207 ++++-
 drivers/net/bonding/bond_sysfs.c               |   74 ++-
 drivers/net/bonding/bonding.h                  |   10 +-
 drivers/net/cassini.c                          |    2 +-
 drivers/net/cpmac.c                            | 1174 ++++++++++++++++++++++++
 drivers/net/gianfar.c                          |   14 +-
 drivers/net/ibm_emac/ibm_emac_mal.c            |    5 +-
 drivers/net/ibm_emac/ibm_emac_mal.h            |    5 +-
 drivers/net/ibm_newemac/mal.c                  |    9 +-
 drivers/net/ibm_newemac/mal.h                  |    5 +-
 drivers/net/irda/donauboe.c                    |    2 +-
 drivers/net/jazzsonic.c                        |    1 -
 drivers/net/mipsnet.c                          |   63 +-
 drivers/net/mipsnet.h                          |   83 +-
 drivers/net/myri10ge/myri10ge.c                |  100 ++-
 drivers/net/myri10ge/myri10ge_mcp.h            |   90 ++-
 drivers/net/natsemi.c                          |   20 +-
 drivers/net/ne-h8300.c                         |    4 +-
 drivers/net/saa9730.c                          |    9 +-
 drivers/net/tc35815.c                          |    1 -
 drivers/net/tehuti.c                           |    3 +-
 drivers/net/tg3.c                              |    2 +-
 drivers/net/tulip/de4x5.c                      |    4 +-
 drivers/net/ucc_geth.c                         |    5 +-
 drivers/net/wan/sdla.c                         |    8 +-
 drivers/net/xen-netfront.c                     |   35 +-
 include/asm-mips/mach-au1x00/prom.h            |   13 +
 include/asm-powerpc/dcr-mmio.h                 |    6 +-
 include/asm-powerpc/dcr-native.h               |    6 +-
 include/linux/skbuff.h                         |    5 +
 51 files changed, 1914 insertions(+), 325 deletions(-)
 create mode 100644 drivers/net/cpmac.c
 create mode 100644 include/asm-mips/mach-au1x00/prom.h

Alejandro Martinez Ruiz (1):
      netdev: convert non-obvious instances to use ARRAY_SIZE()

Brice Goglin (5):
      myri10ge: fix some indentation, white spaces, and comments
      myri10ge: update firmware headers
      Add skb_is_gso_v6
      myri10ge: add IPv6 TSO support
      myri10ge: update driver version to 1.3.2-1.287

Emil Medve (1):
      ucc_geth: Fix build break introduced by commit 09f75cd7bf13720738e6a196cc0107ce9a5bd5a0

Florin Malita (1):
      tehuti: possible leak in bdx_probe

Jay Vosburgh (1):
      net/bonding: Optionally allow ethernet slaves to keep own MAC

Jeremy Fitzhardinge (1):
      xen-netfront: rearrange netfront structure to separate tx and rx

Li Yang (3):
      gianfar: Fix compile regression caused by bea3348e
      gianfar: Cleanup compile warning caused by 0795af57
      gianfar: Fix regression caused by new napi interface

Mark Brown (2):
      natsemi: Use round_jiffies() for slow timers
      natsemi: Check return value for pci_enable_device()

Matteo Croce (1):
      AR7 ethernet

Michael Ellerman (5):
      Update ibm_newemac to use dcr_host_t.base
      Use dcr_host_t.base in ibm_emac_mal
      Add dcr_host_t.base in dcr_read()/dcr_write()
      Use dcr_host_t.base in dcr_unmap()
      Remove msic_dcr_read() in axon_msi.c

Moni Shoua (8):
      IB/ipoib: Bound the net device to the ipoib_neigh structue
      IB/ipoib: Verify address handle validity on send
      net/bonding: Enable bonding to enslave non ARPHRD_ETHER
      net/bonding: Enable bonding to enslave netdevices not supporting set_mac_address()
      net/bonding: Enable IP multicast for bonding IPoIB devices
      net/bonding: Handlle wrong assumptions that slave is always an Ethernet device
      net/bonding: Delay sending of gratuitous ARP to avoid failure
      net/bonding: Destroy bonding master when last slave is gone

Ralf Baechle (4):
      SAA9730: Fix build
      TC35815: Fix build
      Jazzsonic: Fix warning about unused variable.
      MIPSsim: General cleanup

Yoichi Yuasa (2):
      update AU1000 get_ethernet_addr()
      add new prom.h for AU1x00

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 1da5666..1134062 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -281,6 +281,39 @@ downdelay
 	will be rounded down to the nearest multiple.  The default
 	value is 0.
 
+fail_over_mac
+
+	Specifies whether active-backup mode should set all slaves to
+	the same MAC address (the traditional behavior), or, when
+	enabled, change the bond's MAC address when changing the
+	active interface (i.e., fail over the MAC address itself).
+
+	Fail over MAC is useful for devices that cannot ever alter
+	their MAC address, or for devices that refuse incoming
+	broadcasts with their own source MAC (which interferes with
+	the ARP monitor).
+
+	The down side of fail over MAC is that every device on the
+	network must be updated via gratuitous ARP, vs. just updating
+	a switch or set of switches (which often takes place for any
+	traffic, not just ARP traffic, if the switch snoops incoming
+	traffic to update its tables) for the traditional method.  If
+	the gratuitous ARP is lost, communication may be disrupted.
+
+	When fail over MAC is used in conjuction with the mii monitor,
+	devices which assert link up prior to being able to actually
+	transmit and receive are particularly susecptible to loss of
+	the gratuitous ARP, and an appropriate updelay setting may be
+	required.
+
+	A value of 0 disables fail over MAC, and is the default.  A
+	value of 1 enables fail over MAC.  This option is enabled
+	automatically if the first slave added cannot change its MAC
+	address.  This option may be modified via sysfs only when no
+	slaves are present in the bond.
+
+	This option was added in bonding version 3.2.0.
+
 lacp_rate
 
 	Option specifying the rate in which we'll ask our link partner
diff --git a/arch/mips/au1000/common/prom.c b/arch/mips/au1000/common/prom.c
index a8637cd..90d7069 100644
--- a/arch/mips/au1000/common/prom.c
+++ b/arch/mips/au1000/common/prom.c
@@ -33,7 +33,6 @@
  *  with this program; if not, write  to the Free Software Foundation, Inc.,
  *  675 Mass Ave, Cambridge, MA 02139, USA.
  */
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -41,18 +40,16 @@
 
 #include <asm/bootinfo.h>
 
-/* #define DEBUG_CMDLINE */
-
-extern int prom_argc;
-extern char **prom_argv, **prom_envp;
-
+int prom_argc;
+char **prom_argv;
+char **prom_envp;
 
 char * __init_or_module prom_getcmdline(void)
 {
 	return &(arcs_cmdline[0]);
 }
 
-void  prom_init_cmdline(void)
+void prom_init_cmdline(void)
 {
 	char *cp;
 	int actr;
@@ -61,7 +58,7 @@ void  prom_init_cmdline(void)
 
 	cp = &(arcs_cmdline[0]);
 	while(actr < prom_argc) {
-	        strcpy(cp, prom_argv[actr]);
+		strcpy(cp, prom_argv[actr]);
 		cp += strlen(prom_argv[actr]);
 		*cp++ = ' ';
 		actr++;
@@ -70,10 +67,8 @@ void  prom_init_cmdline(void)
 		--cp;
 	if (prom_argc > 1)
 		*cp = '\0';
-
 }
 
-
 char *prom_getenv(char *envname)
 {
 	/*
@@ -95,21 +90,23 @@ char *prom_getenv(char *envname)
 		}
 		env++;
 	}
+
 	return NULL;
 }
 
-inline unsigned char str2hexnum(unsigned char c)
+static inline unsigned char str2hexnum(unsigned char c)
 {
-	if(c >= '0' && c <= '9')
+	if (c >= '0' && c <= '9')
 		return c - '0';
-	if(c >= 'a' && c <= 'f')
+	if (c >= 'a' && c <= 'f')
 		return c - 'a' + 10;
-	if(c >= 'A' && c <= 'F')
+	if (c >= 'A' && c <= 'F')
 		return c - 'A' + 10;
+
 	return 0; /* foo */
 }
 
-inline void str2eaddr(unsigned char *ea, unsigned char *str)
+static inline void str2eaddr(unsigned char *ea, unsigned char *str)
 {
 	int i;
 
@@ -124,35 +121,29 @@ inline void str2eaddr(unsigned char *ea, unsigned char *str)
 	}
 }
 
-int get_ethernet_addr(char *ethernet_addr)
+int prom_get_ethernet_addr(char *ethernet_addr)
 {
-        char *ethaddr_str;
+	char *ethaddr_str;
+	char *argptr;
 
-        ethaddr_str = prom_getenv("ethaddr");
+	/* Check the environment variables first */
+	ethaddr_str = prom_getenv("ethaddr");
 	if (!ethaddr_str) {
-	        printk("ethaddr not set in boot prom\n");
-		return -1;
-	}
-	str2eaddr(ethernet_addr, ethaddr_str);
-
-#if 0
-	{
-		int i;
+		/* Check command line */
+		argptr = prom_getcmdline();
+		ethaddr_str = strstr(argptr, "ethaddr=");
+		if (!ethaddr_str)
+			return -1;
 
-	printk("get_ethernet_addr: ");
-	for (i=0; i<5; i++)
-		printk("%02x:", (unsigned char)*(ethernet_addr+i));
-	printk("%02x\n", *(ethernet_addr+i));
+		ethaddr_str += strlen("ethaddr=");
 	}
-#endif
+
+	str2eaddr(ethernet_addr, ethaddr_str);
 
 	return 0;
 }
+EXPORT_SYMBOL(prom_get_ethernet_addr);
 
 void __init prom_free_prom_memory(void)
 {
 }
-
-EXPORT_SYMBOL(prom_getcmdline);
-EXPORT_SYMBOL(get_ethernet_addr);
-EXPORT_SYMBOL(str2eaddr);
diff --git a/arch/mips/au1000/common/setup.c b/arch/mips/au1000/common/setup.c
index b212c07..a90d425 100644
--- a/arch/mips/au1000/common/setup.c
+++ b/arch/mips/au1000/common/setup.c
@@ -40,10 +40,11 @@
 #include <asm/mipsregs.h>
 #include <asm/reboot.h>
 #include <asm/pgtable.h>
-#include <asm/mach-au1x00/au1000.h>
 #include <asm/time.h>
 
-extern char * prom_getcmdline(void);
+#include <au1000.h>
+#include <prom.h>
+
 extern void __init board_setup(void);
 extern void au1000_restart(char *);
 extern void au1000_halt(void);
diff --git a/arch/mips/au1000/db1x00/init.c b/arch/mips/au1000/db1x00/init.c
index 4d7bcfc..43298fd 100644
--- a/arch/mips/au1000/db1x00/init.c
+++ b/arch/mips/au1000/db1x00/init.c
@@ -31,15 +31,13 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/bootmem.h>
-#include <asm/addrspace.h>
-#include <asm/bootinfo.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
 
-int prom_argc;
-char **prom_argv, **prom_envp;
-extern void  __init prom_init_cmdline(void);
-extern char *prom_getenv(char *envname);
+#include <asm/addrspace.h>
+#include <asm/bootinfo.h>
+
+#include <prom.h>
 
 const char *get_system_type(void)
 {
diff --git a/arch/mips/au1000/mtx-1/init.c b/arch/mips/au1000/mtx-1/init.c
index 2aa7b2e..cdeae32 100644
--- a/arch/mips/au1000/mtx-1/init.c
+++ b/arch/mips/au1000/mtx-1/init.c
@@ -34,13 +34,11 @@
 #include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/bootmem.h>
+
 #include <asm/addrspace.h>
 #include <asm/bootinfo.h>
 
-int prom_argc;
-char **prom_argv, **prom_envp;
-extern void  __init prom_init_cmdline(void);
-extern char *prom_getenv(char *envname);
+#include <prom.h>
 
 const char *get_system_type(void)
 {
diff --git a/arch/mips/au1000/pb1000/init.c b/arch/mips/au1000/pb1000/init.c
index 4535f72..ddccaf6 100644
--- a/arch/mips/au1000/pb1000/init.c
+++ b/arch/mips/au1000/pb1000/init.c
@@ -30,15 +30,13 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/bootmem.h>
-#include <asm/addrspace.h>
-#include <asm/bootinfo.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
 
-int prom_argc;
-char **prom_argv, **prom_envp;
-extern void  __init prom_init_cmdline(void);
-extern char *prom_getenv(char *envname);
+#include <asm/addrspace.h>
+#include <asm/bootinfo.h>
+
+#include <prom.h>
 
 const char *get_system_type(void)
 {
diff --git a/arch/mips/au1000/pb1100/init.c b/arch/mips/au1000/pb1100/init.c
index 7ba6852..c93fd39 100644
--- a/arch/mips/au1000/pb1100/init.c
+++ b/arch/mips/au1000/pb1100/init.c
@@ -31,15 +31,13 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/bootmem.h>
-#include <asm/addrspace.h>
-#include <asm/bootinfo.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
 
-int prom_argc;
-char **prom_argv, **prom_envp;
-extern void  __init prom_init_cmdline(void);
-extern char *prom_getenv(char *envname);
+#include <asm/addrspace.h>
+#include <asm/bootinfo.h>
+
+#include <prom.h>
 
 const char *get_system_type(void)
 {
diff --git a/arch/mips/au1000/pb1200/board_setup.c b/arch/mips/au1000/pb1200/board_setup.c
index 2122515..5dbc986 100644
--- a/arch/mips/au1000/pb1200/board_setup.c
+++ b/arch/mips/au1000/pb1200/board_setup.c
@@ -41,8 +41,10 @@
 #include <asm/mipsregs.h>
 #include <asm/reboot.h>
 #include <asm/pgtable.h>
-#include <asm/mach-au1x00/au1000.h>
-#include <asm/mach-au1x00/au1xxx_dbdma.h>
+
+#include <au1000.h>
+#include <au1xxx_dbdma.h>
+#include <prom.h>
 
 #ifdef CONFIG_MIPS_PB1200
 #include <asm/mach-pb1x00/pb1200.h>
diff --git a/arch/mips/au1000/pb1200/init.c b/arch/mips/au1000/pb1200/init.c
index 5a70029..c251570 100644
--- a/arch/mips/au1000/pb1200/init.c
+++ b/arch/mips/au1000/pb1200/init.c
@@ -31,15 +31,13 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/bootmem.h>
-#include <asm/addrspace.h>
-#include <asm/bootinfo.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
 
-int prom_argc;
-char **prom_argv, **prom_envp;
-extern void  __init prom_init_cmdline(void);
-extern char *prom_getenv(char *envname);
+#include <asm/addrspace.h>
+#include <asm/bootinfo.h>
+
+#include <prom.h>
 
 const char *get_system_type(void)
 {
diff --git a/arch/mips/au1000/pb1500/init.c b/arch/mips/au1000/pb1500/init.c
index e58a9d6..507d4b2 100644
--- a/arch/mips/au1000/pb1500/init.c
+++ b/arch/mips/au1000/pb1500/init.c
@@ -31,15 +31,13 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/bootmem.h>
-#include <asm/addrspace.h>
-#include <asm/bootinfo.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
 
-int prom_argc;
-char **prom_argv, **prom_envp;
-extern void  __init prom_init_cmdline(void);
-extern char *prom_getenv(char *envname);
+#include <asm/addrspace.h>
+#include <asm/bootinfo.h>
+
+#include <prom.h>
 
 const char *get_system_type(void)
 {
diff --git a/arch/mips/au1000/pb1550/init.c b/arch/mips/au1000/pb1550/init.c
index fad53bf..b03eee6 100644
--- a/arch/mips/au1000/pb1550/init.c
+++ b/arch/mips/au1000/pb1550/init.c
@@ -31,15 +31,13 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/bootmem.h>
-#include <asm/addrspace.h>
-#include <asm/bootinfo.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
 
-int prom_argc;
-char **prom_argv, **prom_envp;
-extern void  __init prom_init_cmdline(void);
-extern char *prom_getenv(char *envname);
+#include <asm/addrspace.h>
+#include <asm/bootinfo.h>
+
+#include <prom.h>
 
 const char *get_system_type(void)
 {
diff --git a/arch/mips/au1000/xxs1500/init.c b/arch/mips/au1000/xxs1500/init.c
index 9f839c3..6532939 100644
--- a/arch/mips/au1000/xxs1500/init.c
+++ b/arch/mips/au1000/xxs1500/init.c
@@ -30,15 +30,13 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/bootmem.h>
-#include <asm/addrspace.h>
-#include <asm/bootinfo.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
 
-int prom_argc;
-char **prom_argv, **prom_envp;
-extern void  __init prom_init_cmdline(void);
-extern char *prom_getenv(char *envname);
+#include <asm/addrspace.h>
+#include <asm/bootinfo.h>
+
+#include <prom.h>
 
 const char *get_system_type(void)
 {
diff --git a/arch/powerpc/platforms/cell/axon_msi.c b/arch/powerpc/platforms/cell/axon_msi.c
index 1245b2f..095988f 100644
--- a/arch/powerpc/platforms/cell/axon_msi.c
+++ b/arch/powerpc/platforms/cell/axon_msi.c
@@ -77,12 +77,7 @@ static void msic_dcr_write(struct axon_msic *msic, unsigned int dcr_n, u32 val)
 {
 	pr_debug("axon_msi: dcr_write(0x%x, 0x%x)\n", val, dcr_n);
 
-	dcr_write(msic->dcr_host, msic->dcr_host.base + dcr_n, val);
-}
-
-static u32 msic_dcr_read(struct axon_msic *msic, unsigned int dcr_n)
-{
-	return dcr_read(msic->dcr_host, msic->dcr_host.base + dcr_n);
+	dcr_write(msic->dcr_host, dcr_n, val);
 }
 
 static void axon_msi_cascade(unsigned int irq, struct irq_desc *desc)
@@ -91,7 +86,7 @@ static void axon_msi_cascade(unsigned int irq, struct irq_desc *desc)
 	u32 write_offset, msi;
 	int idx;
 
-	write_offset = msic_dcr_read(msic, MSIC_WRITE_OFFSET_REG);
+	write_offset = dcr_read(msic->dcr_host, MSIC_WRITE_OFFSET_REG);
 	pr_debug("axon_msi: original write_offset 0x%x\n", write_offset);
 
 	/* write_offset doesn't wrap properly, so we have to mask it */
@@ -306,7 +301,7 @@ static int axon_msi_notify_reboot(struct notifier_block *nb,
 	list_for_each_entry(msic, &axon_msic_list, list) {
 		pr_debug("axon_msi: disabling %s\n",
 			  msic->irq_host->of_node->full_name);
-		tmp  = msic_dcr_read(msic, MSIC_CTRL_REG);
+		tmp  = dcr_read(msic->dcr_host, MSIC_CTRL_REG);
 		tmp &= ~MSIC_CTRL_ENABLE & ~MSIC_CTRL_IRQ_ENABLE;
 		msic_dcr_write(msic, MSIC_CTRL_REG, tmp);
 	}
diff --git a/arch/powerpc/sysdev/dcr.c b/arch/powerpc/sysdev/dcr.c
index ab11c0b..427027c 100644
--- a/arch/powerpc/sysdev/dcr.c
+++ b/arch/powerpc/sysdev/dcr.c
@@ -126,13 +126,13 @@ dcr_host_t dcr_map(struct device_node *dev, unsigned int dcr_n,
 }
 EXPORT_SYMBOL_GPL(dcr_map);
 
-void dcr_unmap(dcr_host_t host, unsigned int dcr_n, unsigned int dcr_c)
+void dcr_unmap(dcr_host_t host, unsigned int dcr_c)
 {
 	dcr_host_t h = host;
 
 	if (h.token == NULL)
 		return;
-	h.token += dcr_n * h.stride;
+	h.token += host.base * h.stride;
 	iounmap(h.token);
 	h.token = NULL;
 }
diff --git a/arch/powerpc/sysdev/mpic.c b/arch/powerpc/sysdev/mpic.c
index 893e654..e479388 100644
--- a/arch/powerpc/sysdev/mpic.c
+++ b/arch/powerpc/sysdev/mpic.c
@@ -156,7 +156,7 @@ static inline u32 _mpic_read(enum mpic_reg_type type,
 	switch(type) {
 #ifdef CONFIG_PPC_DCR
 	case mpic_access_dcr:
-		return dcr_read(rb->dhost, rb->dhost.base + reg);
+		return dcr_read(rb->dhost, reg);
 #endif
 	case mpic_access_mmio_be:
 		return in_be32(rb->base + (reg >> 2));
@@ -173,7 +173,7 @@ static inline void _mpic_write(enum mpic_reg_type type,
 	switch(type) {
 #ifdef CONFIG_PPC_DCR
 	case mpic_access_dcr:
-		return dcr_write(rb->dhost, rb->dhost.base + reg, value);
+		return dcr_write(rb->dhost, reg, value);
 #endif
 	case mpic_access_mmio_be:
 		return out_be32(rb->base + (reg >> 2), value);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index 6545fa7..1b3327a 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -349,6 +349,7 @@ struct ipoib_neigh {
 	struct sk_buff_head queue;
 
 	struct neighbour   *neighbour;
+	struct net_device *dev;
 
 	struct list_head    list;
 };
@@ -365,7 +366,8 @@ static inline struct ipoib_neigh **to_ipoib_neigh(struct neighbour *neigh)
 				     INFINIBAND_ALEN, sizeof(void *));
 }
 
-struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neigh);
+struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neigh,
+				      struct net_device *dev);
 void ipoib_neigh_free(struct net_device *dev, struct ipoib_neigh *neigh);
 
 extern struct workqueue_struct *ipoib_workqueue;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index e072f3c..362610d 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -517,7 +517,7 @@ static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 	struct ipoib_path *path;
 	struct ipoib_neigh *neigh;
 
-	neigh = ipoib_neigh_alloc(skb->dst->neighbour);
+	neigh = ipoib_neigh_alloc(skb->dst->neighbour, skb->dev);
 	if (!neigh) {
 		++dev->stats.tx_dropped;
 		dev_kfree_skb_any(skb);
@@ -692,9 +692,10 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				goto out;
 			}
 		} else if (neigh->ah) {
-			if (unlikely(memcmp(&neigh->dgid.raw,
+			if (unlikely((memcmp(&neigh->dgid.raw,
 					    skb->dst->neighbour->ha + 4,
-					    sizeof(union ib_gid)))) {
+					    sizeof(union ib_gid))) ||
+					 (neigh->dev != dev))) {
 				spin_lock(&priv->lock);
 				/*
 				 * It's safe to call ipoib_put_ah() inside
@@ -817,6 +818,13 @@ static void ipoib_neigh_cleanup(struct neighbour *n)
 	unsigned long flags;
 	struct ipoib_ah *ah = NULL;
 
+	neigh = *to_ipoib_neigh(n);
+	if (neigh) {
+		priv = netdev_priv(neigh->dev);
+		ipoib_dbg(priv, "neigh_destructor for bonding device: %s\n",
+			  n->dev->name);
+	} else
+		return;
 	ipoib_dbg(priv,
 		  "neigh_cleanup for %06x " IPOIB_GID_FMT "\n",
 		  IPOIB_QPN(n->ha),
@@ -824,13 +832,10 @@ static void ipoib_neigh_cleanup(struct neighbour *n)
 
 	spin_lock_irqsave(&priv->lock, flags);
 
-	neigh = *to_ipoib_neigh(n);
-	if (neigh) {
-		if (neigh->ah)
-			ah = neigh->ah;
-		list_del(&neigh->list);
-		ipoib_neigh_free(n->dev, neigh);
-	}
+	if (neigh->ah)
+		ah = neigh->ah;
+	list_del(&neigh->list);
+	ipoib_neigh_free(n->dev, neigh);
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -838,7 +843,8 @@ static void ipoib_neigh_cleanup(struct neighbour *n)
 		ipoib_put_ah(ah);
 }
 
-struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour)
+struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour,
+				      struct net_device *dev)
 {
 	struct ipoib_neigh *neigh;
 
@@ -847,6 +853,7 @@ struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour)
 		return NULL;
 
 	neigh->neighbour = neighbour;
+	neigh->dev = dev;
 	*to_ipoib_neigh(neighbour) = neigh;
 	skb_queue_head_init(&neigh->queue);
 	ipoib_cm_set(neigh, NULL);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 827820e..9bcfc7a 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -705,7 +705,8 @@ out:
 		if (skb->dst            &&
 		    skb->dst->neighbour &&
 		    !*to_ipoib_neigh(skb->dst->neighbour)) {
-			struct ipoib_neigh *neigh = ipoib_neigh_alloc(skb->dst->neighbour);
+			struct ipoib_neigh *neigh = ipoib_neigh_alloc(skb->dst->neighbour,
+									skb->dev);
 
 			if (neigh) {
 				kref_get(&mcast->ah->ref);
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9c635a2..8f99a06 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1780,6 +1780,15 @@ config SC92031
 	  To compile this driver as a module, choose M here: the module
 	  will be called sc92031.  This is recommended.
 
+config CPMAC
+	tristate "TI AR7 CPMAC Ethernet support (EXPERIMENTAL)"
+	depends on NET_ETHERNET && EXPERIMENTAL && AR7
+	select PHYLIB
+	select FIXED_PHY
+	select FIXED_MII_100_FDX
+	help
+	  TI AR7 CPMAC Ethernet support
+
 config NET_POCKET
 	bool "Pocket and portable adapters"
 	depends on PARPORT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d2e0f35..22f78cb 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -159,6 +159,7 @@ obj-$(CONFIG_8139CP) += 8139cp.o
 obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_ZNET) += znet.o
 obj-$(CONFIG_LAN_SAA9730) += saa9730.o
+obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_DEPCA) += depca.o
 obj-$(CONFIG_EWRK3) += ewrk3.o
 obj-$(CONFIG_ATP) += atp.o
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index b46c5d8..185f98e 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -54,13 +54,16 @@
 #include <linux/delay.h>
 #include <linux/crc32.h>
 #include <linux/phy.h>
+
+#include <asm/cpu.h>
 #include <asm/mipsregs.h>
 #include <asm/irq.h>
 #include <asm/io.h>
 #include <asm/processor.h>
 
-#include <asm/mach-au1x00/au1000.h>
-#include <asm/cpu.h>
+#include <au1000.h>
+#include <prom.h>
+
 #include "au1000_eth.h"
 
 #ifdef AU1000_ETH_DEBUG
@@ -96,11 +99,6 @@ static void mdio_write(struct net_device *, int, int, u16);
 static void au1000_adjust_link(struct net_device *);
 static void enable_mac(struct net_device *, int);
 
-// externs
-extern int get_ethernet_addr(char *ethernet_addr);
-extern void str2eaddr(unsigned char *ea, unsigned char *str);
-extern char * prom_getcmdline(void);
-
 /*
  * Theory of operation
  *
@@ -619,7 +617,6 @@ static struct net_device * au1000_probe(int port_num)
 	struct au1000_private *aup = NULL;
 	struct net_device *dev = NULL;
 	db_dest_t *pDB, *pDBfree;
-	char *pmac, *argptr;
 	char ethaddr[6];
 	int irq, i, err;
 	u32 base, macen;
@@ -677,21 +674,12 @@ static struct net_device * au1000_probe(int port_num)
 	au_macs[port_num] = aup;
 
 	if (port_num == 0) {
-		/* Check the environment variables first */
-		if (get_ethernet_addr(ethaddr) == 0)
+		if (prom_get_ethernet_addr(ethaddr) == 0)
 			memcpy(au1000_mac_addr, ethaddr, sizeof(au1000_mac_addr));
 		else {
-			/* Check command line */
-			argptr = prom_getcmdline();
-			if ((pmac = strstr(argptr, "ethaddr=")) == NULL)
-				printk(KERN_INFO "%s: No MAC address found\n",
-						 dev->name);
+			printk(KERN_INFO "%s: No MAC address found\n",
+					 dev->name);
 				/* Use the hard coded MAC addresses */
-			else {
-				str2eaddr(ethaddr, pmac + strlen("ethaddr="));
-				memcpy(au1000_mac_addr, ethaddr,
-				       sizeof(au1000_mac_addr));
-			}
 		}
 
 		setup_hw_rings(aup, MAC0_RX_DMA_ADDR, MAC0_TX_DMA_ADDR);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 64bfec3..db80f24 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -98,6 +98,7 @@ static char *xmit_hash_policy = NULL;
 static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
 static char *arp_validate = NULL;
+static int fail_over_mac = 0;
 struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
@@ -131,6 +132,8 @@ module_param_array(arp_ip_target, charp, NULL, 0);
 MODULE_PARM_DESC(arp_ip_target, "arp targets in n.n.n.n form");
 module_param(arp_validate, charp, 0);
 MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes: none (default), active, backup or all");
+module_param(fail_over_mac, int, 0);
+MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to the same MAC.  0 of off (default), 1 for on.");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -1096,7 +1099,21 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 		if (new_active) {
 			bond_set_slave_active_flags(new_active);
 		}
-		bond_send_gratuitous_arp(bond);
+
+		/* when bonding does not set the slave MAC address, the bond MAC
+		 * address is the one of the active slave.
+		 */
+		if (new_active && bond->params.fail_over_mac)
+			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
+				new_active->dev->addr_len);
+		if (bond->curr_active_slave &&
+			test_bit(__LINK_STATE_LINKWATCH_PENDING,
+					&bond->curr_active_slave->dev->state)) {
+			dprintk("delaying gratuitous arp on %s\n",
+				bond->curr_active_slave->dev->name);
+			bond->send_grat_arp = 1;
+		} else
+			bond_send_gratuitous_arp(bond);
 	}
 }
 
@@ -1217,7 +1234,8 @@ static int bond_compute_features(struct bonding *bond)
 	struct slave *slave;
 	struct net_device *bond_dev = bond->dev;
 	unsigned long features = bond_dev->features;
-	unsigned short max_hard_header_len = ETH_HLEN;
+	unsigned short max_hard_header_len = max((u16)ETH_HLEN,
+						bond_dev->hard_header_len);
 	int i;
 
 	features &= ~(NETIF_F_ALL_CSUM | BOND_VLAN_FEATURES);
@@ -1238,6 +1256,23 @@ static int bond_compute_features(struct bonding *bond)
 	return 0;
 }
 
+
+static void bond_setup_by_slave(struct net_device *bond_dev,
+				struct net_device *slave_dev)
+{
+	struct bonding *bond = bond_dev->priv;
+
+	bond_dev->neigh_setup           = slave_dev->neigh_setup;
+
+	bond_dev->type		    = slave_dev->type;
+	bond_dev->hard_header_len   = slave_dev->hard_header_len;
+	bond_dev->addr_len	    = slave_dev->addr_len;
+
+	memcpy(bond_dev->broadcast, slave_dev->broadcast,
+		slave_dev->addr_len);
+	bond->setup_by_slave = 1;
+}
+
 /* enslave device <slave> to bond device <master> */
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
@@ -1258,8 +1293,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	/* bond must be initialized by bond_open() before enslaving */
 	if (!(bond_dev->flags & IFF_UP)) {
-		dprintk("Error, master_dev is not up\n");
-		return -EPERM;
+		printk(KERN_WARNING DRV_NAME
+			" %s: master_dev is not up in bond_enslave\n",
+			bond_dev->name);
 	}
 
 	/* already enslaved */
@@ -1312,14 +1348,42 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_undo_flags;
 	}
 
+	/* set bonding device ether type by slave - bonding netdevices are
+	 * created with ether_setup, so when the slave type is not ARPHRD_ETHER
+	 * there is a need to override some of the type dependent attribs/funcs.
+	 *
+	 * bond ether type mutual exclusion - don't allow slaves of dissimilar
+	 * ether type (eg ARPHRD_ETHER and ARPHRD_INFINIBAND) share the same bond
+	 */
+	if (bond->slave_cnt == 0) {
+		if (slave_dev->type != ARPHRD_ETHER)
+			bond_setup_by_slave(bond_dev, slave_dev);
+	} else if (bond_dev->type != slave_dev->type) {
+		printk(KERN_ERR DRV_NAME ": %s ether type (%d) is different "
+			"from other slaves (%d), can not enslave it.\n",
+			slave_dev->name,
+			slave_dev->type, bond_dev->type);
+			res = -EINVAL;
+			goto err_undo_flags;
+	}
+
 	if (slave_dev->set_mac_address == NULL) {
-		printk(KERN_ERR DRV_NAME
-			": %s: Error: The slave device you specified does "
-			"not support setting the MAC address. "
-			"Your kernel likely does not support slave "
-			"devices.\n", bond_dev->name);
-  		res = -EOPNOTSUPP;
-		goto err_undo_flags;
+		if (bond->slave_cnt == 0) {
+			printk(KERN_WARNING DRV_NAME
+			       ": %s: Warning: The first slave device "
+			       "specified does not support setting the MAC "
+			       "address. Enabling the fail_over_mac option.",
+			       bond_dev->name);
+			bond->params.fail_over_mac = 1;
+		} else if (!bond->params.fail_over_mac) {
+			printk(KERN_ERR DRV_NAME
+				": %s: Error: The slave device specified "
+				"does not support setting the MAC address, "
+				"but fail_over_mac is not enabled.\n"
+				, bond_dev->name);
+			res = -EOPNOTSUPP;
+			goto err_undo_flags;
+		}
 	}
 
 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
@@ -1340,16 +1404,18 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 */
 	memcpy(new_slave->perm_hwaddr, slave_dev->dev_addr, ETH_ALEN);
 
-	/*
-	 * Set slave to master's mac address.  The application already
-	 * set the master's mac address to that of the first slave
-	 */
-	memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
-	addr.sa_family = slave_dev->type;
-	res = dev_set_mac_address(slave_dev, &addr);
-	if (res) {
-		dprintk("Error %d calling set_mac_address\n", res);
-		goto err_free;
+	if (!bond->params.fail_over_mac) {
+		/*
+		 * Set slave to master's mac address.  The application already
+		 * set the master's mac address to that of the first slave
+		 */
+		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
+		addr.sa_family = slave_dev->type;
+		res = dev_set_mac_address(slave_dev, &addr);
+		if (res) {
+			dprintk("Error %d calling set_mac_address\n", res);
+			goto err_free;
+		}
 	}
 
 	res = netdev_set_master(slave_dev, bond_dev);
@@ -1574,9 +1640,11 @@ err_close:
 	dev_close(slave_dev);
 
 err_restore_mac:
-	memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
-	addr.sa_family = slave_dev->type;
-	dev_set_mac_address(slave_dev, &addr);
+	if (!bond->params.fail_over_mac) {
+		memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
+		addr.sa_family = slave_dev->type;
+		dev_set_mac_address(slave_dev, &addr);
+	}
 
 err_free:
 	kfree(new_slave);
@@ -1749,10 +1817,12 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* close slave before restoring its mac address */
 	dev_close(slave_dev);
 
-	/* restore original ("permanent") mac address */
-	memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
-	addr.sa_family = slave_dev->type;
-	dev_set_mac_address(slave_dev, &addr);
+	if (!bond->params.fail_over_mac) {
+		/* restore original ("permanent") mac address */
+		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
+		addr.sa_family = slave_dev->type;
+		dev_set_mac_address(slave_dev, &addr);
+	}
 
 	slave_dev->priv_flags &= ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
 				   IFF_SLAVE_INACTIVE | IFF_BONDING |
@@ -1764,6 +1834,35 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 }
 
 /*
+* Destroy a bonding device.
+* Must be under rtnl_lock when this function is called.
+*/
+void bond_destroy(struct bonding *bond)
+{
+	bond_deinit(bond->dev);
+	bond_destroy_sysfs_entry(bond);
+	unregister_netdevice(bond->dev);
+}
+
+/*
+* First release a slave and than destroy the bond if no more slaves iare left.
+* Must be under rtnl_lock when this function is called.
+*/
+int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev)
+{
+	struct bonding *bond = bond_dev->priv;
+	int ret;
+
+	ret = bond_release(bond_dev, slave_dev);
+	if ((ret == 0) && (bond->slave_cnt == 0)) {
+		printk(KERN_INFO DRV_NAME ": %s: destroying bond %s.\n",
+		       bond_dev->name, bond_dev->name);
+		bond_destroy(bond);
+	}
+	return ret;
+}
+
+/*
  * This function releases all slaves.
  */
 static int bond_release_all(struct net_device *bond_dev)
@@ -1839,10 +1938,12 @@ static int bond_release_all(struct net_device *bond_dev)
 		/* close slave before restoring its mac address */
 		dev_close(slave_dev);
 
-		/* restore original ("permanent") mac address*/
-		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
-		addr.sa_family = slave_dev->type;
-		dev_set_mac_address(slave_dev, &addr);
+		if (!bond->params.fail_over_mac) {
+			/* restore original ("permanent") mac address*/
+			memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
+			addr.sa_family = slave_dev->type;
+			dev_set_mac_address(slave_dev, &addr);
+		}
 
 		slave_dev->priv_flags &= ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
 					   IFF_SLAVE_INACTIVE);
@@ -2013,6 +2114,17 @@ void bond_mii_monitor(struct net_device *bond_dev)
 	 * program could monitor the link itself if needed.
 	 */
 
+	if (bond->send_grat_arp) {
+		if (bond->curr_active_slave && test_bit(__LINK_STATE_LINKWATCH_PENDING,
+				&bond->curr_active_slave->dev->state))
+			dprintk("Needs to send gratuitous arp but not yet\n");
+		else {
+			dprintk("sending delayed gratuitous arp on on %s\n",
+				bond->curr_active_slave->dev->name);
+			bond_send_gratuitous_arp(bond);
+			bond->send_grat_arp = 0;
+		}
+	}
 	read_lock(&bond->curr_slave_lock);
 	oldcurrent = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
@@ -2414,7 +2526,7 @@ static void bond_send_gratuitous_arp(struct bonding *bond)
 
 	if (bond->master_ip) {
 		bond_arp_send(slave->dev, ARPOP_REPLY, bond->master_ip,
-				  bond->master_ip, 0);
+				bond->master_ip, 0);
 	}
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
@@ -2951,9 +3063,15 @@ static void bond_info_show_master(struct seq_file *seq)
 	curr = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
 
-	seq_printf(seq, "Bonding Mode: %s\n",
+	seq_printf(seq, "Bonding Mode: %s",
 		   bond_mode_name(bond->params.mode));
 
+	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP &&
+	    bond->params.fail_over_mac)
+		seq_printf(seq, " (fail_over_mac)");
+
+	seq_printf(seq, "\n");
+
 	if (bond->params.mode == BOND_MODE_XOR ||
 		bond->params.mode == BOND_MODE_8023AD) {
 		seq_printf(seq, "Transmit Hash Policy: %s (%d)\n",
@@ -3248,6 +3366,11 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
 		 * ... Or is it this?
 		 */
 		break;
+	case NETDEV_GOING_DOWN:
+		dprintk("slave %s is going down\n", slave_dev->name);
+		if (bond->setup_by_slave)
+			bond_release_and_destroy(bond_dev, slave_dev);
+		break;
 	case NETDEV_CHANGEMTU:
 		/*
 		 * TODO: Should slaves be allowed to
@@ -3880,6 +4003,13 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 
 	dprintk("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
 
+	/*
+	 * If fail_over_mac is enabled, do nothing and return success.
+	 * Returning an error causes ifenslave to fail.
+	 */
+	if (bond->params.fail_over_mac)
+		return 0;
+
 	if (!is_valid_ether_addr(sa->sa_data)) {
 		return -EADDRNOTAVAIL;
 	}
@@ -4217,6 +4347,8 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	bond->current_arp_slave = NULL;
 	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
+	bond->send_grat_arp = 0;
+	bond->setup_by_slave = 0;
 	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
@@ -4265,7 +4397,6 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 #ifdef CONFIG_PROC_FS
 	bond_create_proc_entry(bond);
 #endif
-
 	list_add_tail(&bond->bond_list, &bond_dev_list);
 
 	return 0;
@@ -4599,6 +4730,11 @@ static int bond_check_params(struct bond_params *params)
 		primary = NULL;
 	}
 
+	if (fail_over_mac && (bond_mode != BOND_MODE_ACTIVEBACKUP))
+		printk(KERN_WARNING DRV_NAME
+		       ": Warning: fail_over_mac only affects "
+		       "active-backup mode.\n");
+
 	/* fill params struct with the proper values */
 	params->mode = bond_mode;
 	params->xmit_policy = xmit_hashtype;
@@ -4610,6 +4746,7 @@ static int bond_check_params(struct bond_params *params)
 	params->use_carrier = use_carrier;
 	params->lacp_fast = lacp_fast;
 	params->primary[0] = 0;
+	params->fail_over_mac = fail_over_mac;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 6f49ca7..80c0c8c 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -164,9 +164,7 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 				printk(KERN_INFO DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
-				bond_deinit(bond->dev);
-		        	bond_destroy_sysfs_entry(bond);
-				unregister_netdevice(bond->dev);
+				bond_destroy(bond);
 				rtnl_unlock();
 				goto out;
 			}
@@ -260,17 +258,16 @@ static ssize_t bonding_store_slaves(struct device *d,
 	char command[IFNAMSIZ + 1] = { 0, };
 	char *ifname;
 	int i, res, found, ret = count;
+	u32 original_mtu;
 	struct slave *slave;
 	struct net_device *dev = NULL;
 	struct bonding *bond = to_bond(d);
 
 	/* Quick sanity check -- is the bond interface up? */
 	if (!(bond->dev->flags & IFF_UP)) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: Unable to update slaves because interface is down.\n",
+		printk(KERN_WARNING DRV_NAME
+		       ": %s: doing slave updates when interface is down.\n",
 		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
 	}
 
 	/* Note:  We can't hold bond->lock here, as bond_create grabs it. */
@@ -327,6 +324,7 @@ static ssize_t bonding_store_slaves(struct device *d,
 		}
 
 		/* Set the slave's MTU to match the bond */
+		original_mtu = dev->mtu;
 		if (dev->mtu != bond->dev->mtu) {
 			if (dev->change_mtu) {
 				res = dev->change_mtu(dev,
@@ -341,6 +339,9 @@ static ssize_t bonding_store_slaves(struct device *d,
 		}
 		rtnl_lock();
 		res = bond_enslave(bond->dev, dev);
+		bond_for_each_slave(bond, slave, i)
+			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0)
+				slave->original_mtu = original_mtu;
 		rtnl_unlock();
 		if (res) {
 			ret = res;
@@ -353,13 +354,17 @@ static ssize_t bonding_store_slaves(struct device *d,
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 				dev = slave->dev;
+				original_mtu = slave->original_mtu;
 				break;
 			}
 		if (dev) {
 			printk(KERN_INFO DRV_NAME ": %s: Removing slave %s\n",
 				bond->dev->name, dev->name);
 			rtnl_lock();
-			res = bond_release(bond->dev, dev);
+			if (bond->setup_by_slave)
+				res = bond_release_and_destroy(bond->dev, dev);
+			else
+				res = bond_release(bond->dev, dev);
 			rtnl_unlock();
 			if (res) {
 				ret = res;
@@ -367,9 +372,9 @@ static ssize_t bonding_store_slaves(struct device *d,
 			}
 			/* set the slave MTU to the default */
 			if (dev->change_mtu) {
-				dev->change_mtu(dev, 1500);
+				dev->change_mtu(dev, original_mtu);
 			} else {
-				dev->mtu = 1500;
+				dev->mtu = original_mtu;
 			}
 		}
 		else {
@@ -563,6 +568,54 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 static DEVICE_ATTR(arp_validate, S_IRUGO | S_IWUSR, bonding_show_arp_validate, bonding_store_arp_validate);
 
 /*
+ * Show and store fail_over_mac.  User only allowed to change the
+ * value when there are no slaves.
+ */
+static ssize_t bonding_show_fail_over_mac(struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.fail_over_mac) + 1;
+}
+
+static ssize_t bonding_store_fail_over_mac(struct device *d, struct device_attribute *attr, const char *buf, size_t count)
+{
+	int new_value;
+	int ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (bond->slave_cnt != 0) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Can't alter fail_over_mac with slaves in bond.\n",
+		       bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: no fail_over_mac value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if ((new_value == 0) || (new_value == 1)) {
+		bond->params.fail_over_mac = new_value;
+		printk(KERN_INFO DRV_NAME ": %s: Setting fail_over_mac to %d.\n",
+		       bond->dev->name, new_value);
+	} else {
+		printk(KERN_INFO DRV_NAME
+		       ": %s: Ignoring invalid fail_over_mac value %d.\n",
+		       bond->dev->name, new_value);
+	}
+out:
+	return ret;
+}
+
+static DEVICE_ATTR(fail_over_mac, S_IRUGO | S_IWUSR, bonding_show_fail_over_mac, bonding_store_fail_over_mac);
+
+/*
  * Show and set the arp timer interval.  There are two tricky bits
  * here.  First, if ARP monitoring is activated, then we must disable
  * MII monitoring.  Second, if the ARP timer isn't running, we must
@@ -1383,6 +1436,7 @@ static DEVICE_ATTR(ad_partner_mac, S_IRUGO, bonding_show_ad_partner_mac, NULL);
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
+	&dev_attr_fail_over_mac.attr,
 	&dev_attr_arp_validate.attr,
 	&dev_attr_arp_interval.attr,
 	&dev_attr_arp_ip_target.attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2a6af7d..a8bbd56 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.1.3"
-#define DRV_RELDATE	"June 13, 2007"
+#define DRV_VERSION	"3.2.0"
+#define DRV_RELDATE	"September 13, 2007"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
@@ -128,6 +128,7 @@ struct bond_params {
 	int arp_interval;
 	int arp_validate;
 	int use_carrier;
+	int fail_over_mac;
 	int updelay;
 	int downdelay;
 	int lacp_fast;
@@ -156,6 +157,7 @@ struct slave {
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     state;   /* one of BOND_STATE_XXXX */
 	u32    original_flags;
+	u32    original_mtu;
 	u32    link_failure_count;
 	u16    speed;
 	u8     duplex;
@@ -185,6 +187,8 @@ struct bonding {
 	struct   timer_list mii_timer;
 	struct   timer_list arp_timer;
 	s8       kill_timers;
+	s8	 send_grat_arp;
+	s8	 setup_by_slave;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;
@@ -292,6 +296,8 @@ static inline void bond_unset_master_alb_flags(struct bonding *bond)
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
+void bond_destroy(struct bonding *bond);
+int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 void bond_deinit(struct net_device *bond_dev);
 int bond_create_sysfs(void);
 void bond_destroy_sysfs(void);
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 563bf5f..7df31b5 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4443,7 +4443,7 @@ static struct {
 	{REG_MAC_COLL_EXCESS},
 	{REG_MAC_COLL_LATE}
 };
-#define CAS_REG_LEN 	(sizeof(ethtool_register_table)/sizeof(int))
+#define CAS_REG_LEN 	ARRAY_SIZE(ethtool_register_table)
 #define CAS_MAX_REGS 	(sizeof (u32)*CAS_REG_LEN)
 
 static void cas_read_regs(struct cas *cp, u8 *ptr, int len)
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
new file mode 100644
index 0000000..ed53aaa
--- /dev/null
+++ b/drivers/net/cpmac.c
@@ -0,0 +1,1174 @@
+/*
+ * Copyright (C) 2006, 2007 Eugene Konev
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/moduleparam.h>
+
+#include <linux/sched.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/delay.h>
+#include <linux/version.h>
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/skbuff.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/dma-mapping.h>
+#include <asm/gpio.h>
+
+MODULE_AUTHOR("Eugene Konev <ejka@imfi.kspu.ru>");
+MODULE_DESCRIPTION("TI AR7 ethernet driver (CPMAC)");
+MODULE_LICENSE("GPL");
+
+static int debug_level = 8;
+static int dumb_switch;
+
+/* Next 2 are only used in cpmac_probe, so it's pointless to change them */
+module_param(debug_level, int, 0444);
+module_param(dumb_switch, int, 0444);
+
+MODULE_PARM_DESC(debug_level, "Number of NETIF_MSG bits to enable");
+MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
+
+#define CPMAC_VERSION "0.5.0"
+/* stolen from net/ieee80211.h */
+#ifndef MAC_FMT
+#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
+#define MAC_ARG(x) ((u8*)(x))[0], ((u8*)(x))[1], ((u8*)(x))[2], \
+		   ((u8*)(x))[3], ((u8*)(x))[4], ((u8*)(x))[5]
+#endif
+/* frame size + 802.1q tag */
+#define CPMAC_SKB_SIZE		(ETH_FRAME_LEN + 4)
+#define CPMAC_QUEUES	8
+
+/* Ethernet registers */
+#define CPMAC_TX_CONTROL		0x0004
+#define CPMAC_TX_TEARDOWN		0x0008
+#define CPMAC_RX_CONTROL		0x0014
+#define CPMAC_RX_TEARDOWN		0x0018
+#define CPMAC_MBP			0x0100
+# define MBP_RXPASSCRC			0x40000000
+# define MBP_RXQOS			0x20000000
+# define MBP_RXNOCHAIN			0x10000000
+# define MBP_RXCMF			0x01000000
+# define MBP_RXSHORT			0x00800000
+# define MBP_RXCEF			0x00400000
+# define MBP_RXPROMISC			0x00200000
+# define MBP_PROMISCCHAN(channel)	(((channel) & 0x7) << 16)
+# define MBP_RXBCAST			0x00002000
+# define MBP_BCASTCHAN(channel)		(((channel) & 0x7) << 8)
+# define MBP_RXMCAST			0x00000020
+# define MBP_MCASTCHAN(channel)		((channel) & 0x7)
+#define CPMAC_UNICAST_ENABLE		0x0104
+#define CPMAC_UNICAST_CLEAR		0x0108
+#define CPMAC_MAX_LENGTH		0x010c
+#define CPMAC_BUFFER_OFFSET		0x0110
+#define CPMAC_MAC_CONTROL		0x0160
+# define MAC_TXPTYPE			0x00000200
+# define MAC_TXPACE			0x00000040
+# define MAC_MII			0x00000020
+# define MAC_TXFLOW			0x00000010
+# define MAC_RXFLOW			0x00000008
+# define MAC_MTEST			0x00000004
+# define MAC_LOOPBACK			0x00000002
+# define MAC_FDX			0x00000001
+#define CPMAC_MAC_STATUS		0x0164
+# define MAC_STATUS_QOS			0x00000004
+# define MAC_STATUS_RXFLOW		0x00000002
+# define MAC_STATUS_TXFLOW		0x00000001
+#define CPMAC_TX_INT_ENABLE		0x0178
+#define CPMAC_TX_INT_CLEAR		0x017c
+#define CPMAC_MAC_INT_VECTOR		0x0180
+# define MAC_INT_STATUS			0x00080000
+# define MAC_INT_HOST			0x00040000
+# define MAC_INT_RX			0x00020000
+# define MAC_INT_TX			0x00010000
+#define CPMAC_MAC_EOI_VECTOR		0x0184
+#define CPMAC_RX_INT_ENABLE		0x0198
+#define CPMAC_RX_INT_CLEAR		0x019c
+#define CPMAC_MAC_INT_ENABLE		0x01a8
+#define CPMAC_MAC_INT_CLEAR		0x01ac
+#define CPMAC_MAC_ADDR_LO(channel) 	(0x01b0 + (channel) * 4)
+#define CPMAC_MAC_ADDR_MID		0x01d0
+#define CPMAC_MAC_ADDR_HI		0x01d4
+#define CPMAC_MAC_HASH_LO		0x01d8
+#define CPMAC_MAC_HASH_HI		0x01dc
+#define CPMAC_TX_PTR(channel)		(0x0600 + (channel) * 4)
+#define CPMAC_RX_PTR(channel)		(0x0620 + (channel) * 4)
+#define CPMAC_TX_ACK(channel)		(0x0640 + (channel) * 4)
+#define CPMAC_RX_ACK(channel)		(0x0660 + (channel) * 4)
+#define CPMAC_REG_END			0x0680
+/*
+ * Rx/Tx statistics
+ * TODO: use some of them to fill stats in cpmac_stats()
+ */
+#define CPMAC_STATS_RX_GOOD		0x0200
+#define CPMAC_STATS_RX_BCAST		0x0204
+#define CPMAC_STATS_RX_MCAST		0x0208
+#define CPMAC_STATS_RX_PAUSE		0x020c
+#define CPMAC_STATS_RX_CRC		0x0210
+#define CPMAC_STATS_RX_ALIGN		0x0214
+#define CPMAC_STATS_RX_OVER		0x0218
+#define CPMAC_STATS_RX_JABBER		0x021c
+#define CPMAC_STATS_RX_UNDER		0x0220
+#define CPMAC_STATS_RX_FRAG		0x0224
+#define CPMAC_STATS_RX_FILTER		0x0228
+#define CPMAC_STATS_RX_QOSFILTER	0x022c
+#define CPMAC_STATS_RX_OCTETS		0x0230
+
+#define CPMAC_STATS_TX_GOOD		0x0234
+#define CPMAC_STATS_TX_BCAST		0x0238
+#define CPMAC_STATS_TX_MCAST		0x023c
+#define CPMAC_STATS_TX_PAUSE		0x0240
+#define CPMAC_STATS_TX_DEFER		0x0244
+#define CPMAC_STATS_TX_COLLISION	0x0248
+#define CPMAC_STATS_TX_SINGLECOLL	0x024c
+#define CPMAC_STATS_TX_MULTICOLL	0x0250
+#define CPMAC_STATS_TX_EXCESSCOLL	0x0254
+#define CPMAC_STATS_TX_LATECOLL		0x0258
+#define CPMAC_STATS_TX_UNDERRUN		0x025c
+#define CPMAC_STATS_TX_CARRIERSENSE	0x0260
+#define CPMAC_STATS_TX_OCTETS		0x0264
+
+#define cpmac_read(base, reg)		(readl((void __iomem *)(base) + (reg)))
+#define cpmac_write(base, reg, val)	(writel(val, (void __iomem *)(base) + \
+						(reg)))
+
+/* MDIO bus */
+#define CPMAC_MDIO_VERSION		0x0000
+#define CPMAC_MDIO_CONTROL		0x0004
+# define MDIOC_IDLE			0x80000000
+# define MDIOC_ENABLE			0x40000000
+# define MDIOC_PREAMBLE			0x00100000
+# define MDIOC_FAULT			0x00080000
+# define MDIOC_FAULTDETECT		0x00040000
+# define MDIOC_INTTEST			0x00020000
+# define MDIOC_CLKDIV(div)		((div) & 0xff)
+#define CPMAC_MDIO_ALIVE		0x0008
+#define CPMAC_MDIO_LINK			0x000c
+#define CPMAC_MDIO_ACCESS(channel)	(0x0080 + (channel) * 8)
+# define MDIO_BUSY			0x80000000
+# define MDIO_WRITE			0x40000000
+# define MDIO_REG(reg)			(((reg) & 0x1f) << 21)
+# define MDIO_PHY(phy)			(((phy) & 0x1f) << 16)
+# define MDIO_DATA(data)		((data) & 0xffff)
+#define CPMAC_MDIO_PHYSEL(channel)	(0x0084 + (channel) * 8)
+# define PHYSEL_LINKSEL			0x00000040
+# define PHYSEL_LINKINT			0x00000020
+
+struct cpmac_desc {
+	u32 hw_next;
+	u32 hw_data;
+	u16 buflen;
+	u16 bufflags;
+	u16 datalen;
+	u16 dataflags;
+#define CPMAC_SOP			0x8000
+#define CPMAC_EOP			0x4000
+#define CPMAC_OWN			0x2000
+#define CPMAC_EOQ			0x1000
+	struct sk_buff *skb;
+	struct cpmac_desc *next;
+	dma_addr_t mapping;
+	dma_addr_t data_mapping;
+};
+
+struct cpmac_priv {
+	spinlock_t lock;
+	spinlock_t rx_lock;
+	struct cpmac_desc *rx_head;
+	int ring_size;
+	struct cpmac_desc *desc_ring;
+	dma_addr_t dma_ring;
+	void __iomem *regs;
+	struct mii_bus *mii_bus;
+	struct phy_device *phy;
+	char phy_name[BUS_ID_SIZE];
+	int oldlink, oldspeed, oldduplex;
+	u32 msg_enable;
+	struct net_device *dev;
+	struct work_struct reset_work;
+	struct platform_device *pdev;
+};
+
+static irqreturn_t cpmac_irq(int, void *);
+static void cpmac_hw_start(struct net_device *dev);
+static void cpmac_hw_stop(struct net_device *dev);
+static int cpmac_stop(struct net_device *dev);
+static int cpmac_open(struct net_device *dev);
+
+static void cpmac_dump_regs(struct net_device *dev)
+{
+	int i;
+	struct cpmac_priv *priv = netdev_priv(dev);
+	for (i = 0; i < CPMAC_REG_END; i += 4) {
+		if (i % 16 == 0) {
+			if (i)
+				printk("\n");
+			printk(KERN_DEBUG "%s: reg[%p]:", dev->name,
+			       priv->regs + i);
+		}
+		printk(" %08x", cpmac_read(priv->regs, i));
+	}
+	printk("\n");
+}
+
+static void cpmac_dump_desc(struct net_device *dev, struct cpmac_desc *desc)
+{
+	int i;
+	printk(KERN_DEBUG "%s: desc[%p]:", dev->name, desc);
+	for (i = 0; i < sizeof(*desc) / 4; i++)
+		printk(" %08x", ((u32 *)desc)[i]);
+	printk("\n");
+}
+
+static void cpmac_dump_skb(struct net_device *dev, struct sk_buff *skb)
+{
+	int i;
+	printk(KERN_DEBUG "%s: skb 0x%p, len=%d\n", dev->name, skb, skb->len);
+	for (i = 0; i < skb->len; i++) {
+		if (i % 16 == 0) {
+			if (i)
+				printk("\n");
+			printk(KERN_DEBUG "%s: data[%p]:", dev->name,
+			       skb->data + i);
+		}
+		printk(" %02x", ((u8 *)skb->data)[i]);
+	}
+	printk("\n");
+}
+
+static int cpmac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+{
+	u32 val;
+
+	while (cpmac_read(bus->priv, CPMAC_MDIO_ACCESS(0)) & MDIO_BUSY)
+		cpu_relax();
+	cpmac_write(bus->priv, CPMAC_MDIO_ACCESS(0), MDIO_BUSY | MDIO_REG(reg) |
+		    MDIO_PHY(phy_id));
+	while ((val = cpmac_read(bus->priv, CPMAC_MDIO_ACCESS(0))) & MDIO_BUSY)
+		cpu_relax();
+	return MDIO_DATA(val);
+}
+
+static int cpmac_mdio_write(struct mii_bus *bus, int phy_id,
+			    int reg, u16 val)
+{
+	while (cpmac_read(bus->priv, CPMAC_MDIO_ACCESS(0)) & MDIO_BUSY)
+		cpu_relax();
+	cpmac_write(bus->priv, CPMAC_MDIO_ACCESS(0), MDIO_BUSY | MDIO_WRITE |
+		    MDIO_REG(reg) | MDIO_PHY(phy_id) | MDIO_DATA(val));
+	return 0;
+}
+
+static int cpmac_mdio_reset(struct mii_bus *bus)
+{
+	ar7_device_reset(AR7_RESET_BIT_MDIO);
+	cpmac_write(bus->priv, CPMAC_MDIO_CONTROL, MDIOC_ENABLE |
+		    MDIOC_CLKDIV(ar7_cpmac_freq() / 2200000 - 1));
+	return 0;
+}
+
+static int mii_irqs[PHY_MAX_ADDR] = { PHY_POLL, };
+
+static struct mii_bus cpmac_mii = {
+	.name = "cpmac-mii",
+	.read = cpmac_mdio_read,
+	.write = cpmac_mdio_write,
+	.reset = cpmac_mdio_reset,
+	.irq = mii_irqs,
+};
+
+static int cpmac_config(struct net_device *dev, struct ifmap *map)
+{
+	if (dev->flags & IFF_UP)
+		return -EBUSY;
+
+	/* Don't allow changing the I/O address */
+	if (map->base_addr != dev->base_addr)
+		return -EOPNOTSUPP;
+
+	/* ignore other fields */
+	return 0;
+}
+
+static void cpmac_set_multicast_list(struct net_device *dev)
+{
+	struct dev_mc_list *iter;
+	int i;
+	u8 tmp;
+	u32 mbp, bit, hash[2] = { 0, };
+	struct cpmac_priv *priv = netdev_priv(dev);
+
+	mbp = cpmac_read(priv->regs, CPMAC_MBP);
+	if (dev->flags & IFF_PROMISC) {
+		cpmac_write(priv->regs, CPMAC_MBP, (mbp & ~MBP_PROMISCCHAN(0)) |
+			    MBP_RXPROMISC);
+	} else {
+		cpmac_write(priv->regs, CPMAC_MBP, mbp & ~MBP_RXPROMISC);
+		if (dev->flags & IFF_ALLMULTI) {
+			/* enable all multicast mode */
+			cpmac_write(priv->regs, CPMAC_MAC_HASH_LO, 0xffffffff);
+			cpmac_write(priv->regs, CPMAC_MAC_HASH_HI, 0xffffffff);
+		} else {
+			/*
+			 * cpmac uses some strange mac address hashing
+			 * (not crc32)
+			 */
+			for (i = 0, iter = dev->mc_list; i < dev->mc_count;
+			     i++, iter = iter->next) {
+				bit = 0;
+				tmp = iter->dmi_addr[0];
+				bit  ^= (tmp >> 2) ^ (tmp << 4);
+				tmp = iter->dmi_addr[1];
+				bit  ^= (tmp >> 4) ^ (tmp << 2);
+				tmp = iter->dmi_addr[2];
+				bit  ^= (tmp >> 6) ^ tmp;
+				tmp = iter->dmi_addr[3];
+				bit  ^= (tmp >> 2) ^ (tmp << 4);
+				tmp = iter->dmi_addr[4];
+				bit  ^= (tmp >> 4) ^ (tmp << 2);
+				tmp = iter->dmi_addr[5];
+				bit  ^= (tmp >> 6) ^ tmp;
+				bit &= 0x3f;
+				hash[bit / 32] |= 1 << (bit % 32);
+			}
+
+			cpmac_write(priv->regs, CPMAC_MAC_HASH_LO, hash[0]);
+			cpmac_write(priv->regs, CPMAC_MAC_HASH_HI, hash[1]);
+		}
+	}
+}
+
+static struct sk_buff *cpmac_rx_one(struct net_device *dev,
+				    struct cpmac_priv *priv,
+				    struct cpmac_desc *desc)
+{
+	struct sk_buff *skb, *result = NULL;
+
+	if (unlikely(netif_msg_hw(priv)))
+		cpmac_dump_desc(dev, desc);
+	cpmac_write(priv->regs, CPMAC_RX_ACK(0), (u32)desc->mapping);
+	if (unlikely(!desc->datalen)) {
+		if (netif_msg_rx_err(priv) && net_ratelimit())
+			printk(KERN_WARNING "%s: rx: spurious interrupt\n",
+			       dev->name);
+		return NULL;
+	}
+
+	skb = netdev_alloc_skb(dev, CPMAC_SKB_SIZE);
+	if (likely(skb)) {
+		skb_reserve(skb, 2);
+		skb_put(desc->skb, desc->datalen);
+		desc->skb->protocol = eth_type_trans(desc->skb, dev);
+		desc->skb->ip_summed = CHECKSUM_NONE;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += desc->datalen;
+		result = desc->skb;
+		dma_unmap_single(&dev->dev, desc->data_mapping, CPMAC_SKB_SIZE,
+				 DMA_FROM_DEVICE);
+		desc->skb = skb;
+		desc->data_mapping = dma_map_single(&dev->dev, skb->data,
+						    CPMAC_SKB_SIZE,
+						    DMA_FROM_DEVICE);
+		desc->hw_data = (u32)desc->data_mapping;
+		if (unlikely(netif_msg_pktdata(priv))) {
+			printk(KERN_DEBUG "%s: received packet:\n", dev->name);
+			cpmac_dump_skb(dev, result);
+		}
+	} else {
+		if (netif_msg_rx_err(priv) && net_ratelimit())
+			printk(KERN_WARNING
+			       "%s: low on skbs, dropping packet\n", dev->name);
+		dev->stats.rx_dropped++;
+	}
+
+	desc->buflen = CPMAC_SKB_SIZE;
+	desc->dataflags = CPMAC_OWN;
+
+	return result;
+}
+
+static int cpmac_poll(struct net_device *dev, int *budget)
+{
+	struct sk_buff *skb;
+	struct cpmac_desc *desc;
+	int received = 0, quota = min(dev->quota, *budget);
+	struct cpmac_priv *priv = netdev_priv(dev);
+
+	spin_lock(&priv->rx_lock);
+	if (unlikely(!priv->rx_head)) {
+		if (netif_msg_rx_err(priv) && net_ratelimit())
+			printk(KERN_WARNING "%s: rx: polling, but no queue\n",
+			       dev->name);
+		netif_rx_complete(dev);
+		return 0;
+	}
+
+	desc = priv->rx_head;
+	while ((received < quota) && ((desc->dataflags & CPMAC_OWN) == 0)) {
+		skb = cpmac_rx_one(dev, priv, desc);
+		if (likely(skb)) {
+			netif_receive_skb(skb);
+			received++;
+		}
+		desc = desc->next;
+	}
+
+	priv->rx_head = desc;
+	spin_unlock(&priv->rx_lock);
+	*budget -= received;
+	dev->quota -= received;
+	if (unlikely(netif_msg_rx_status(priv)))
+		printk(KERN_DEBUG "%s: poll processed %d packets\n", dev->name,
+		       received);
+	if (desc->dataflags & CPMAC_OWN) {
+		netif_rx_complete(dev);
+		cpmac_write(priv->regs, CPMAC_RX_PTR(0), (u32)desc->mapping);
+		cpmac_write(priv->regs, CPMAC_RX_INT_ENABLE, 1);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int queue, len;
+	struct cpmac_desc *desc;
+	struct cpmac_priv *priv = netdev_priv(dev);
+
+	if (unlikely(skb_padto(skb, ETH_ZLEN))) {
+		if (netif_msg_tx_err(priv) && net_ratelimit())
+			printk(KERN_WARNING
+			       "%s: tx: padding failed, dropping\n", dev->name);
+		spin_lock(&priv->lock);
+		dev->stats.tx_dropped++;
+		spin_unlock(&priv->lock);
+		return -ENOMEM;
+	}
+
+	len = max(skb->len, ETH_ZLEN);
+	queue = skb->queue_mapping;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netif_stop_subqueue(dev, queue);
+#else
+	netif_stop_queue(dev);
+#endif
+
+	desc = &priv->desc_ring[queue];
+	if (unlikely(desc->dataflags & CPMAC_OWN)) {
+		if (netif_msg_tx_err(priv) && net_ratelimit())
+			printk(KERN_WARNING "%s: tx dma ring full, dropping\n",
+			       dev->name);
+		spin_lock(&priv->lock);
+		dev->stats.tx_dropped++;
+		spin_unlock(&priv->lock);
+		dev_kfree_skb_any(skb);
+		return -ENOMEM;
+	}
+
+	spin_lock(&priv->lock);
+	dev->trans_start = jiffies;
+	spin_unlock(&priv->lock);
+	desc->dataflags = CPMAC_SOP | CPMAC_EOP | CPMAC_OWN;
+	desc->skb = skb;
+	desc->data_mapping = dma_map_single(&dev->dev, skb->data, len,
+					    DMA_TO_DEVICE);
+	desc->hw_data = (u32)desc->data_mapping;
+	desc->datalen = len;
+	desc->buflen = len;
+	if (unlikely(netif_msg_tx_queued(priv)))
+		printk(KERN_DEBUG "%s: sending 0x%p, len=%d\n", dev->name, skb,
+		       skb->len);
+	if (unlikely(netif_msg_hw(priv)))
+		cpmac_dump_desc(dev, desc);
+	if (unlikely(netif_msg_pktdata(priv)))
+		cpmac_dump_skb(dev, skb);
+	cpmac_write(priv->regs, CPMAC_TX_PTR(queue), (u32)desc->mapping);
+
+	return 0;
+}
+
+static void cpmac_end_xmit(struct net_device *dev, int queue)
+{
+	struct cpmac_desc *desc;
+	struct cpmac_priv *priv = netdev_priv(dev);
+
+	desc = &priv->desc_ring[queue];
+	cpmac_write(priv->regs, CPMAC_TX_ACK(queue), (u32)desc->mapping);
+	if (likely(desc->skb)) {
+		spin_lock(&priv->lock);
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += desc->skb->len;
+		spin_unlock(&priv->lock);
+		dma_unmap_single(&dev->dev, desc->data_mapping, desc->skb->len,
+				 DMA_TO_DEVICE);
+
+		if (unlikely(netif_msg_tx_done(priv)))
+			printk(KERN_DEBUG "%s: sent 0x%p, len=%d\n", dev->name,
+			       desc->skb, desc->skb->len);
+
+		dev_kfree_skb_irq(desc->skb);
+		desc->skb = NULL;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+		if (netif_subqueue_stopped(dev, queue))
+			netif_wake_subqueue(dev, queue);
+#else
+		if (netif_queue_stopped(dev))
+			netif_wake_queue(dev);
+#endif
+	} else {
+		if (netif_msg_tx_err(priv) && net_ratelimit())
+			printk(KERN_WARNING
+			       "%s: end_xmit: spurious interrupt\n", dev->name);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+		if (netif_subqueue_stopped(dev, queue))
+			netif_wake_subqueue(dev, queue);
+#else
+		if (netif_queue_stopped(dev))
+			netif_wake_queue(dev);
+#endif
+	}
+}
+
+static void cpmac_hw_stop(struct net_device *dev)
+{
+	int i;
+	struct cpmac_priv *priv = netdev_priv(dev);
+	struct plat_cpmac_data *pdata = priv->pdev->dev.platform_data;
+
+	ar7_device_reset(pdata->reset_bit);
+	cpmac_write(priv->regs, CPMAC_RX_CONTROL,
+		    cpmac_read(priv->regs, CPMAC_RX_CONTROL) & ~1);
+	cpmac_write(priv->regs, CPMAC_TX_CONTROL,
+		    cpmac_read(priv->regs, CPMAC_TX_CONTROL) & ~1);
+	for (i = 0; i < 8; i++) {
+		cpmac_write(priv->regs, CPMAC_TX_PTR(i), 0);
+		cpmac_write(priv->regs, CPMAC_RX_PTR(i), 0);
+	}
+	cpmac_write(priv->regs, CPMAC_UNICAST_CLEAR, 0xff);
+	cpmac_write(priv->regs, CPMAC_RX_INT_CLEAR, 0xff);
+	cpmac_write(priv->regs, CPMAC_TX_INT_CLEAR, 0xff);
+	cpmac_write(priv->regs, CPMAC_MAC_INT_CLEAR, 0xff);
+	cpmac_write(priv->regs, CPMAC_MAC_CONTROL,
+		    cpmac_read(priv->regs, CPMAC_MAC_CONTROL) & ~MAC_MII);
+}
+
+static void cpmac_hw_start(struct net_device *dev)
+{
+	int i;
+	struct cpmac_priv *priv = netdev_priv(dev);
+	struct plat_cpmac_data *pdata = priv->pdev->dev.platform_data;
+
+	ar7_device_reset(pdata->reset_bit);
+	for (i = 0; i < 8; i++) {
+		cpmac_write(priv->regs, CPMAC_TX_PTR(i), 0);
+		cpmac_write(priv->regs, CPMAC_RX_PTR(i), 0);
+	}
+	cpmac_write(priv->regs, CPMAC_RX_PTR(0), priv->rx_head->mapping);
+
+	cpmac_write(priv->regs, CPMAC_MBP, MBP_RXSHORT | MBP_RXBCAST |
+		    MBP_RXMCAST);
+	cpmac_write(priv->regs, CPMAC_BUFFER_OFFSET, 0);
+	for (i = 0; i < 8; i++)
+		cpmac_write(priv->regs, CPMAC_MAC_ADDR_LO(i), dev->dev_addr[5]);
+	cpmac_write(priv->regs, CPMAC_MAC_ADDR_MID, dev->dev_addr[4]);
+	cpmac_write(priv->regs, CPMAC_MAC_ADDR_HI, dev->dev_addr[0] |
+		    (dev->dev_addr[1] << 8) | (dev->dev_addr[2] << 16) |
+		    (dev->dev_addr[3] << 24));
+	cpmac_write(priv->regs, CPMAC_MAX_LENGTH, CPMAC_SKB_SIZE);
+	cpmac_write(priv->regs, CPMAC_UNICAST_CLEAR, 0xff);
+	cpmac_write(priv->regs, CPMAC_RX_INT_CLEAR, 0xff);
+	cpmac_write(priv->regs, CPMAC_TX_INT_CLEAR, 0xff);
+	cpmac_write(priv->regs, CPMAC_MAC_INT_CLEAR, 0xff);
+	cpmac_write(priv->regs, CPMAC_UNICAST_ENABLE, 1);
+	cpmac_write(priv->regs, CPMAC_RX_INT_ENABLE, 1);
+	cpmac_write(priv->regs, CPMAC_TX_INT_ENABLE, 0xff);
+	cpmac_write(priv->regs, CPMAC_MAC_INT_ENABLE, 3);
+
+	cpmac_write(priv->regs, CPMAC_RX_CONTROL,
+		    cpmac_read(priv->regs, CPMAC_RX_CONTROL) | 1);
+	cpmac_write(priv->regs, CPMAC_TX_CONTROL,
+		    cpmac_read(priv->regs, CPMAC_TX_CONTROL) | 1);
+	cpmac_write(priv->regs, CPMAC_MAC_CONTROL,
+		    cpmac_read(priv->regs, CPMAC_MAC_CONTROL) | MAC_MII |
+		    MAC_FDX);
+}
+
+static void cpmac_clear_rx(struct net_device *dev)
+{
+	struct cpmac_priv *priv = netdev_priv(dev);
+	struct cpmac_desc *desc;
+	int i;
+	if (unlikely(!priv->rx_head))
+		return;
+	desc = priv->rx_head;
+	for (i = 0; i < priv->ring_size; i++) {
+		if ((desc->dataflags & CPMAC_OWN) == 0) {
+			if (netif_msg_rx_err(priv) && net_ratelimit())
+				printk(KERN_WARNING "%s: packet dropped\n",
+				       dev->name);
+			if (unlikely(netif_msg_hw(priv)))
+				cpmac_dump_desc(dev, desc);
+			desc->dataflags = CPMAC_OWN;
+			dev->stats.rx_dropped++;
+		}
+		desc = desc->next;
+	}
+}
+
+static void cpmac_clear_tx(struct net_device *dev)
+{
+	struct cpmac_priv *priv = netdev_priv(dev);
+	int i;
+	if (unlikely(!priv->desc_ring))
+		return;
+	for (i = 0; i < CPMAC_QUEUES; i++)
+		if (priv->desc_ring[i].skb) {
+			dev_kfree_skb_any(priv->desc_ring[i].skb);
+			if (netif_subqueue_stopped(dev, i))
+			    netif_wake_subqueue(dev, i);
+		}
+}
+
+static void cpmac_hw_error(struct work_struct *work)
+{
+	struct cpmac_priv *priv =
+		container_of(work, struct cpmac_priv, reset_work);
+
+	spin_lock(&priv->rx_lock);
+	cpmac_clear_rx(priv->dev);
+	spin_unlock(&priv->rx_lock);
+	cpmac_clear_tx(priv->dev);
+	cpmac_hw_start(priv->dev);
+	netif_start_queue(priv->dev);
+}
+
+static irqreturn_t cpmac_irq(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct cpmac_priv *priv;
+	int queue;
+	u32 status;
+
+	if (!dev)
+		return IRQ_NONE;
+
+	priv = netdev_priv(dev);
+
+	status = cpmac_read(priv->regs, CPMAC_MAC_INT_VECTOR);
+
+	if (unlikely(netif_msg_intr(priv)))
+		printk(KERN_DEBUG "%s: interrupt status: 0x%08x\n", dev->name,
+		       status);
+
+	if (status & MAC_INT_TX)
+		cpmac_end_xmit(dev, (status & 7));
+
+	if (status & MAC_INT_RX) {
+		queue = (status >> 8) & 7;
+		netif_rx_schedule(dev);
+		cpmac_write(priv->regs, CPMAC_RX_INT_CLEAR, 1 << queue);
+	}
+
+	cpmac_write(priv->regs, CPMAC_MAC_EOI_VECTOR, 0);
+
+	if (unlikely(status & (MAC_INT_HOST | MAC_INT_STATUS))) {
+		if (netif_msg_drv(priv) && net_ratelimit())
+			printk(KERN_ERR "%s: hw error, resetting...\n",
+			       dev->name);
+		netif_stop_queue(dev);
+		cpmac_hw_stop(dev);
+		schedule_work(&priv->reset_work);
+		if (unlikely(netif_msg_hw(priv)))
+			cpmac_dump_regs(dev);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static void cpmac_tx_timeout(struct net_device *dev)
+{
+	struct cpmac_priv *priv = netdev_priv(dev);
+	int i;
+
+	spin_lock(&priv->lock);
+	dev->stats.tx_errors++;
+	spin_unlock(&priv->lock);
+	if (netif_msg_tx_err(priv) && net_ratelimit())
+		printk(KERN_WARNING "%s: transmit timeout\n", dev->name);
+	/* 
+	 * FIXME: waking up random queue is not the best thing to
+	 * do... on the other hand why we got here at all?
+	 */
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	for (i = 0; i < CPMAC_QUEUES; i++)
+		if (priv->desc_ring[i].skb) {
+			dev_kfree_skb_any(priv->desc_ring[i].skb);
+			netif_wake_subqueue(dev, i);
+			break;
+		}
+#else
+	if (priv->desc_ring[0].skb)
+		dev_kfree_skb_any(priv->desc_ring[0].skb);
+	netif_wake_queue(dev);
+#endif
+}
+
+static int cpmac_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct cpmac_priv *priv = netdev_priv(dev);
+	if (!(netif_running(dev)))
+		return -EINVAL;
+	if (!priv->phy)
+		return -EINVAL;
+	if ((cmd == SIOCGMIIPHY) || (cmd == SIOCGMIIREG) ||
+	    (cmd == SIOCSMIIREG))
+		return phy_mii_ioctl(priv->phy, if_mii(ifr), cmd);
+
+	return -EOPNOTSUPP;
+}
+
+static int cpmac_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct cpmac_priv *priv = netdev_priv(dev);
+
+	if (priv->phy)
+		return phy_ethtool_gset(priv->phy, cmd);
+
+	return -EINVAL;
+}
+
+static int cpmac_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct cpmac_priv *priv = netdev_priv(dev);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (priv->phy)
+		return phy_ethtool_sset(priv->phy, cmd);
+
+	return -EINVAL;
+}
+
+static void cpmac_get_ringparam(struct net_device *dev, struct ethtool_ringparam* ring)
+{
+	struct cpmac_priv *priv = netdev_priv(dev);
+
+	ring->rx_max_pending = 1024;
+	ring->rx_mini_max_pending = 1;
+	ring->rx_jumbo_max_pending = 1;
+	ring->tx_max_pending = 1;
+
+	ring->rx_pending = priv->ring_size;
+	ring->rx_mini_pending = 1;
+	ring->rx_jumbo_pending = 1;
+	ring->tx_pending = 1;
+}
+
+static int cpmac_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ring)
+{
+	struct cpmac_priv *priv = netdev_priv(dev);
+
+	if (dev->flags && IFF_UP)
+		return -EBUSY;
+	priv->ring_size = ring->rx_pending;
+	return 0;
+}
+
+static void cpmac_get_drvinfo(struct net_device *dev,
+			      struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, "cpmac");
+	strcpy(info->version, CPMAC_VERSION);
+	info->fw_version[0] = '\0';
+	sprintf(info->bus_info, "%s", "cpmac");
+	info->regdump_len = 0;
+}
+
+static const struct ethtool_ops cpmac_ethtool_ops = {
+	.get_settings = cpmac_get_settings,
+	.set_settings = cpmac_set_settings,
+	.get_drvinfo = cpmac_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+	.get_ringparam = cpmac_get_ringparam,
+	.set_ringparam = cpmac_set_ringparam,
+};
+
+static void cpmac_adjust_link(struct net_device *dev)
+{
+	struct cpmac_priv *priv = netdev_priv(dev);
+	int new_state = 0;
+
+	spin_lock(&priv->lock);
+	if (priv->phy->link) {
+		netif_start_queue(dev);
+		if (priv->phy->duplex != priv->oldduplex) {
+			new_state = 1;
+			priv->oldduplex = priv->phy->duplex;
+		}
+
+		if (priv->phy->speed != priv->oldspeed) {
+			new_state = 1;
+			priv->oldspeed = priv->phy->speed;
+		}
+
+		if (!priv->oldlink) {
+			new_state = 1;
+			priv->oldlink = 1;
+			netif_schedule(dev);
+		}
+	} else if (priv->oldlink) {
+		netif_stop_queue(dev);
+		new_state = 1;
+		priv->oldlink = 0;
+		priv->oldspeed = 0;
+		priv->oldduplex = -1;
+	}
+
+	if (new_state && netif_msg_link(priv) && net_ratelimit())
+		phy_print_status(priv->phy);
+
+	spin_unlock(&priv->lock);
+}
+
+static int cpmac_open(struct net_device *dev)
+{
+	int i, size, res;
+	struct cpmac_priv *priv = netdev_priv(dev);
+	struct resource *mem;
+	struct cpmac_desc *desc;
+	struct sk_buff *skb;
+
+	priv->phy = phy_connect(dev, priv->phy_name, &cpmac_adjust_link,
+				0, PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(priv->phy)) {
+		if (netif_msg_drv(priv))
+			printk(KERN_ERR "%s: Could not attach to PHY\n",
+			       dev->name);
+		return PTR_ERR(priv->phy);
+	}
+
+	mem = platform_get_resource_byname(priv->pdev, IORESOURCE_MEM, "regs");
+	if (!request_mem_region(mem->start, mem->end - mem->start, dev->name)) {
+		if (netif_msg_drv(priv))
+			printk(KERN_ERR "%s: failed to request registers\n",
+			       dev->name);
+		res = -ENXIO;
+		goto fail_reserve;
+	}
+
+	priv->regs = ioremap(mem->start, mem->end - mem->start);
+	if (!priv->regs) {
+		if (netif_msg_drv(priv))
+			printk(KERN_ERR "%s: failed to remap registers\n",
+			       dev->name);
+		res = -ENXIO;
+		goto fail_remap;
+	}
+
+	size = priv->ring_size + CPMAC_QUEUES;
+	priv->desc_ring = dma_alloc_coherent(&dev->dev,
+					     sizeof(struct cpmac_desc) * size,
+					     &priv->dma_ring,
+					     GFP_KERNEL);
+	if (!priv->desc_ring) {
+		res = -ENOMEM;
+		goto fail_alloc;
+	}
+
+	for (i = 0; i < size; i++)
+		priv->desc_ring[i].mapping = priv->dma_ring + sizeof(*desc) * i;
+
+	priv->rx_head = &priv->desc_ring[CPMAC_QUEUES];
+	for (i = 0, desc = priv->rx_head; i < priv->ring_size; i++, desc++) {
+		skb = netdev_alloc_skb(dev, CPMAC_SKB_SIZE);
+		if (unlikely(!skb)) {
+			res = -ENOMEM;
+			goto fail_desc;
+		}
+		skb_reserve(skb, 2);
+		desc->skb = skb;
+		desc->data_mapping = dma_map_single(&dev->dev, skb->data,
+						    CPMAC_SKB_SIZE,
+						    DMA_FROM_DEVICE);
+		desc->hw_data = (u32)desc->data_mapping;
+		desc->buflen = CPMAC_SKB_SIZE;
+		desc->dataflags = CPMAC_OWN;
+		desc->next = &priv->rx_head[(i + 1) % priv->ring_size];
+		desc->hw_next = (u32)desc->next->mapping;
+	}
+
+	if ((res = request_irq(dev->irq, cpmac_irq, IRQF_SHARED,
+			       dev->name, dev))) {
+		if (netif_msg_drv(priv))
+			printk(KERN_ERR "%s: failed to obtain irq\n",
+			       dev->name);
+		goto fail_irq;
+	}
+
+	INIT_WORK(&priv->reset_work, cpmac_hw_error);
+	cpmac_hw_start(dev);
+
+	priv->phy->state = PHY_CHANGELINK;
+	phy_start(priv->phy);
+
+	return 0;
+
+fail_irq:
+fail_desc:
+	for (i = 0; i < priv->ring_size; i++) {
+		if (priv->rx_head[i].skb) {
+			dma_unmap_single(&dev->dev,
+					 priv->rx_head[i].data_mapping,
+					 CPMAC_SKB_SIZE,
+					 DMA_FROM_DEVICE);
+			kfree_skb(priv->rx_head[i].skb);
+		}
+	}
+fail_alloc:
+	kfree(priv->desc_ring);
+	iounmap(priv->regs);
+
+fail_remap:
+	release_mem_region(mem->start, mem->end - mem->start);
+
+fail_reserve:
+	phy_disconnect(priv->phy);
+
+	return res;
+}
+
+static int cpmac_stop(struct net_device *dev)
+{
+	int i;
+	struct cpmac_priv *priv = netdev_priv(dev);
+	struct resource *mem;
+
+	netif_stop_queue(dev);
+
+	cancel_work_sync(&priv->reset_work);
+	phy_stop(priv->phy);
+	phy_disconnect(priv->phy);
+	priv->phy = NULL;
+
+	cpmac_hw_stop(dev);
+
+	for (i = 0; i < 8; i++)
+		cpmac_write(priv->regs, CPMAC_TX_PTR(i), 0);
+	cpmac_write(priv->regs, CPMAC_RX_PTR(0), 0);
+	cpmac_write(priv->regs, CPMAC_MBP, 0);
+
+	free_irq(dev->irq, dev);
+	iounmap(priv->regs);
+	mem = platform_get_resource_byname(priv->pdev, IORESOURCE_MEM, "regs");
+	release_mem_region(mem->start, mem->end - mem->start);
+	priv->rx_head = &priv->desc_ring[CPMAC_QUEUES];
+	for (i = 0; i < priv->ring_size; i++) {
+		if (priv->rx_head[i].skb) {
+			dma_unmap_single(&dev->dev,
+					 priv->rx_head[i].data_mapping,
+					 CPMAC_SKB_SIZE,
+					 DMA_FROM_DEVICE);
+			kfree_skb(priv->rx_head[i].skb);
+		}
+	}
+
+	dma_free_coherent(&dev->dev, sizeof(struct cpmac_desc) *
+			  (CPMAC_QUEUES + priv->ring_size),
+			  priv->desc_ring, priv->dma_ring);
+	return 0;
+}
+
+static int external_switch;
+
+static int __devinit cpmac_probe(struct platform_device *pdev)
+{
+	int rc, phy_id;
+	struct resource *mem;
+	struct cpmac_priv *priv;
+	struct net_device *dev;
+	struct plat_cpmac_data *pdata;
+
+	pdata = pdev->dev.platform_data;
+
+	for (phy_id = 0; phy_id < PHY_MAX_ADDR; phy_id++) {
+		if (!(pdata->phy_mask & (1 << phy_id)))
+			continue;
+		if (!cpmac_mii.phy_map[phy_id])
+			continue;
+		break;
+	}
+
+	if (phy_id == PHY_MAX_ADDR) {
+		if (external_switch || dumb_switch)
+			phy_id = 0;
+		else {
+			printk(KERN_ERR "cpmac: no PHY present\n");
+			return -ENODEV;
+		}
+	}
+
+	dev = alloc_etherdev_mq(sizeof(*priv), CPMAC_QUEUES);
+
+	if (!dev) {
+		printk(KERN_ERR "cpmac: Unable to allocate net_device\n");
+		return -ENOMEM;
+	}
+
+	platform_set_drvdata(pdev, dev);
+	priv = netdev_priv(dev);
+
+	priv->pdev = pdev;
+	mem = platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
+	if (!mem) {
+		rc = -ENODEV;
+		goto fail;
+	}
+
+	dev->irq = platform_get_irq_byname(pdev, "irq");
+
+	dev->open               = cpmac_open;
+	dev->stop               = cpmac_stop;
+	dev->set_config         = cpmac_config;
+	dev->hard_start_xmit    = cpmac_start_xmit;
+	dev->do_ioctl           = cpmac_ioctl;
+	dev->set_multicast_list = cpmac_set_multicast_list;
+	dev->tx_timeout         = cpmac_tx_timeout;
+	dev->ethtool_ops        = &cpmac_ethtool_ops;
+	dev->poll = cpmac_poll;
+	dev->weight = 64;
+	dev->features |= NETIF_F_MULTI_QUEUE;
+
+	spin_lock_init(&priv->lock);
+	spin_lock_init(&priv->rx_lock);
+	priv->dev = dev;
+	priv->ring_size = 64;
+	priv->msg_enable = netif_msg_init(debug_level, 0xff);
+	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
+	if (phy_id == 31) {
+		snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT,
+			 cpmac_mii.id, phy_id);
+	} else
+		snprintf(priv->phy_name, BUS_ID_SIZE, "fixed@%d:%d", 100, 1);
+
+	if ((rc = register_netdev(dev))) {
+		printk(KERN_ERR "cpmac: error %i registering device %s\n", rc,
+		       dev->name);
+		goto fail;
+	}
+
+	if (netif_msg_probe(priv)) {
+		printk(KERN_INFO
+		       "cpmac: device %s (regs: %p, irq: %d, phy: %s, mac: "
+		       MAC_FMT ")\n", dev->name, (void *)mem->start, dev->irq,
+		       priv->phy_name, MAC_ARG(dev->dev_addr));
+	}
+	return 0;
+
+fail:
+	free_netdev(dev);
+	return rc;
+}
+
+static int __devexit cpmac_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	unregister_netdev(dev);
+	free_netdev(dev);
+	return 0;
+}
+
+static struct platform_driver cpmac_driver = {
+	.driver.name = "cpmac",
+	.probe = cpmac_probe,
+	.remove = __devexit_p(cpmac_remove),
+};
+
+int __devinit cpmac_init(void)
+{
+	u32 mask;
+	int i, res;
+
+	cpmac_mii.priv = ioremap(AR7_REGS_MDIO, 256);
+
+	if (!cpmac_mii.priv) {
+		printk(KERN_ERR "Can't ioremap mdio registers\n");
+		return -ENXIO;
+	}
+
+#warning FIXME: unhardcode gpio&reset bits
+	ar7_gpio_disable(26);
+	ar7_gpio_disable(27);
+	ar7_device_reset(AR7_RESET_BIT_CPMAC_LO);
+	ar7_device_reset(AR7_RESET_BIT_CPMAC_HI);
+	ar7_device_reset(AR7_RESET_BIT_EPHY);
+
+	cpmac_mii.reset(&cpmac_mii);
+
+	for (i = 0; i < 300000; i++)
+		if ((mask = cpmac_read(cpmac_mii.priv, CPMAC_MDIO_ALIVE)))
+			break;
+		else
+			cpu_relax();
+
+	mask &= 0x7fffffff;
+	if (mask & (mask - 1)) {
+		external_switch = 1;
+		mask = 0;
+	}
+
+	cpmac_mii.phy_mask = ~(mask | 0x80000000);
+
+	res = mdiobus_register(&cpmac_mii);
+	if (res)
+		goto fail_mii;
+
+	res = platform_driver_register(&cpmac_driver);
+	if (res)
+		goto fail_cpmac;
+
+	return 0;
+
+fail_cpmac:
+	mdiobus_unregister(&cpmac_mii);
+
+fail_mii:
+	iounmap(cpmac_mii.priv);
+
+	return res;
+}
+
+void __devexit cpmac_exit(void)
+{
+	platform_driver_unregister(&cpmac_driver);
+	mdiobus_unregister(&cpmac_mii);
+	iounmap(cpmac_mii.priv);
+}
+
+module_init(cpmac_init);
+module_exit(cpmac_exit);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 0db5e6f..558440c 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -168,7 +168,6 @@ static int gfar_probe(struct platform_device *pdev)
 	struct gfar_private *priv = NULL;
 	struct gianfar_platform_data *einfo;
 	struct resource *r;
-	int idx;
 	int err = 0;
 	DECLARE_MAC_BUF(mac);
 
@@ -261,7 +260,9 @@ static int gfar_probe(struct platform_device *pdev)
 	dev->hard_start_xmit = gfar_start_xmit;
 	dev->tx_timeout = gfar_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_GFAR_NAPI
 	netif_napi_add(dev, &priv->napi, gfar_poll, GFAR_DEV_WEIGHT);
+#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = gfar_netpoll;
 #endif
@@ -931,9 +932,14 @@ tx_skb_fail:
 /* Returns 0 for success. */
 static int gfar_enet_open(struct net_device *dev)
 {
+#ifdef CONFIG_GFAR_NAPI
+	struct gfar_private *priv = netdev_priv(dev);
+#endif
 	int err;
 
+#ifdef CONFIG_GFAR_NAPI
 	napi_enable(&priv->napi);
+#endif
 
 	/* Initialize a bunch of registers */
 	init_registers(dev);
@@ -943,13 +949,17 @@ static int gfar_enet_open(struct net_device *dev)
 	err = init_phy(dev);
 
 	if(err) {
+#ifdef CONFIG_GFAR_NAPI
 		napi_disable(&priv->napi);
+#endif
 		return err;
 	}
 
 	err = startup_gfar(dev);
 	if (err)
+#ifdef CONFIG_GFAR_NAPI
 		napi_disable(&priv->napi);
+#endif
 
 	netif_start_queue(dev);
 
@@ -1103,7 +1113,9 @@ static int gfar_close(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
+#ifdef CONFIG_GFAR_NAPI
 	napi_disable(&priv->napi);
+#endif
 
 	stop_gfar(dev);
 
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.c b/drivers/net/ibm_emac/ibm_emac_mal.c
index 4e49e8c..dcd8826 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.c
+++ b/drivers/net/ibm_emac/ibm_emac_mal.c
@@ -413,7 +413,10 @@ static int __init mal_probe(struct ocp_device *ocpdev)
 		       ocpdev->def->index);
 		return -ENOMEM;
 	}
-	mal->dcrbase = maldata->dcr_base;
+
+	/* XXX This only works for native dcr for now */
+	mal->dcrhost = dcr_map(NULL, maldata->dcr_base, 0);
+
 	mal->def = ocpdev->def;
 
 	INIT_LIST_HEAD(&mal->poll_list);
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.h b/drivers/net/ibm_emac/ibm_emac_mal.h
index 8f54d62..b8adbe6 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.h
+++ b/drivers/net/ibm_emac/ibm_emac_mal.h
@@ -191,7 +191,6 @@ struct mal_commac {
 };
 
 struct ibm_ocp_mal {
-	int			dcrbase;
 	dcr_host_t		dcrhost;
 
 	struct list_head	poll_list;
@@ -209,12 +208,12 @@ struct ibm_ocp_mal {
 
 static inline u32 get_mal_dcrn(struct ibm_ocp_mal *mal, int reg)
 {
-	return dcr_read(mal->dcrhost, mal->dcrbase + reg);
+	return dcr_read(mal->dcrhost, reg);
 }
 
 static inline void set_mal_dcrn(struct ibm_ocp_mal *mal, int reg, u32 val)
 {
-	dcr_write(mal->dcrhost, mal->dcrbase + reg, val);
+	dcr_write(mal->dcrhost, reg, val);
 }
 
 /* Register MAL devices */
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index 5885411..39f4cb6 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -461,6 +461,7 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	struct mal_instance *mal;
 	int err = 0, i, bd_size;
 	int index = mal_count++;
+	unsigned int dcr_base;
 	const u32 *prop;
 	u32 cfg;
 
@@ -497,14 +498,14 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	}
 	mal->num_rx_chans = prop[0];
 
-	mal->dcr_base = dcr_resource_start(ofdev->node, 0);
-	if (mal->dcr_base == 0) {
+	dcr_base = dcr_resource_start(ofdev->node, 0);
+	if (dcr_base == 0) {
 		printk(KERN_ERR
 		       "mal%d: can't find DCR resource!\n", index);
 		err = -ENODEV;
 		goto fail;
 	}
-        mal->dcr_host = dcr_map(ofdev->node, mal->dcr_base, 0x100);
+	mal->dcr_host = dcr_map(ofdev->node, dcr_base, 0x100);
 	if (!DCR_MAP_OK(mal->dcr_host)) {
 		printk(KERN_ERR
 		       "mal%d: failed to map DCRs !\n", index);
@@ -626,7 +627,7 @@ static int __devinit mal_probe(struct of_device *ofdev,
  fail2:
 	dma_free_coherent(&ofdev->dev, bd_size, mal->bd_virt, mal->bd_dma);
  fail_unmap:
-	dcr_unmap(mal->dcr_host, mal->dcr_base, 0x100);
+	dcr_unmap(mal->dcr_host, 0x100);
  fail:
 	kfree(mal);
 
diff --git a/drivers/net/ibm_newemac/mal.h b/drivers/net/ibm_newemac/mal.h
index cb1a16d..784edb8 100644
--- a/drivers/net/ibm_newemac/mal.h
+++ b/drivers/net/ibm_newemac/mal.h
@@ -185,7 +185,6 @@ struct mal_commac {
 
 struct mal_instance {
 	int			version;
-	int			dcr_base;
 	dcr_host_t		dcr_host;
 
 	int			num_tx_chans;	/* Number of TX channels */
@@ -213,12 +212,12 @@ struct mal_instance {
 
 static inline u32 get_mal_dcrn(struct mal_instance *mal, int reg)
 {
-	return dcr_read(mal->dcr_host, mal->dcr_base + reg);
+	return dcr_read(mal->dcr_host, reg);
 }
 
 static inline void set_mal_dcrn(struct mal_instance *mal, int reg, u32 val)
 {
-	dcr_write(mal->dcr_host, mal->dcr_base + reg, val);
+	dcr_write(mal->dcr_host, reg, val);
 }
 
 /* Register MAL devices */
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 3e5eca1..a82d8f9 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -840,7 +840,7 @@ toshoboe_probe (struct toshoboe_cb *self)
 
   /* test 1: SIR filter and back to back */
 
-  for (j = 0; j < (sizeof (bauds) / sizeof (int)); ++j)
+  for (j = 0; j < ARRAY_SIZE(bauds); ++j)
     {
       int fir = (j > 1);
       toshoboe_stopchip (self);
diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index d3825c8..5c154fe 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -208,7 +208,6 @@ static int __init jazz_sonic_probe(struct platform_device *pdev)
 	struct sonic_local *lp;
 	struct resource *res;
 	int err = 0;
-	int i;
 	DECLARE_MAC_BUF(mac);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index d593175..37707a0 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -7,12 +7,12 @@
 #define DEBUG
 
 #include <linux/init.h>
+#include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/platform_device.h>
-#include <asm/io.h>
 #include <asm/mips-boards/simint.h>
 
 #include "mipsnet.h"		/* actual device IO mapping */
@@ -33,9 +33,8 @@ static int ioiocpy_frommipsnet(struct net_device *dev, unsigned char *kdata,
 	if (available_len < len)
 		return -EFAULT;
 
-	for (; len > 0; len--, kdata++) {
+	for (; len > 0; len--, kdata++)
 		*kdata = inb(mipsnet_reg_address(dev, rxDataBuffer));
-	}
 
 	return inl(mipsnet_reg_address(dev, rxDataCount));
 }
@@ -47,16 +46,15 @@ static inline ssize_t mipsnet_put_todevice(struct net_device *dev,
 	char *buf_ptr = skb->data;
 
 	pr_debug("%s: %s(): telling MIPSNET txDataCount(%d)\n",
-	         dev->name, __FUNCTION__, skb->len);
+		 dev->name, __FUNCTION__, skb->len);
 
 	outl(skb->len, mipsnet_reg_address(dev, txDataCount));
 
 	pr_debug("%s: %s(): sending data to MIPSNET txDataBuffer(%d)\n",
-	         dev->name, __FUNCTION__, skb->len);
+		 dev->name, __FUNCTION__, skb->len);
 
-	for (; count_to_go; buf_ptr++, count_to_go--) {
+	for (; count_to_go; buf_ptr++, count_to_go--)
 		outb(*buf_ptr, mipsnet_reg_address(dev, txDataBuffer));
-	}
 
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
@@ -67,7 +65,7 @@ static inline ssize_t mipsnet_put_todevice(struct net_device *dev,
 static int mipsnet_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	pr_debug("%s:%s(): transmitting %d bytes\n",
-	         dev->name, __FUNCTION__, skb->len);
+		 dev->name, __FUNCTION__, skb->len);
 
 	/* Only one packet at a time. Once TXDONE interrupt is serviced, the
 	 * queue will be restarted.
@@ -83,7 +81,8 @@ static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t count)
 	struct sk_buff *skb;
 	size_t len = count;
 
-	if (!(skb = alloc_skb(len + 2, GFP_KERNEL))) {
+	skb = alloc_skb(len + 2, GFP_KERNEL);
+	if (!skb) {
 		dev->stats.rx_dropped++;
 		return -ENOMEM;
 	}
@@ -96,7 +95,7 @@ static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t count)
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	pr_debug("%s:%s(): pushing RXed data to kernel\n",
-	         dev->name, __FUNCTION__);
+		 dev->name, __FUNCTION__);
 	netif_rx(skb);
 
 	dev->stats.rx_packets++;
@@ -114,42 +113,44 @@ static irqreturn_t mipsnet_interrupt(int irq, void *dev_id)
 
 	if (irq == dev->irq) {
 		pr_debug("%s:%s(): irq %d for device\n",
-		         dev->name, __FUNCTION__, irq);
+			 dev->name, __FUNCTION__, irq);
 
 		retval = IRQ_HANDLED;
 
 		interruptFlags =
 		    inl(mipsnet_reg_address(dev, interruptControl));
 		pr_debug("%s:%s(): intCtl=0x%016llx\n", dev->name,
-		         __FUNCTION__, interruptFlags);
+			 __FUNCTION__, interruptFlags);
 
 		if (interruptFlags & MIPSNET_INTCTL_TXDONE) {
 			pr_debug("%s:%s(): got TXDone\n",
-			         dev->name, __FUNCTION__);
+				 dev->name, __FUNCTION__);
 			outl(MIPSNET_INTCTL_TXDONE,
 			     mipsnet_reg_address(dev, interruptControl));
-			// only one packet at a time, we are done.
+			/* only one packet at a time, we are done. */
 			netif_wake_queue(dev);
 		} else if (interruptFlags & MIPSNET_INTCTL_RXDONE) {
 			pr_debug("%s:%s(): got RX data\n",
-			         dev->name, __FUNCTION__);
+				 dev->name, __FUNCTION__);
 			mipsnet_get_fromdev(dev,
-			            inl(mipsnet_reg_address(dev, rxDataCount)));
+				    inl(mipsnet_reg_address(dev, rxDataCount)));
 			pr_debug("%s:%s(): clearing RX int\n",
-			         dev->name, __FUNCTION__);
+				 dev->name, __FUNCTION__);
 			outl(MIPSNET_INTCTL_RXDONE,
 			     mipsnet_reg_address(dev, interruptControl));
 
 		} else if (interruptFlags & MIPSNET_INTCTL_TESTBIT) {
 			pr_debug("%s:%s(): got test interrupt\n",
-			         dev->name, __FUNCTION__);
-			// TESTBIT is cleared on read.
-			//    And takes effect after a write with 0
+				 dev->name, __FUNCTION__);
+			/*
+			 * TESTBIT is cleared on read.
+			 * And takes effect after a write with 0
+			 */
 			outl(0, mipsnet_reg_address(dev, interruptControl));
 		} else {
 			pr_debug("%s:%s(): no valid fags 0x%016llx\n",
-			         dev->name, __FUNCTION__, interruptFlags);
-			// Maybe shared IRQ, just ignore, no clearing.
+				 dev->name, __FUNCTION__, interruptFlags);
+			/* Maybe shared IRQ, just ignore, no clearing. */
 			retval = IRQ_NONE;
 		}
 
@@ -159,7 +160,7 @@ static irqreturn_t mipsnet_interrupt(int irq, void *dev_id)
 		retval = IRQ_NONE;
 	}
 	return retval;
-}				//mipsnet_interrupt()
+}
 
 static int mipsnet_open(struct net_device *dev)
 {
@@ -171,18 +172,18 @@ static int mipsnet_open(struct net_device *dev)
 
 	if (err) {
 		pr_debug("%s: %s(): can't get irq %d\n",
-		         dev->name, __FUNCTION__, dev->irq);
+			 dev->name, __FUNCTION__, dev->irq);
 		release_region(dev->base_addr, MIPSNET_IO_EXTENT);
 		return err;
 	}
 
 	pr_debug("%s: %s(): got IO region at 0x%04lx and irq %d for dev.\n",
-	         dev->name, __FUNCTION__, dev->base_addr, dev->irq);
+		 dev->name, __FUNCTION__, dev->base_addr, dev->irq);
 
 
 	netif_start_queue(dev);
 
-	// test interrupt handler
+	/* test interrupt handler */
 	outl(MIPSNET_INTCTL_TESTBIT,
 	     mipsnet_reg_address(dev, interruptControl));
 
@@ -199,8 +200,6 @@ static int mipsnet_close(struct net_device *dev)
 
 static void mipsnet_set_mclist(struct net_device *dev)
 {
-	// we don't do anything
-	return;
 }
 
 static int __init mipsnet_probe(struct device *dev)
@@ -226,13 +225,13 @@ static int __init mipsnet_probe(struct device *dev)
 	 */
 	netdev->base_addr = 0x4200;
 	netdev->irq = MIPS_CPU_IRQ_BASE + MIPSCPU_INT_MB0 +
-	              inl(mipsnet_reg_address(netdev, interruptInfo));
+		      inl(mipsnet_reg_address(netdev, interruptInfo));
 
-	// Get the io region now, get irq on open()
+	/* Get the io region now, get irq on open() */
 	if (!request_region(netdev->base_addr, MIPSNET_IO_EXTENT, "mipsnet")) {
 		pr_debug("%s: %s(): IO region {start: 0x%04lux, len: %d} "
-		         "for dev is not availble.\n", netdev->name,
-		         __FUNCTION__, netdev->base_addr, MIPSNET_IO_EXTENT);
+			 "for dev is not availble.\n", netdev->name,
+			 __FUNCTION__, netdev->base_addr, MIPSNET_IO_EXTENT);
 		err = -EBUSY;
 		goto out_free_netdev;
 	}
diff --git a/drivers/net/mipsnet.h b/drivers/net/mipsnet.h
index 026c732..0132c67 100644
--- a/drivers/net/mipsnet.h
+++ b/drivers/net/mipsnet.h
@@ -9,32 +9,34 @@
 /*
  *  Id of this Net device, as seen by the core.
  */
-#define MIPS_NET_DEV_ID ((uint64_t)           \
-	                     ((uint64_t)'M'<< 0)| \
-	                     ((uint64_t)'I'<< 8)| \
-	                     ((uint64_t)'P'<<16)| \
-	                     ((uint64_t)'S'<<24)| \
-	                     ((uint64_t)'N'<<32)| \
-	                     ((uint64_t)'E'<<40)| \
-	                     ((uint64_t)'T'<<48)| \
-	                     ((uint64_t)'0'<<56))
+#define MIPS_NET_DEV_ID ((uint64_t)	   \
+			     ((uint64_t) 'M' <<  0)| \
+			     ((uint64_t) 'I' <<  8)| \
+			     ((uint64_t) 'P' << 16)| \
+			     ((uint64_t) 'S' << 24)| \
+			     ((uint64_t) 'N' << 32)| \
+			     ((uint64_t) 'E' << 40)| \
+			     ((uint64_t) 'T' << 48)| \
+			     ((uint64_t) '0' << 56))
 
 /*
  * Net status/control block as seen by sw in the core.
  * (Why not use bit fields? can't be bothered with cross-platform struct
  *  packing.)
  */
-typedef struct _net_control_block {
-	/// dev info for probing
-	///  reads as MIPSNET%d where %d is some form of version
-	uint64_t devId;		/*0x00 */
+struct net_control_block {
+	/*
+	 * dev info for probing
+	 * reads as MIPSNET%d where %d is some form of version
+	 */
+	uint64_t devId;		/* 0x00 */
 
 	/*
 	 * read only busy flag.
 	 * Set and cleared by the Net Device to indicate that an rx or a tx
 	 * is in progress.
 	 */
-	uint32_t busy;		/*0x08 */
+	uint32_t busy;		/* 0x08 */
 
 	/*
 	 * Set by the Net Device.
@@ -43,16 +45,16 @@ typedef struct _net_control_block {
 	 * rxDataBuffer.  The value will decrease till 0 until all the data
 	 * from rxDataBuffer has been read.
 	 */
-	uint32_t rxDataCount;	/*0x0c */
+	uint32_t rxDataCount;	/* 0x0c */
 #define MIPSNET_MAX_RXTX_DATACOUNT (1<<16)
 
 	/*
-	 * Settable from the MIPS core, cleared by the Net Device.
-	 * The core should set the number of bytes it wants to send,
-	 *   then it should write those bytes of data to txDataBuffer.
-	 * The device will clear txDataCount has been processed (not necessarily sent).
+	 * Settable from the MIPS core, cleared by the Net Device.  The core
+	 * should set the number of bytes it wants to send, then it should
+	 * write those bytes of data to txDataBuffer.  The device will clear
+	 * txDataCount has been processed (not necessarily sent).
 	 */
-	uint32_t txDataCount;	/*0x10 */
+	uint32_t txDataCount;	/* 0x10 */
 
 	/*
 	 * Interrupt control
@@ -69,39 +71,42 @@ typedef struct _net_control_block {
 	 *    To clear the test interrupt, write 0 to this register.
 	 */
 	uint32_t interruptControl;	/*0x14 */
-#define MIPSNET_INTCTL_TXDONE     ((uint32_t)(1<< 0))
-#define MIPSNET_INTCTL_RXDONE     ((uint32_t)(1<< 1))
-#define MIPSNET_INTCTL_TESTBIT    ((uint32_t)(1<<31))
-#define MIPSNET_INTCTL_ALLSOURCES (MIPSNET_INTCTL_TXDONE|MIPSNET_INTCTL_RXDONE|MIPSNET_INTCTL_TESTBIT)
+#define MIPSNET_INTCTL_TXDONE     ((uint32_t)(1 <<  0))
+#define MIPSNET_INTCTL_RXDONE     ((uint32_t)(1 <<  1))
+#define MIPSNET_INTCTL_TESTBIT    ((uint32_t)(1 << 31))
+#define MIPSNET_INTCTL_ALLSOURCES	(MIPSNET_INTCTL_TXDONE | \
+					 MIPSNET_INTCTL_RXDONE | \
+					 MIPSNET_INTCTL_TESTBIT)
 
 	/*
-	 * Readonly core-specific interrupt info for the device to signal the core.
-	 * The meaning of the contents of this field might change.
-	 */
-	/*###\todo: the whole memIntf interrupt scheme is messy: the device should have
-	 *  no control what so ever of what VPE/register set is being used.
-	 *  The MemIntf should only expose interrupt lines, and something in the
-	 *  config should be responsible for the line<->core/vpe bindings.
+	 * Readonly core-specific interrupt info for the device to signal the
+	 * core.  The meaning of the contents of this field might change.
+	 *
+	 * TODO: the whole memIntf interrupt scheme is messy: the device should
+	 *       have no control what so ever of what VPE/register set is being
+	 *       used.  The MemIntf should only expose interrupt lines, and
+	 *       something in the config should be responsible for the
+	 *       line<->core/vpe bindings.
 	 */
-	uint32_t interruptInfo;	/*0x18 */
+	uint32_t interruptInfo;	/* 0x18 */
 
 	/*
 	 *  This is where the received data is read out.
 	 *  There is more data to read until rxDataReady is 0.
 	 *  Only 1 byte at this regs offset is used.
 	 */
-	uint32_t rxDataBuffer;	/*0x1c */
+	uint32_t rxDataBuffer;	/* 0x1c */
 
 	/*
-	 * This is where the data to transmit is written.
-	 * Data should be written for the amount specified in the txDataCount register.
-	 *  Only 1 byte at this regs offset is used.
+	 * This is where the data to transmit is written.  Data should be
+	 * written for the amount specified in the txDataCount register.  Only
+	 * 1 byte at this regs offset is used.
 	 */
-	uint32_t txDataBuffer;	/*0x20 */
-} MIPS_T_NetControl;
+	uint32_t txDataBuffer;	/* 0x20 */
+};
 
 #define MIPSNET_IO_EXTENT 0x40	/* being generous */
 
-#define field_offset(field) ((int)&((MIPS_T_NetControl*)(0))->field)
+#define field_offset(field) (offsetof(struct net_control_block, field))
 
 #endif /* __MIPSNET_H */
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index e8afa10..64c8151 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.2-1.269"
+#define MYRI10GE_VERSION_STR "1.3.2-1.287"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -214,6 +214,8 @@ struct myri10ge_priv {
 	unsigned long serial_number;
 	int vendor_specific_offset;
 	int fw_multicast_support;
+	unsigned long features;
+	u32 max_tso6;
 	u32 read_dma;
 	u32 write_dma;
 	u32 read_write_dma;
@@ -311,6 +313,7 @@ MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled\n");
 #define myri10ge_pio_copy(to,from,size) __iowrite64_copy(to,from,size/8)
 
 static void myri10ge_set_multicast_list(struct net_device *dev);
+static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev);
 
 static inline void put_be32(__be32 val, __be32 __iomem * p)
 {
@@ -612,6 +615,7 @@ static int myri10ge_load_firmware(struct myri10ge_priv *mgp)
 	__be32 buf[16];
 	u32 dma_low, dma_high, size;
 	int status, i;
+	struct myri10ge_cmd cmd;
 
 	size = 0;
 	status = myri10ge_load_hotplug_firmware(mgp, &size);
@@ -688,6 +692,14 @@ static int myri10ge_load_firmware(struct myri10ge_priv *mgp)
 	dev_info(&mgp->pdev->dev, "handoff confirmed\n");
 	myri10ge_dummy_rdma(mgp, 1);
 
+	/* probe for IPv6 TSO support */
+	mgp->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
+				   &cmd, 0);
+	if (status == 0) {
+		mgp->max_tso6 = cmd.data0;
+		mgp->features |= NETIF_F_TSO6;
+	}
 	return 0;
 }
 
@@ -1047,7 +1059,8 @@ myri10ge_rx_done(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 
 	hlen = MYRI10GE_HLEN > len ? len : MYRI10GE_HLEN;
 
-	/* allocate an skb to attach the page(s) to. */
+	/* allocate an skb to attach the page(s) to. This is done
+	 * after trying LRO, so as to avoid skb allocation overheads */
 
 	skb = netdev_alloc_skb(dev, MYRI10GE_HLEN + 16);
 	if (unlikely(skb == NULL)) {
@@ -1217,7 +1230,8 @@ static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 
 static int myri10ge_poll(struct napi_struct *napi, int budget)
 {
-	struct myri10ge_priv *mgp = container_of(napi, struct myri10ge_priv, napi);
+	struct myri10ge_priv *mgp =
+	    container_of(napi, struct myri10ge_priv, napi);
 	struct net_device *netdev = mgp->dev;
 	struct myri10ge_rx_done *rx_done = &mgp->rx_done;
 	int work_done;
@@ -1382,6 +1396,18 @@ static int myri10ge_set_rx_csum(struct net_device *netdev, u32 csum_enabled)
 	return 0;
 }
 
+static int myri10ge_set_tso(struct net_device *netdev, u32 tso_enabled)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	unsigned long flags = mgp->features & (NETIF_F_TSO6 | NETIF_F_TSO);
+
+	if (tso_enabled)
+		netdev->features |= flags;
+	else
+		netdev->features &= ~flags;
+	return 0;
+}
+
 static const char myri10ge_gstrings_stats[][ETH_GSTRING_LEN] = {
 	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
 	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
@@ -1506,7 +1532,7 @@ static const struct ethtool_ops myri10ge_ethtool_ops = {
 	.set_rx_csum = myri10ge_set_rx_csum,
 	.set_tx_csum = ethtool_op_set_tx_hw_csum,
 	.set_sg = ethtool_op_set_sg,
-	.set_tso = ethtool_op_set_tso,
+	.set_tso = myri10ge_set_tso,
 	.get_link = ethtool_op_get_link,
 	.get_strings = myri10ge_get_strings,
 	.get_sset_count = myri10ge_get_sset_count,
@@ -2164,7 +2190,8 @@ again:
 		pseudo_hdr_offset = cksum_offset + skb->csum_offset;
 		/* If the headers are excessively large, then we must
 		 * fall back to a software checksum */
-		if (unlikely(cksum_offset > 255 || pseudo_hdr_offset > 127)) {
+		if (unlikely(!mss && (cksum_offset > 255 ||
+				      pseudo_hdr_offset > 127))) {
 			if (skb_checksum_help(skb))
 				goto drop;
 			cksum_offset = 0;
@@ -2184,9 +2211,18 @@ again:
 		/* negative cum_len signifies to the
 		 * send loop that we are still in the
 		 * header portion of the TSO packet.
-		 * TSO header must be at most 134 bytes long */
+		 * TSO header can be at most 1KB long */
 		cum_len = -(skb_transport_offset(skb) + tcp_hdrlen(skb));
 
+		/* for IPv6 TSO, the checksum offset stores the
+		 * TCP header length, to save the firmware from
+		 * the need to parse the headers */
+		if (skb_is_gso_v6(skb)) {
+			cksum_offset = tcp_hdrlen(skb);
+			/* Can only handle headers <= max_tso6 long */
+			if (unlikely(-cum_len > mgp->max_tso6))
+				return myri10ge_sw_tso(skb, dev);
+		}
 		/* for TSO, pseudo_hdr_offset holds mss.
 		 * The firmware figures out where to put
 		 * the checksum by parsing the header. */
@@ -2301,10 +2337,12 @@ again:
 			req++;
 			count++;
 			rdma_count++;
-			if (unlikely(cksum_offset > seglen))
-				cksum_offset -= seglen;
-			else
-				cksum_offset = 0;
+			if (cksum_offset != 0 && !(mss && skb_is_gso_v6(skb))) {
+				if (unlikely(cksum_offset > seglen))
+					cksum_offset -= seglen;
+				else
+					cksum_offset = 0;
+			}
 		}
 		if (frag_idx == frag_cnt)
 			break;
@@ -2387,6 +2425,41 @@ drop:
 
 }
 
+static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sk_buff *segs, *curr;
+	struct myri10ge_priv *mgp = dev->priv;
+	int status;
+
+	segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO6);
+	if (unlikely(IS_ERR(segs)))
+		goto drop;
+
+	while (segs) {
+		curr = segs;
+		segs = segs->next;
+		curr->next = NULL;
+		status = myri10ge_xmit(curr, dev);
+		if (status != 0) {
+			dev_kfree_skb_any(curr);
+			if (segs != NULL) {
+				curr = segs;
+				segs = segs->next;
+				curr->next = NULL;
+				dev_kfree_skb_any(segs);
+			}
+			goto drop;
+		}
+	}
+	dev_kfree_skb_any(skb);
+	return 0;
+
+drop:
+	dev_kfree_skb_any(skb);
+	mgp->stats.tx_dropped += 1;
+	return 0;
+}
+
 static struct net_device_stats *myri10ge_get_stats(struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
@@ -2706,7 +2779,6 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 }
 
 #ifdef CONFIG_PM
-
 static int myri10ge_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct myri10ge_priv *mgp;
@@ -2787,7 +2859,6 @@ abort_with_enabled:
 	return -EIO;
 
 }
-
 #endif				/* CONFIG_PM */
 
 static u32 myri10ge_read_reboot(struct myri10ge_priv *mgp)
@@ -2954,8 +3025,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	mgp = netdev_priv(netdev);
 	mgp->dev = netdev;
-	netif_napi_add(netdev, &mgp->napi,
-		       myri10ge_poll, myri10ge_napi_weight);
+	netif_napi_add(netdev, &mgp->napi, myri10ge_poll, myri10ge_napi_weight);
 	mgp->pdev = pdev;
 	mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
 	mgp->pause = myri10ge_flow_control;
@@ -3077,7 +3147,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->change_mtu = myri10ge_change_mtu;
 	netdev->set_multicast_list = myri10ge_set_multicast_list;
 	netdev->set_mac_address = myri10ge_set_mac_address;
-	netdev->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
+	netdev->features = mgp->features;
 	if (dac_enabled)
 		netdev->features |= NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/myri10ge/myri10ge_mcp.h b/drivers/net/myri10ge/myri10ge_mcp.h
index a1d2a22..58e5717 100644
--- a/drivers/net/myri10ge/myri10ge_mcp.h
+++ b/drivers/net/myri10ge/myri10ge_mcp.h
@@ -10,7 +10,7 @@ struct mcp_dma_addr {
 	__be32 low;
 };
 
-/* 4 Bytes */
+/* 4 Bytes.  8 Bytes for NDIS drivers. */
 struct mcp_slot {
 	__sum16 checksum;
 	__be16 length;
@@ -205,8 +205,87 @@ enum myri10ge_mcp_cmd_type {
 	/* same than DMA_TEST (same args) but abort with UNALIGNED on unaligned
 	 * chipset */
 
-	MXGEFW_CMD_UNALIGNED_STATUS
-	    /* return data = boolean, true if the chipset is known to be unaligned */
+	MXGEFW_CMD_UNALIGNED_STATUS,
+	/* return data = boolean, true if the chipset is known to be unaligned */
+
+	MXGEFW_CMD_ALWAYS_USE_N_BIG_BUFFERS,
+	/* data0 = number of big buffers to use.  It must be 0 or a power of 2.
+	 * 0 indicates that the NIC consumes as many buffers as they are required
+	 * for packet. This is the default behavior.
+	 * A power of 2 number indicates that the NIC always uses the specified
+	 * number of buffers for each big receive packet.
+	 * It is up to the driver to ensure that this value is big enough for
+	 * the NIC to be able to receive maximum-sized packets.
+	 */
+
+	MXGEFW_CMD_GET_MAX_RSS_QUEUES,
+	MXGEFW_CMD_ENABLE_RSS_QUEUES,
+	/* data0 = number of slices n (0, 1, ..., n-1) to enable
+	 * data1 = interrupt mode. 0=share one INTx/MSI, 1=use one MSI-X per queue.
+	 * If all queues share one interrupt, the driver must have set
+	 * RSS_SHARED_INTERRUPT_DMA before enabling queues.
+	 */
+	MXGEFW_CMD_GET_RSS_SHARED_INTERRUPT_MASK_OFFSET,
+	MXGEFW_CMD_SET_RSS_SHARED_INTERRUPT_DMA,
+	/* data0, data1 = bus address lsw, msw */
+	MXGEFW_CMD_GET_RSS_TABLE_OFFSET,
+	/* get the offset of the indirection table */
+	MXGEFW_CMD_SET_RSS_TABLE_SIZE,
+	/* set the size of the indirection table */
+	MXGEFW_CMD_GET_RSS_KEY_OFFSET,
+	/* get the offset of the secret key */
+	MXGEFW_CMD_RSS_KEY_UPDATED,
+	/* tell nic that the secret key's been updated */
+	MXGEFW_CMD_SET_RSS_ENABLE,
+	/* data0 = enable/disable rss
+	 * 0: disable rss.  nic does not distribute receive packets.
+	 * 1: enable rss.  nic distributes receive packets among queues.
+	 * data1 = hash type
+	 * 1: IPV4
+	 * 2: TCP_IPV4
+	 * 3: IPV4 | TCP_IPV4
+	 */
+
+	MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
+	/* Return data = the max. size of the entire headers of a IPv6 TSO packet.
+	 * If the header size of a IPv6 TSO packet is larger than the specified
+	 * value, then the driver must not use TSO.
+	 * This size restriction only applies to IPv6 TSO.
+	 * For IPv4 TSO, the maximum size of the headers is fixed, and the NIC
+	 * always has enough header buffer to store maximum-sized headers.
+	 */
+
+	MXGEFW_CMD_SET_TSO_MODE,
+	/* data0 = TSO mode.
+	 * 0: Linux/FreeBSD style (NIC default)
+	 * 1: NDIS/NetBSD style
+	 */
+
+	MXGEFW_CMD_MDIO_READ,
+	/* data0 = dev_addr (PMA/PMD or PCS ...), data1 = register/addr */
+	MXGEFW_CMD_MDIO_WRITE,
+	/* data0 = dev_addr,  data1 = register/addr, data2 = value  */
+
+	MXGEFW_CMD_XFP_I2C_READ,
+	/* Starts to get a fresh copy of one byte or of the whole xfp i2c table, the
+	 * obtained data is cached inside the xaui-xfi chip :
+	 *   data0 : "all" flag : 0 => get one byte, 1=> get 256 bytes,
+	 *   data1 : if (data0 == 0): index of byte to refresh [ not used otherwise ]
+	 * The operation might take ~1ms for a single byte or ~65ms when refreshing all 256 bytes
+	 * During the i2c operation,  MXGEFW_CMD_XFP_I2C_READ or MXGEFW_CMD_XFP_BYTE attempts
+	 *  will return MXGEFW_CMD_ERROR_BUSY
+	 */
+	MXGEFW_CMD_XFP_BYTE,
+	/* Return the last obtained copy of a given byte in the xfp i2c table
+	 * (copy cached during the last relevant MXGEFW_CMD_XFP_I2C_READ)
+	 *   data0 : index of the desired table entry
+	 *  Return data = the byte stored at the requested index in the table
+	 */
+
+	MXGEFW_CMD_GET_VPUMP_OFFSET,
+	/* Return data = NIC memory offset of mcp_vpump_public_global */
+	MXGEFW_CMD_RESET_VPUMP,
+	/* Resets the VPUMP state */
 };
 
 enum myri10ge_mcp_cmd_status {
@@ -220,7 +299,10 @@ enum myri10ge_mcp_cmd_status {
 	MXGEFW_CMD_ERROR_BAD_PORT,
 	MXGEFW_CMD_ERROR_RESOURCES,
 	MXGEFW_CMD_ERROR_MULTICAST,
-	MXGEFW_CMD_ERROR_UNALIGNED
+	MXGEFW_CMD_ERROR_UNALIGNED,
+	MXGEFW_CMD_ERROR_NO_MDIO,
+	MXGEFW_CMD_ERROR_XFP_FAILURE,
+	MXGEFW_CMD_ERROR_XFP_ABSENT
 };
 
 #define MXGEFW_OLD_IRQ_DATA_LEN 40
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 527f9dc..50e1ec6 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -1576,7 +1576,7 @@ static int netdev_open(struct net_device *dev)
 
 	/* Set the timer to check for link beat. */
 	init_timer(&np->timer);
-	np->timer.expires = jiffies + NATSEMI_TIMER_FREQ;
+	np->timer.expires = round_jiffies(jiffies + NATSEMI_TIMER_FREQ);
 	np->timer.data = (unsigned long)dev;
 	np->timer.function = &netdev_timer; /* timer handler */
 	add_timer(&np->timer);
@@ -1856,7 +1856,11 @@ static void netdev_timer(unsigned long data)
 			next_tick = 1;
 		}
 	}
-	mod_timer(&np->timer, jiffies + next_tick);
+
+	if (next_tick > 1)
+		mod_timer(&np->timer, round_jiffies(jiffies + next_tick));
+	else
+		mod_timer(&np->timer, jiffies + next_tick);
 }
 
 static void dump_ring(struct net_device *dev)
@@ -3310,13 +3314,19 @@ static int natsemi_resume (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
 	struct netdev_private *np = netdev_priv(dev);
+	int ret = 0;
 
 	rtnl_lock();
 	if (netif_device_present(dev))
 		goto out;
 	if (netif_running(dev)) {
 		BUG_ON(!np->hands_off);
-		pci_enable_device(pdev);
+		ret = pci_enable_device(pdev);
+		if (ret < 0) {
+			dev_err(&pdev->dev,
+				"pci_enable_device() failed: %d\n", ret);
+			goto out;
+		}
 	/*	pci_power_on(pdev); */
 
 		napi_enable(&np->napi);
@@ -3331,12 +3341,12 @@ static int natsemi_resume (struct pci_dev *pdev)
 		spin_unlock_irq(&np->lock);
 		enable_irq(dev->irq);
 
-		mod_timer(&np->timer, jiffies + 1*HZ);
+		mod_timer(&np->timer, round_jiffies(jiffies + 1*HZ));
 	}
 	netif_device_attach(dev);
 out:
 	rtnl_unlock();
-	return 0;
+	return ret;
 }
 
 #endif /* CONFIG_PM */
diff --git a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
index 368f256..fbc7531 100644
--- a/drivers/net/ne-h8300.c
+++ b/drivers/net/ne-h8300.c
@@ -93,7 +93,7 @@ static int __init init_reg_offset(struct net_device *dev,unsigned long base_addr
 	bus_width = *(volatile unsigned char *)ABWCR;
 	bus_width &= 1 << ((base_addr >> 21) & 7);
 
-	for (i = 0; i < sizeof(reg_offset) / sizeof(u32); i++)
+	for (i = 0; i < ARRAY_SIZE(reg_offset); i++)
 		if (bus_width == 0)
 			reg_offset[i] = i * 2 + 1;
 		else
@@ -115,7 +115,7 @@ static int h8300_ne_irq[] = {EXT_IRQ5};
 
 static inline int init_dev(struct net_device *dev)
 {
-	if (h8300_ne_count < (sizeof(h8300_ne_base) / sizeof(unsigned long))) {
+	if (h8300_ne_count < ARRAY_SIZE(h8300_ne_base)) {
 		dev->base_addr = h8300_ne_base[h8300_ne_count];
 		dev->irq       = h8300_ne_irq[h8300_ne_count];
 		h8300_ne_count++;
diff --git a/drivers/net/saa9730.c b/drivers/net/saa9730.c
index 14361e8..c65199d 100644
--- a/drivers/net/saa9730.c
+++ b/drivers/net/saa9730.c
@@ -97,13 +97,16 @@ static void evm_saa9730_unblock_lan_int(struct lan_saa9730_private *lp)
 	       &lp->evm_saa9730_regs->InterruptBlock1);
 }
 
-static void __attribute_used__ show_saa9730_regs(struct lan_saa9730_private *lp)
+static void __used show_saa9730_regs(struct net_device *dev)
 {
+	struct lan_saa9730_private *lp = netdev_priv(dev);
 	int i, j;
+
 	printk("TxmBufferA = %p\n", lp->TxmBuffer[0][0]);
 	printk("TxmBufferB = %p\n", lp->TxmBuffer[1][0]);
 	printk("RcvBufferA = %p\n", lp->RcvBuffer[0][0]);
 	printk("RcvBufferB = %p\n", lp->RcvBuffer[1][0]);
+
 	for (i = 0; i < LAN_SAA9730_BUFFERS; i++) {
 		for (j = 0; j < LAN_SAA9730_TXM_Q_SIZE; j++) {
 			printk("TxmBuffer[%d][%d] = %x\n", i, j,
@@ -146,11 +149,13 @@ static void __attribute_used__ show_saa9730_regs(struct lan_saa9730_private *lp)
 	       readl(&lp->lan_saa9730_regs->RxCtl));
 	printk("lp->lan_saa9730_regs->RxStatus = %x\n",
 	       readl(&lp->lan_saa9730_regs->RxStatus));
+
 	for (i = 0; i < LAN_SAA9730_CAM_DWORDS; i++) {
 		writel(i, &lp->lan_saa9730_regs->CamAddress);
 		printk("lp->lan_saa9730_regs->CamData = %x\n",
 		       readl(&lp->lan_saa9730_regs->CamData));
 	}
+
 	printk("dev->stats.tx_packets = %lx\n", dev->stats.tx_packets);
 	printk("dev->stats.tx_errors = %lx\n", dev->stats.tx_errors);
 	printk("dev->stats.tx_aborted_errors = %lx\n",
@@ -855,7 +860,7 @@ static void lan_saa9730_tx_timeout(struct net_device *dev)
 	/* Transmitter timeout, serious problems */
 	dev->stats.tx_errors++;
 	printk("%s: transmit timed out, reset\n", dev->name);
-	/*show_saa9730_regs(lp); */
+	/*show_saa9730_regs(dev); */
 	lan_saa9730_restart(lp);
 
 	dev->trans_start = jiffies;
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index a679f43..8038f28 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1461,7 +1461,6 @@ static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
 	}
 	return IRQ_NONE;
 #else
-	struct tc35815_local *lp = dev->priv;
 	int handled;
 	u32 status;
 
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 8d04654..4e1b84e 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1906,7 +1906,7 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
     /************** pci *****************/
 	if ((err = pci_enable_device(pdev)))	/* it trigers interrupt, dunno why. */
-		RET(err);			/* it's not a problem though */
+		goto err_pci;			/* it's not a problem though */
 
 	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
 	    !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
@@ -2076,6 +2076,7 @@ err_out_res:
 	pci_release_regions(pdev);
 err_dma:
 	pci_disable_device(pdev);
+err_pci:
 	vfree(nic);
 
 	RET(err);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 30b1cca..76efb3f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9034,7 +9034,7 @@ static int tg3_do_mem_test(struct tg3 *tp, u32 offset, u32 len)
 	int i;
 	u32 j;
 
-	for (i = 0; i < sizeof(test_pattern)/sizeof(u32); i++) {
+	for (i = 0; i < ARRAY_SIZE(test_pattern); i++) {
 		for (j = 0; j < len; j += 4) {
 			u32 val;
 
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 9b9cd83..41f34bb 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1041,7 +1041,7 @@ static struct InfoLeaf infoleaf_array[] = {
     {DC21142, dc21142_infoleaf},
     {DC21143, dc21143_infoleaf}
 };
-#define INFOLEAF_SIZE (sizeof(infoleaf_array)/(sizeof(int)+sizeof(int *)))
+#define INFOLEAF_SIZE ARRAY_SIZE(infoleaf_array)
 
 /*
 ** List the SROM info block functions
@@ -1056,7 +1056,7 @@ static int (*dc_infoblock[])(struct net_device *dev, u_char, u_char *) = {
     compact_infoblock
 };
 
-#define COMPACT (sizeof(dc_infoblock)/sizeof(int *) - 1)
+#define COMPACT (ARRAY_SIZE(dc_infoblock) - 1)
 
 /*
 ** Miscellaneous defines...
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index d00e7d4..bec413b 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -63,7 +63,7 @@
 #define UGETH_MSG_DEFAULT	(NETIF_MSG_IFUP << 1 ) - 1
 
 void uec_set_ethtool_ops(struct net_device *netdev);
-	
+
 static DEFINE_SPINLOCK(ugeth_lock);
 
 static struct {
@@ -3454,9 +3454,12 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 	u16 length, howmany = 0;
 	u32 bd_status;
 	u8 *bdBuffer;
+	struct net_device * dev;
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
+	dev = ugeth->dev;
+
 	/* collect received buffers */
 	bd = ugeth->rxBd[rxQ];
 
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index b39a541..05df0a3 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -1342,11 +1342,11 @@ static int sdla_set_config(struct net_device *dev, struct ifmap *map)
 	if (flp->initialized)
 		return(-EINVAL);
 
-	for(i=0;i < sizeof(valid_port) / sizeof (int) ; i++)
+	for(i=0; i < ARRAY_SIZE(valid_port); i++)
 		if (valid_port[i] == map->base_addr)
 			break;   
 
-	if (i == sizeof(valid_port) / sizeof(int))
+	if (i == ARRAY_SIZE(valid_port))
 		return(-EINVAL);
 
 	if (!request_region(map->base_addr, SDLA_IO_EXTENTS, dev->name)){
@@ -1487,12 +1487,12 @@ got_type:
 		}
 	}
 
-	for(i=0;i < sizeof(valid_mem) / sizeof (int) ; i++)
+	for(i=0; i < ARRAY_SIZE(valid_mem); i++)
 		if (valid_mem[i] == map->mem_start)
 			break;   
 
 	err = -EINVAL;
-	if (i == sizeof(valid_mem) / sizeof(int))
+	if (i == ARRAY_SIZE(valid_mem))
 		goto fail2;
 
 	if (flp->type == SDLA_S502A && (map->mem_start & 0xF000) >> 12 == 0x0E)
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f464b82..7fd505c 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -74,22 +74,12 @@ struct netfront_info {
 
 	struct napi_struct napi;
 
-	struct xen_netif_tx_front_ring tx;
-	struct xen_netif_rx_front_ring rx;
-
-	spinlock_t   tx_lock;
-	spinlock_t   rx_lock;
-
 	unsigned int evtchn;
+	struct xenbus_device *xbdev;
 
-	/* Receive-ring batched refills. */
-#define RX_MIN_TARGET 8
-#define RX_DFL_MIN_TARGET 64
-#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
-	unsigned rx_min_target, rx_max_target, rx_target;
-	struct sk_buff_head rx_batch;
-
-	struct timer_list rx_refill_timer;
+	spinlock_t   tx_lock;
+	struct xen_netif_tx_front_ring tx;
+	int tx_ring_ref;
 
 	/*
 	 * {tx,rx}_skbs store outstanding skbuffs. Free tx_skb entries
@@ -108,14 +98,23 @@ struct netfront_info {
 	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE];
 	unsigned tx_skb_freelist;
 
+	spinlock_t   rx_lock ____cacheline_aligned_in_smp;
+	struct xen_netif_rx_front_ring rx;
+	int rx_ring_ref;
+
+	/* Receive-ring batched refills. */
+#define RX_MIN_TARGET 8
+#define RX_DFL_MIN_TARGET 64
+#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+	unsigned rx_min_target, rx_max_target, rx_target;
+	struct sk_buff_head rx_batch;
+
+	struct timer_list rx_refill_timer;
+
 	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
 	grant_ref_t gref_rx_head;
 	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
 
-	struct xenbus_device *xbdev;
-	int tx_ring_ref;
-	int rx_ring_ref;
-
 	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
 	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
 	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
diff --git a/include/asm-mips/mach-au1x00/prom.h b/include/asm-mips/mach-au1x00/prom.h
new file mode 100644
index 0000000..e387155
--- /dev/null
+++ b/include/asm-mips/mach-au1x00/prom.h
@@ -0,0 +1,13 @@
+#ifndef __AU1X00_PROM_H
+#define __AU1X00_PROM_H
+
+extern int prom_argc;
+extern char **prom_argv;
+extern char **prom_envp;
+
+extern void prom_init_cmdline(void);
+extern char *prom_getcmdline(void);
+extern char *prom_getenv(char *envname);
+extern int prom_get_ethernet_addr(char *ethernet_addr);
+
+#endif
diff --git a/include/asm-powerpc/dcr-mmio.h b/include/asm-powerpc/dcr-mmio.h
index 6b82c3b..08532ff 100644
--- a/include/asm-powerpc/dcr-mmio.h
+++ b/include/asm-powerpc/dcr-mmio.h
@@ -33,16 +33,16 @@ typedef struct {
 
 extern dcr_host_t dcr_map(struct device_node *dev, unsigned int dcr_n,
 			  unsigned int dcr_c);
-extern void dcr_unmap(dcr_host_t host, unsigned int dcr_n, unsigned int dcr_c);
+extern void dcr_unmap(dcr_host_t host, unsigned int dcr_c);
 
 static inline u32 dcr_read(dcr_host_t host, unsigned int dcr_n)
 {
-	return in_be32(host.token + dcr_n * host.stride);
+	return in_be32(host.token + ((host.base + dcr_n) * host.stride));
 }
 
 static inline void dcr_write(dcr_host_t host, unsigned int dcr_n, u32 value)
 {
-	out_be32(host.token + dcr_n * host.stride, value);
+	out_be32(host.token + ((host.base + dcr_n) * host.stride), value);
 }
 
 extern u64 of_translate_dcr_address(struct device_node *dev,
diff --git a/include/asm-powerpc/dcr-native.h b/include/asm-powerpc/dcr-native.h
index f41058c..8dbb1ab 100644
--- a/include/asm-powerpc/dcr-native.h
+++ b/include/asm-powerpc/dcr-native.h
@@ -29,9 +29,9 @@ typedef struct {
 #define DCR_MAP_OK(host)	(1)
 
 #define dcr_map(dev, dcr_n, dcr_c)	((dcr_host_t){ .base = (dcr_n) })
-#define dcr_unmap(host, dcr_n, dcr_c)	do {} while (0)
-#define dcr_read(host, dcr_n)		mfdcr(dcr_n)
-#define dcr_write(host, dcr_n, value)	mtdcr(dcr_n, value)
+#define dcr_unmap(host, dcr_c)		do {} while (0)
+#define dcr_read(host, dcr_n)		mfdcr(dcr_n + host.base)
+#define dcr_write(host, dcr_n, value)	mtdcr(dcr_n + host.base, value)
 
 /* Device Control Registers */
 void __mtdcr(int reg, unsigned int val);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a656cec..8101e8b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1781,6 +1781,11 @@ static inline int skb_is_gso(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_size;
 }
 
+static inline int skb_is_gso_v6(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6;
+}
+
 static inline void skb_forward_csum(struct sk_buff *skb)
 {
 	/* Unfortunately we don't support this one.  Any brave souls? */
