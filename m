From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: MV643xx Ethernet 2.6 driver update
Date: Thu, 27 Jan 2005 13:19:55 -0700
Message-ID: <20050127201955.GC1452@xyzzy>
References: <20050117184019.GA24655@xyzzy> <41F8BACA.1020302@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FkmkrVfFsRoUs1wW"
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <41F8BACA.1020302@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--FkmkrVfFsRoUs1wW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jan 27, 2005 at 09:56:26AM +0000, Jeff Garzik wrote:
> Ouch:

I'm sorry for the pain I caused you. :)

> When using BitKeeper, you need to make sure your changes are the only 
> ones in the tree.  It doesn't work for me to pull:
> 
> mv643xx-enet -> jgarzik-mv643xx-enet -> net-drivers-2.6 -> linus
> 
> because that would require pulling the entire netdev-2.6 tree up through 
> that chain.

Oops.  Yes, I had cloned the netdev-2.6 tree and I see why that doesn't work.

I've now put the changes into a tree cloned from linux-2.5.
I sure hope this works better Jeff.

In addition to these changesets previously submitted:
  A. Remove redundant or unneeded code.
  B. Replace fixed count spins with udelay/msleep waits on hardware status bits
  C. Fix code to enable hardware checksum generation for TX packets
  D. Convert from pci_map_* to dma_map_* interface
  E. Add device driver model support.
  F. Add support for several configurable parameters via platform_device
  G. Make use of MV64340_RX_QUEUE_FILL_ON_TASK macro consistent.
  H. Simplify mv64340_eth_set_rx_mode()
  I. Clean up receive buffer sizing
  J. Call netif_carrier_off/netif_carrier_on on a link down/up condition
  K. Add support for PHYs/boards that don't support autonegotiation.

I've added the following changesets:
  L. Remove a spurious left paren causing an obvious syntax error
     in the #ifndef MV64340_NAPI case
  M. Add a function to detect at runtime whether a PHY is attached to
     the specified port.
  N. Run mv643xx_eth.[ch] through scripts/Lindent
  O. Additional whitespace cleanups, mostly changing spaces to tabs in comments
  P. Rename MV_READ => mv_read and MV_WRITE => mv_write
  Q. Rename MV64340 => MV643XX and mv64340 => mv643xx

I've attached patches for L and M below, but omitted N-Q since they are
large and only cosmetic.

Thanks,
-Dale

Please do a

	bk pull bk://dfarnsworth.bkbits.net/linux-2.5-mv643xx-enet

This will update the following files:

 drivers/net/mv643xx_eth.c | 2398 ++++++++++++++++++++++++----------------------
 drivers/net/mv643xx_eth.h |  603 +++--------
 include/linux/mv643xx.h   |  434 ++++++--
 3 files changed, 1776 insertions(+), 1659 deletions(-)

through these ChangeSets:

<dfarnsworth@mvista.com> (05/01/27 1.1975.53.17)
   Big rename.
   
   Change MV64340 => MV643XX and mv64340 => mv643xx
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1975.53.16)
   Rename MV_READ => mv_read and MV_WRITE => mv_write
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1975.53.15)
   Additional whitespace cleanups, mostly changing spaces to tabs in comments

<dfarnsworth@mvista.com> (05/01/27 1.1975.53.14)
   Run mv643xx_eth.[ch] through scripts/Lindent
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1975.53.13)
   Add a function to detect at runtime whether a PHY is attached to
   the specified port, and use it to cause the probe routine to fail
   when there is no PHY.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1975.53.12)
   This one liner removes a spurious left paren fixing an obvious syntax error
   in the #ifndef MV64340_NAPI case

<dfarnsworth@mvista.com> (05/01/27 1.1975.53.11)
   Add support for PHYs/boards that don't support autonegotiation.
     
   Signed-off-by: Brian Waite <brian@waitefamily.us>
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1975.53.10)
   With this patch, the driver now calls netif_carrier_off/netif_carrier_on
   on a link down/up condition.
     
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1975.53.9)
   This patch cleans up the handling of receive skb sizing.
     
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1975.53.8)
   This patch simplifies the mv64340_eth_set_rx_mode function without
   changing its behavior.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1975.53.7)
   This patch makes the use of the MV64340_RX_QUEUE_FILL_ON_TASK config macro
   more consistent, though the macro remains undefined, since the feature still
   does not work properly.
           
   Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1975.53.6)
   This patch adds support for passing additional parameters via the
   platform_device interface.  These additional parameters are:
           size of RX and TX descriptor rings
           port_config value 
           port_config_extend value
           port_sdma_config value
           port_serial_control value
           PHY address                                                                                                                                             Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1975.53.5)
   This patch adds device driver model support to the mv643xx_eth driver.
   
   This is a change to the driver's programming interface.  Platform
   code must now pass in the address of the MV643xx ethernet registers
   and IRQ.  If firmware doesn't set the MAC address, platform code
   must also pass in the MAC address.
   
   Also, note that local MV_READ/MV_WRITE macros are used rather than              using global macros.  Keeping the macro names minimizes the patch size.         The names will be changed to mv_read/mv_write in a later cosmetic               cleanup patch.                                                                                                                                                  Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1975.53.4)
   This patch replaces the use of the pci_map_* functions with the
   corresponding dma_map_* functions.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1975.53.3)
   This patch fixes the code that enables hardware checksum generation.
   The previous code has so many problems that it appears to never have 
   worked 2.6.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1975.53.2)
   This patch removes spin delays (count to 1000000, ugh) and instead waits
   with udelay or msleep for hardware flags to change.
   
   It also adds a spinlock to protect access to the MV64340_ETH_SMI_REG,
   which is shared across ports.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1975.53.1)
   This patch removes code that is redundant or useless.
   The biggest area is in pre-initializing the RX and TX descriptor
   rings, which only obfuscates the driver since the ring data is
   overwritten without being used.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>


--FkmkrVfFsRoUs1wW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mp.1"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/27 12:16:27-07:00 dfarnsworth@mvista.com 
#   This one liner removes a spurious left paren fixing an obvious syntax error
#   in the #ifndef MV64340_NAPI case
# 
# drivers/net/mv643xx_eth.c
#   2005/01/27 12:16:18-07:00 dfarnsworth@mvista.com +0 -1
#   This one liner removes a spurious left paren fixing an obvious syntax error
#   in the #ifndef MV64340_NAPI case
# 
diff -Nru a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c	2005-01-27 13:12:12 -07:00
+++ b/drivers/net/mv643xx_eth.c	2005-01-27 13:12:12 -07:00
@@ -510,7 +510,6 @@
 			__netif_rx_schedule(dev);
 		}
 #else
-		{
 		if (eth_int_cause & (BIT2 | BIT11))
 			mv64340_eth_receive_queue(dev, 0);
 

--FkmkrVfFsRoUs1wW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mp.2"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/27 12:26:38-07:00 dfarnsworth@mvista.com 
#   Add a function to detect at runtime whether a PHY is attached to
#   the specified port, and use it to cause the probe routine to fail
#   when there is no PHY.
#   
#   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
# 
# drivers/net/mv643xx_eth.c
#   2005/01/27 12:26:27-07:00 dfarnsworth@mvista.com +47 -0
#   Add a function to detect at runtime whether a PHY is attached to
#   the specified port, and use it to cause the probe routine to fail
#   when there is no PHY.
#   
#   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
# 
diff -Nru a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c	2005-01-27 13:12:37 -07:00
+++ b/drivers/net/mv643xx_eth.c	2005-01-27 13:12:37 -07:00
@@ -81,6 +81,7 @@
 static int mv64340_poll(struct net_device *dev, int *budget);
 #endif
 static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
+static int ethernet_phy_detect(unsigned int eth_port_num);
 
 static void __iomem *mv64x60_eth_shared_base;
 
@@ -1441,6 +1442,14 @@
 		}
 	}
 
+	err = ethernet_phy_detect(port_num);
+	if (err) {
+		pr_debug("MV643xx ethernet port %d: "
+					"No PHY detected at addr %d\n",
+					port_num, ethernet_phy_get(port_num));
+		return err;
+	}
+
 	err = register_netdev(dev);
 	if (err)
 		goto out;
@@ -2040,6 +2049,44 @@
 	/* Perform dummy reads from MIB counters */
 	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION; i += 4)
 		MV_READ(MV64340_ETH_MIB_COUNTERS_BASE(eth_port_num) + i);
+}
+
+
+/*
+ * ethernet_phy_detect - Detect whether a phy is present
+ *
+ * DESCRIPTION:
+ *	This function tests whether there is a PHY present on
+ *	the specified port.
+ *
+ * INPUT:
+ *	unsigned int    eth_port_num   Ethernet Port number.
+ *
+ * OUTPUT:
+ *       None
+ *
+ * RETURN:
+ *       0 on success
+ *       -ENODEV on failure
+ *
+ */
+static int ethernet_phy_detect(unsigned int port_num)
+{
+	unsigned int phy_reg_data0;
+	int auto_neg;
+
+	eth_port_read_smi_reg(port_num, 0, &phy_reg_data0);
+	auto_neg = phy_reg_data0 & 0x1000;
+	phy_reg_data0 ^= 0x1000;			/* invert auto_neg */
+	eth_port_write_smi_reg(port_num, 0, phy_reg_data0);
+
+	eth_port_read_smi_reg(port_num, 0, &phy_reg_data0);
+	if ((phy_reg_data0 & 0x1000) == auto_neg)
+		return -ENODEV;				/* change didn't take */
+
+	phy_reg_data0 ^= 0x1000;
+	eth_port_write_smi_reg(port_num, 0, phy_reg_data0);
+	return 0;
 }
 
 

--FkmkrVfFsRoUs1wW--
