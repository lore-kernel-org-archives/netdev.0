From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH] mv643xx: permit VLAN tagged rx packets + minor cleanup
Date: Mon, 28 Feb 2005 17:07:42 -0700
Message-ID: <20050301000742.GA3163@xyzzy>
References: <20050217224239.GA16609@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
To: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050217224239.GA16609@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've added two changesets (1.2078 and 1.2079) to my mv643xx-enet tree.
A combined diff for the two changesets is included at the end of this
message.

The other changesets below have already been pulled into netdev-2.6.

Thanks,
-Dale

Please do a

	bk pull bk://dfarnsworth.bkbits.net/linux-2.5-mv643xx-enet

This will update the following files:

 drivers/net/Kconfig       |    5 
 drivers/net/mv643xx_eth.c | 2687 ++++++++++++++++++++++++++--------------------
 drivers/net/mv643xx_eth.h |  641 ++++------
 include/linux/mv643xx.h   |  448 +++++--
 4 files changed, 2114 insertions(+), 1667 deletions(-)

through these ChangeSets:

<dale@farnsworth.org> (05/02/28 1.2079)
   mv643xx: remove superfluous function, mv643xx_set_ethtool_ops
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/28 1.2078)
   mv643xx: raise size of receive skbs to allow for an optional VLAN tag
   
   VLAN tag needs an extra 4 bytes in receive skb
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/22 1.2077)
   Remove call to msleep() while locks are held.  We don't really need to
   wait for the link to come up.  It was a workaround to avoid a transient
   error message, "Virtual device %s asks to queue packet!\n", in
   dev_queue_xmit() when called by ic_bootp_send_if().  This happens because
   right after opening the network device, there is a pending PHY status
   change interrupt causing the driver to call netif_stop_queue().  A half
   second later, the link comes up and all is well.  We could have moved
   the call to msleep() to mv643xx_eth_open() to perpetuate the workaround,
   but I think it's best to remove it entirely.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/22 1.2076)
   Ensure that we only change the Port Serial Control Reg while the port is
   disabled.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2075)
   Add ethtool support to the mv643xx ethernet driver.
   Initially, we add statistics and link status reporting.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2074)
   Enable the mv643xx ethernet support on platforms using the MV64360 chip.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2073)
   Disable tcp/udp checksum offload to hardware.  It generally works,
   but the hardware appears to generate the wrong checksum if the
   hw checksum generation wasn't used in the previous packet sent.
   
   I'm increasingly confident this is a hardware error.
   We'll disable hw tcp/udp checksum generation until we have a fix
   or workaround.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2072)
   We already set ETH_TX_ENABLE_INTERRUPT whenever we set ETH_TX_LAST_DESC.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2071)
   Update tx_bytes statistic when using hw tcp/udp checksum generation.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2070)
   Call netif_carrier_off when closing the driver.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2069)
   Trivial.  Remove repeated comment.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2068)
   Clear transmit l4i_chk even when the hardware ignores it.
   Not absolutely necessary, but makes debugging easier.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2067)
   Increment tx_ring_skbs before calling eth_port_send, since
   otherwise the irq handler may check and decrement it before
   we increment it.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2066)
   Fix handling of unaligned tiny fragments not handled by hardware
   Check all fragments instead of just the last.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2065)
   Fix a few places I missed in the previous rename patch.
   Rename: mv64x60 => mv643xx
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.17)
   Big rename.
   
   Change MV64340 => MV643XX and mv64340 => mv643xx
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.16)
   Rename MV_READ => mv_read and MV_WRITE => mv_write
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.15)
   Additional whitespace cleanups, mostly changing spaces to tabs in comments

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.14)
   Run mv643xx_eth.[ch] through scripts/Lindent
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.13)
   Add a function to detect at runtime whether a PHY is attached to
   the specified port, and use it to cause the probe routine to fail
   when there is no PHY.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.12)
   This one liner removes a spurious left paren fixing an obvious syntax error
   in the #ifndef MV64340_NAPI case

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.11)
   Add support for PHYs/boards that don't support autonegotiation.
     
   Signed-off-by: Brian Waite <brian@waitefamily.us>
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.10)
   With this patch, the driver now calls netif_carrier_off/netif_carrier_on
   on a link down/up condition.
     
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.9)
   This patch cleans up the handling of receive skb sizing.
     
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.8)
   This patch simplifies the mv64340_eth_set_rx_mode function without
   changing its behavior.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.7)
   This patch makes the use of the MV64340_RX_QUEUE_FILL_ON_TASK config macro
   more consistent, though the macro remains undefined, since the feature still
   does not work properly.
           
   Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.6)
   This patch adds support for passing additional parameters via the
   platform_device interface.  These additional parameters are:
           size of RX and TX descriptor rings
           port_config value 
           port_config_extend value
           port_sdma_config value
           port_serial_control value
           PHY address                                                                                                                                             Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.5)
   This patch adds device driver model support to the mv643xx_eth driver.
   
   This is a change to the driver's programming interface.  Platform
   code must now pass in the address of the MV643xx ethernet registers
   and IRQ.  If firmware doesn't set the MAC address, platform code
   must also pass in the MAC address.
   
   Also, note that local MV_READ/MV_WRITE macros are used rather than              using global macros.  Keeping the macro names minimizes the patch size.         The names will be changed to mv_read/mv_write in a later cosmetic               cleanup patch.                                                                                                                                                  Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.4)
   This patch replaces the use of the pci_map_* functions with the
   corresponding dma_map_* functions.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.3)
   This patch fixes the code that enables hardware checksum generation.
   The previous code has so many problems that it appears to never have 
   worked 2.6.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.2)
   This patch removes spin delays (count to 1000000, ugh) and instead waits
   with udelay or msleep for hardware flags to change.
   
   It also adds a spinlock to protect access to the MV64340_ETH_SMI_REG,
   which is shared across ports.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.1)
   This patch removes code that is redundant or useless.
   The biggest area is in pre-initializing the RX and TX descriptor
   rings, which only obfuscates the driver since the ring data is
   overwritten without being used.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

Combined diff for changesets 1.2078 and 1.2079:

diff -u b/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
--- b/drivers/net/mv643xx_eth.c	2005-02-28 16:12:26 -07:00
+++ b/drivers/net/mv643xx_eth.c	2005-02-28 16:50:38 -07:00
@@ -51,8 +51,11 @@
  */
 
 /* Constants */
-#define WRAP				ETH_HLEN + 2 + 4
-#define RX_SKB_SIZE			((dev->mtu + WRAP + 7) & ~0x7)
+#define VLAN_HLEN		4
+#define FCS_LEN			4
+#define WRAP			NET_IP_ALIGN + ETH_HLEN + VLAN_HLEN + FCS_LEN
+#define RX_SKB_SIZE		((dev->mtu + WRAP + 7) & ~0x7)
+
 #define INT_CAUSE_UNMASK_ALL		0x0007ffff
 #define INT_CAUSE_UNMASK_ALL_EXT	0x0011ffff
 #ifdef MV643XX_RX_QUEUE_FILL_ON_TASK
@@ -60,6 +63,7 @@
 #define INT_CAUSE_CHECK_BITS		INT_CAUSE_UNMASK_ALL
 #define INT_CAUSE_CHECK_BITS_EXT	INT_CAUSE_UNMASK_ALL_EXT
 #endif
+
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
 #define MAX_DESCS_PER_SKB	(MAX_SKB_FRAGS + 1)
 #else
@@ -83,7 +87,7 @@
 #endif
 static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
 static int ethernet_phy_detect(unsigned int eth_port_num);
-void mv643xx_set_ethtool_ops(struct net_device *netdev);
+static struct ethtool_ops mv643xx_ethtool_ops;
 
 static char mv643xx_driver_name[] = "mv643xx_eth";
 static char mv643xx_driver_version[] = "1.0";
@@ -1399,7 +1403,7 @@
 	dev->tx_queue_len = mp->tx_ring_size;
 	dev->base_addr = 0;
 	dev->change_mtu = mv643xx_eth_change_mtu;
-	mv643xx_set_ethtool_ops(dev);
+	SET_ETHTOOL_OPS(dev, &mv643xx_ethtool_ops);
 
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
 #ifdef MAX_SKB_FRAGS
@@ -3017,7 +3021,7 @@
 	}
 }
 
-struct ethtool_ops mv643xx_ethtool_ops = {
+static struct ethtool_ops mv643xx_ethtool_ops = {
 	.get_settings           = mv643xx_get_settings,
 	.get_drvinfo            = mv643xx_get_drvinfo,
 	.get_link               = ethtool_op_get_link,
@@ -3030,7 +3034,2 @@
 
-void mv643xx_set_ethtool_ops(struct net_device *netdev)
-{
-	SET_ETHTOOL_OPS(netdev, &mv643xx_ethtool_ops);
-}
-
 /************* End ethtool support *************************/
