From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 04/12] NET: depca: Fix bucketload full of section mismatches.
Date: Sun, 26 Jun 2011 12:23:00 +0100
Message-ID: <1a64483db2fd8cb2879ae148b0eab2eb6797ba0b.1309182743.git.ralf@linux-mips.org>
References: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WARNING: drivers/net/depca.o(.data+0x34): Section mismatch in reference from the variable depca_eisa_driver to the function .init.text:depca_eisa_probe()
The variable depca_eisa_driver references
the function __init depca_eisa_probe()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console

WARNING: drivers/net/depca.o(.devinit.text+0x2c): Section mismatch in reference from the function depca_isa_probe() to the function .init.text:depca_common_init()
The function __devinit depca_isa_probe() references
a function __init depca_common_init().
If depca_common_init is only used by depca_isa_probe then
annotate depca_common_init with a matching annotation.

WARNING: drivers/net/depca.o(.devinit.text+0x44): Section mismatch in reference from the function depca_isa_probe() to the function .init.text:depca_shmem_probe()
The function __devinit depca_isa_probe() references
a function __init depca_shmem_probe().
If depca_shmem_probe is only used by depca_isa_probe then
annotate depca_shmem_probe with a matching annotation.

WARNING: drivers/net/depca.o(.devinit.text+0x8c): Section mismatch in reference from the function depca_isa_probe() to the function .init.text:depca_hw_init()
The function __devinit depca_isa_probe() references
a function __init depca_hw_init().
If depca_hw_init is only used by depca_isa_probe then
annotate depca_hw_init with a matching annotation.

Fixing these in turn triggers yet more mismatches, fix those as well.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
---
 drivers/net/depca.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 8b0084d..d40536a 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -331,7 +331,7 @@ static struct {
                          "DE422",\
                          ""}
 
-static char* __initdata depca_signature[] = DEPCA_SIGNATURE;
+static char* __devinitdata depca_signature[] = DEPCA_SIGNATURE;
 
 enum depca_type {
 	DEPCA, de100, de101, de200, de201, de202, de210, de212, de422, unknown
@@ -541,9 +541,9 @@ static void SetMulticastFilter(struct net_device *dev);
 static int load_packet(struct net_device *dev, struct sk_buff *skb);
 static void depca_dbg_open(struct net_device *dev);
 
-static u_char de1xx_irq[] __initdata = { 2, 3, 4, 5, 7, 9, 0 };
-static u_char de2xx_irq[] __initdata = { 5, 9, 10, 11, 15, 0 };
-static u_char de422_irq[] __initdata = { 5, 9, 10, 11, 0 };
+static u_char de1xx_irq[] __devinitdata = { 2, 3, 4, 5, 7, 9, 0 };
+static u_char de2xx_irq[] __devinitdata = { 5, 9, 10, 11, 15, 0 };
+static u_char de422_irq[] __devinitdata = { 5, 9, 10, 11, 0 };
 static u_char *depca_irq;
 
 static int irq;
@@ -580,7 +580,8 @@ static const struct net_device_ops depca_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __init depca_hw_init (struct net_device *dev, struct device *device)
+static int __devinit depca_hw_init (struct net_device *dev,
+	struct device *device)
 {
 	struct depca_private *lp;
 	int i, j, offset, netRAM, mem_len, status = 0;
@@ -1302,7 +1303,7 @@ static void SetMulticastFilter(struct net_device *dev)
 	}
 }
 
-static int __init depca_common_init (u_long ioaddr, struct net_device **devp)
+static int __devinit depca_common_init (u_long ioaddr, struct net_device **devp)
 {
 	int status = 0;
 
@@ -1333,7 +1334,7 @@ static int __init depca_common_init (u_long ioaddr, struct net_device **devp)
 /*
 ** Microchannel bus I/O device probe
 */
-static int __init depca_mca_probe(struct device *device)
+static int __devinit depca_mca_probe(struct device *device)
 {
 	unsigned char pos[2];
 	unsigned char where;
@@ -1497,7 +1498,7 @@ static void __init depca_platform_probe (void)
 	}
 }
 
-static enum depca_type __init depca_shmem_probe (ulong *mem_start)
+static enum depca_type __devinit depca_shmem_probe (ulong *mem_start)
 {
 	u_long mem_base[] = DEPCA_RAM_BASE_ADDRESSES;
 	enum depca_type adapter = unknown;
@@ -1558,7 +1559,7 @@ static int __devinit depca_isa_probe (struct platform_device *device)
 */
 
 #ifdef CONFIG_EISA
-static int __init depca_eisa_probe (struct device *device)
+static int __devinit depca_eisa_probe (struct device *device)
 {
 	enum depca_type adapter = unknown;
 	struct eisa_device *edev;
@@ -1629,7 +1630,7 @@ static int __devexit depca_device_remove (struct device *device)
 ** and Boot (readb) ROM. This will also give us a clue to the network RAM
 ** base address.
 */
-static int __init DepcaSignature(char *name, u_long base_addr)
+static int __devinit DepcaSignature(char *name, u_long base_addr)
 {
 	u_int i, j, k;
 	void __iomem *ptr;
@@ -1698,7 +1699,7 @@ static int __init DepcaSignature(char *name, u_long base_addr)
 ** PROM address counter is correctly positioned at the start of the
 ** ethernet address for later read out.
 */
-static int __init DevicePresent(u_long ioaddr)
+static int __devinit DevicePresent(u_long ioaddr)
 {
 	union {
 		struct {
@@ -1751,7 +1752,7 @@ static int __init DevicePresent(u_long ioaddr)
 ** reason: access the upper half of the PROM with x=0; access the lower half
 ** with x=1.
 */
-static int __init get_hw_addr(struct net_device *dev)
+static int __devinit get_hw_addr(struct net_device *dev)
 {
 	u_long ioaddr = dev->base_addr;
 	struct depca_private *lp = netdev_priv(dev);
-- 
1.7.4.4
